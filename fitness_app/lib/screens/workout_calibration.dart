import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class WorkoutCalibration extends StatefulWidget {
  final PoseClass poseClass;

  WorkoutCalibration(this.poseClass);

  @override
  _WorkoutCalibrationState createState() => _WorkoutCalibrationState();
}

class _WorkoutCalibrationState extends State<WorkoutCalibration> {
  late Future future;
  CameraController? _controller;
  int _cameraIndex = 1;
  bool angleCalibrated = false;
  String instructionText = '';
  int calibrationCounter = 0;

  @override
  void initState() {
    super.initState();
    future = _getFuture();

    accelerometerEvents.listen((AccelerometerEvent event) {
      if(mounted){
        setState(() {
        double x = event.x, y = event.y, z = event.z;
        double norm_Of_g = math
            .sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        x = event.x / norm_Of_g;
        y = event.y / norm_Of_g;
        z = event.z / norm_Of_g;

        double xInclination = -(math.asin(x) * (180 / math.pi));
        double yInclination = (math.acos(y) * (180 / math.pi));
        double zInclination = (math.atan(z) * (180 / math.pi));

        _resetCalibration() {
          calibrationCounter = 0;
          angleCalibrated = false;
        }

        if (xInclination.round() < -5) {
          instructionText = 'Rotate right';
          _resetCalibration();
        } else if (xInclination.round() > 5) {
          instructionText = 'Rotate left';
          _resetCalibration();
        } else if (zInclination.round() < -3) {
          instructionText = 'Tilt Up';
          _resetCalibration();
        } else if (zInclination.round() > 10) {
          instructionText = 'Tilt Down';
          _resetCalibration();
        } else {
          instructionText = 'Hold...';
          calibrationCounter++;
          if (calibrationCounter >= 18) {
            instructionText = 'Ready to Proceed!';
            angleCalibrated = true;
          }
          ;
        }
      });
    }});
  }

  _getFuture() async {
    cameras = await availableCameras();
    startLiveFeed();
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    return Material(
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CameraPreview(_controller!),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: new Align(
                  alignment: Alignment.topCenter,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Text(
                            instructionText,
                            style: TextStyle(
                                fontFamily: 'nunito',
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        width: 300,
                        decoration: BoxDecoration(
                          color: angleCalibrated
                              ? kPrimaryColor
                              : Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      )
                    ],
                  )),
            ),
            Container(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: new Align(
                  alignment: Alignment.bottomCenter,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 10,
                          color: angleCalibrated
                              ? kPrimaryColor
                              : Colors.grey.withOpacity(0.8),
                          splashColor: angleCalibrated
                              ? Colors.white
                              : Colors.transparent,
                          height: 60,
                          child: Text(
                            '   Next   ',
                            style: TextStyle(
                                fontFamily: 'nunito',
                                    fontSize: 30,
                                    color: angleCalibrated
                                        ? Colors.white
                                        : Colors.white30,
                                    fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (angleCalibrated) {
                              Navigator.pushNamed(
                                context,
                                '/workoutsession',
                                arguments: widget.poseClass
                              );
                            }
                          })
                    ],
                  )),
            ))
          ],
        ),
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
      setState(() {});
    });
  }

  Future stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _liveFeedBody();
          } else {
            return Text('Loading...');
          }
        },
      ),
    );
  }
}
