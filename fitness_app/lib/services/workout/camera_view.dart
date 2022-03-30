import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../main.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.title,
      required this.customPaint,
      required this.onImage,
      required this.state,
      required this.poseClass,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final PoseClass poseClass;
  int state;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  int _cameraIndex = 1;
  late int _state;

  @override
  void initState() {
    super.initState();
    _state = widget.state;
    if (_state == 1) startLiveFeed();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == 2) {
      stopLiveFeed();
    }

    return Scaffold(
      // appBar: _state == 1
      //     ? AppBar(
      //         automaticallyImplyLeading: false,
      //         backgroundColor: Colors.black.withOpacity(0.7),
      //         title: Text(
      //           poseClassToString(widget.poseClass),
      //           style: TextStyle(
      //               color: Colors.white,
      //               fontFamily: 'nunito',
      //               fontWeight: FontWeight.w900),
      //         ),
      //         centerTitle: true,
      //         toolbarHeight: 35,
      //         actions: [
      //           Padding(
      //             padding: EdgeInsets.only(right: 20.0),
      //             child: GestureDetector(
      //               onTap: _switchLiveCamera,
      //               child: Icon(
      //                 Platform.isIOS
      //                     ? Icons.flip_camera_ios_outlined
      //                     : Icons.flip_camera_android_outlined,
      //               ),
      //             ),
      //           ),
      //         ],
      //       )
      //     : null,
      body: _state == 1 ? _liveFeedBody() : Container(color: kPrimaryColor),
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

  Future startLiveFeed() async {
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

  Future stopLiveFeed() async {
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
    await stopLiveFeed();
    await startLiveFeed();
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
}
