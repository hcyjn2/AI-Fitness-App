import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/services/workout/camera_view.dart';
import 'package:fitness_app/services/workout/classification/pose_classifier_processor.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:fitness_app/services/workout/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../main.dart';

final kVerbose = false;
final isStreamMode = true;
final PoseDetectorOptions poseDetectorOptions = PoseDetectorOptions(
    model: PoseDetectionModel.base, mode: PoseDetectionMode.streamImage);

class ExperimentScreen extends StatefulWidget {
  @override
  _ExperimentScreenState createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  PoseDetector poseDetector =
      GoogleMlKit.vision.poseDetector(poseDetectorOptions: poseDetectorOptions);
  bool isBusy = false;
  CustomPaint? customPaint;
  late Future cameraFuture;
  List<String> classificationResult = [];
  late PoseClassifierProcessor poseClassifierProcessor;
  List<PoseSample> __poseSamples = [];
  bool isInit = true;
  int score = 0;

  //To Load Pose Samples from CSV
  Future<List<PoseSample>> loadPoseSamples() async {
    List<PoseSample> poseSamples = [];

    List<String> csvData = await PoseSample.readCSV();

    for (var row in csvData)
      poseSamples.add(await PoseSample.getPoseSample(row));

    return poseSamples;
  }

  @override
  void dispose() async {
    super.dispose();
    await poseDetector.close();
  }

  @override
  void initState() {
    super.initState();

    cameraFuture = _getCameraFuture();
  }

  _getCameraFuture() async {
    cameras = await availableCameras();
    __poseSamples = await loadPoseSamples();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: cameraFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraView(
                        title: 'Pose Detector',
                        customPaint: customPaint,
                        onImage: (inputImage) {
                          processImage(inputImage);
                        },
                      );
                    } else {
                      return Text('Loading...');
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;

    // Equivalent to List<PoseLandmark> allPoseLandmarks = pose.getAllPoseLandmarks();
    final poses = await poseDetector.processImage(inputImage);

    // -----------------------Processing Body--------------------------------
    if (isInit) {
      poseClassifierProcessor =
          await new PoseClassifierProcessor(isStreamMode, __poseSamples);

      isInit = false;
    }

    for (Pose pose in poses)
      classificationResult = poseClassifierProcessor.getPoseResult(pose);

    // -----------------------Processing Body--------------------------------

    // Check if image input is valid then generate overlay over the images
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation, classificationResult);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
