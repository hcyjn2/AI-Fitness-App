import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/services/workout/camera_view.dart';
import 'package:fitness_app/services/workout/classification/pose_classifier_processor.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:fitness_app/services/workout/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

final kVerbose = false;
final isStreamMode = true;
final PoseDetectorOptions poseDetectorOptions = PoseDetectorOptions(
    model: PoseDetectionModel.base, mode: PoseDetectionMode.streamImage);

class WorkoutSession extends StatefulWidget {
  @override
  _WorkoutSessionState createState() => _WorkoutSessionState();
}

class _WorkoutSessionState extends State<WorkoutSession> {
  PoseDetector poseDetector =
      GoogleMlKit.vision.poseDetector(poseDetectorOptions: poseDetectorOptions);
  bool isBusy = false;
  CustomPaint? customPaint;
  late Future future;
  List<String> classificationResult = [];
  late PoseClassifierProcessor poseClassifierProcessor;
  List<PoseSample> _poseSamples = [];
  bool isInit = true;

  // 0 = Loading, 1 = Workout Session, 2 = End of Workout
  int _state = 0;

  late Tuple3<List<String>, List<String>, List<int>> classificationResultTuple;
  List<String> resultClass = [];
  List<int> resultRep = [];

  //To Load Pose Samples from CSV
  Future<List<PoseSample>> loadPoseSamples() async {
    List<PoseSample> poseSamples = [];

    List<String> csvData = await PoseSample.readCSV();

    for (var row in csvData)
      poseSamples.add(await PoseSample.getPoseSample(row));

    return poseSamples;
  }

  late Timer _timer;
  int _countDownDuration = 3;
  int _workoutDuration = 10;

  void startTimer() async {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_countDownDuration == 0) {
          setState(() {
            _state = 1;
            timer.cancel();
            startWorkoutTimer();
          });
        } else {
          setState(() {
            _countDownDuration--;
          });
        }
      },
    );
  }

  void startWorkoutTimer() async {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_workoutDuration == 0) {
          setState(() async {
            await poseDetector.close();
            timer.cancel();
            _state = 2;
            buildWorkoutFinishedAlert();
          });
        } else {
          setState(() {
            _workoutDuration--;
          });
        }
      },
    );
  }

  Widget buildBody(int state) {
    if (state == 0) {
      return _countDownBody();
    } else if (state == 1) {
      return CameraView(
        title: 'Pose Detector',
        customPaint: customPaint,
        onImage: (inputImage) {
          processImage(inputImage);
        },
        state: _state,
      );
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

  //save mood calendar data as Json format with sharedpreferences
  Future _saveData(String classIdentifier, int classRepetition) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _initSaveData(prefs);

    if (prefs.containsKey(classIdentifier)) {
      int previousBest = prefs.getInt(classIdentifier) ?? 0;

      if (classRepetition > previousBest) {
        await prefs.setInt(classIdentifier, classRepetition);
      }
    }
  }

  Future _initSaveData(SharedPreferences prefs) async {
    var existedRecords = prefs.getKeys();

    if (existedRecords.isEmpty) {
      for (var classIdentifier in poseClasses)
        await prefs.setInt(classIdentifier, 0);
    }
  }

  Future buildWorkoutFinishedAlert() async {
    String className = 'null';
    String classRepetition = 'null';

    if (resultClass.isNotEmpty) {
      await _saveData(resultClass.last, resultRep.last);
      className = classIdentifierToClassName(resultClass.last);
      classRepetition = resultRep.last.toString();
    }

    return showDialog(
        barrierColor: kPrimaryColor,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: resultClass.isEmpty
                ? Text('No Worry, You can do better next time!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))
                : Text(
                    'Great Work! \n\n You have just finished the workout. \n' +
                        className +
                        ' : ' +
                        classRepetition +
                        ' reps. \n Give yourself a pat on the back.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
            elevation: 25.0,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  elevation: 5.0,
                  color: Colors.grey,
                  child: Text('BACK',
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))),
                  onPressed: () {
                    setState(() {
                      //NO Action
                      dispose();
                      Navigator.pop(context);
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

  @override
  void dispose() async {
    await poseDetector.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    future = _getFuture();
  }

  _getFuture() async {
    cameras = await availableCameras();
    _poseSamples = await loadPoseSamples();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _state == 1
          ? Padding(
              padding: const EdgeInsets.only(top: 50),
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
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return buildBody(_state);
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
          await new PoseClassifierProcessor(isStreamMode, _poseSamples);

      isInit = false;
    }

    for (Pose pose in poses) {
      classificationResultTuple =
          await poseClassifierProcessor.getPoseResult(pose);
      classificationResult = classificationResultTuple.item1;
      resultClass = classificationResultTuple.item2;
      resultRep = classificationResultTuple.item3;
    }
    // -----------------------Processing Body--------------------------------

    // Check if image input is valid then generate overlay over the images
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation, resultClass, resultRep);
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
