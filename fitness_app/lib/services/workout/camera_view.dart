import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../main.dart';

// 0 = Loading, 1 = Workout Session, 2 = End of Workout
int _state = 0;

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      required this.onImage,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  CameraController? _controller;
  int _cameraIndex = 1;

  late Timer _timer;
  int _countDownDuration = 3;
  int _workoutDuration = 30;

  void startCountDownTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_countDownDuration == 0) {
          setState(() {
            _state = 1;
            _startLiveFeed();
            startWorkoutTimer();
            timer.cancel();
          });
        } else {
          setState(() {
            _countDownDuration--;
          });
        }
      },
    );
  }

  void startWorkoutTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_workoutDuration == 0) {
          setState(() {
            _state = 2;
            buildWorkoutFinishedAlert();
            _stopLiveFeed();
            timer.cancel();
          });
        } else {
          setState(() {
            _workoutDuration--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startCountDownTimer();
  }

  @override
  void dispose() {
    _state = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _state == 1
          ? Padding(
              padding: const EdgeInsets.only(top: 110),
              child: Container(
                height: 80,
                width: 80,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: kPrimaryColor,
                    child: Text(
                      _workoutDuration.toString(),
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      appBar: _state == 1
          ? AppBar(
              backgroundColor: kPrimaryColor,
              title: Text('Workout Feature'),
              centerTitle: true,
              toolbarHeight: 40,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: _switchLiveCamera,
                    child: Icon(
                      Platform.isIOS
                          ? Icons.flip_camera_ios_outlined
                          : Icons.flip_camera_android_outlined,
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: buildBody(_state),
      // floatingActionButton: _floatingActionButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildBody(int state) {
    if (state == 0) {
      return _countDownBody();
    } else if (state == 1) {
      return _liveFeedBody();
    } else {
      return _workoutFinishedBody();
    }
  }

  Widget _workoutFinishedBody() {
    return Container(color: kPrimaryColor);
  }

  Widget _countDownBody() {
    return Container(
      color: kPrimaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ready ?',
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              _countDownDuration.toString(),
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===========================================Widgets====================================================
  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller!),
          if (widget.customPaint != null) widget.customPaint!,
        ],
      ),
    );
  }

  // ==================================================Private Methods=========================================

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
    _state = 2;
  }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0)
      _cameraIndex = 1;
    else
      _cameraIndex = 0;
    await _stopLiveFeed();
    await _startLiveFeed();
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }

  Future buildWorkoutFinishedAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Great Work! \n\n You have just finished the workout. \n Give yourself a pat on the back.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    textStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  elevation: 5.0,
                  color: Colors.grey,
                  child: Text('BACK',
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold))),
                  onPressed: () async {
                    setState(() {
                      //NO Action
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          );
        });
  }
}
