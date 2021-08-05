import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/services/workout/camera_view.dart';
// import 'package:fitness_app/services/workout/classification/models/pose_classifier_processor.dart';
import 'package:fitness_app/services/workout/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../main.dart';

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
  // late PoseClassifierProcessor poseClassifierProcessor;
  late List<String> classificationResult;

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

    // poseClassifierProcessor = new PoseClassifierProcessor(isStreamMode);
    //
    // for (Pose pose in poses)
    //   classificationResult = poseClassifierProcessor.getPoseResult(pose);

    print('Found ${poses.length} poses');

    //Print the landmarks(tracking points of the body) coordinates
    for (var i in poses) {
      for (var j in i.landmarks.values) {
        print(j.type);
        print(j.x);
        print(j.y);
      }
    }

    // -----------------------Processing Body--------------------------------

    // Check if image input is valid then generate overlay over the images
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
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
