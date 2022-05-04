import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/services/workout/camera_view.dart';
import 'package:fitness_app/services/workout/classification/best_record.dart';
import 'package:fitness_app/services/workout/classification/workout_record.dart';
import 'package:fitness_app/services/workout/classification/pose_classifier_processor.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:fitness_app/services/workout/pose_painter.dart';
import 'package:fitness_app/widgets/workout_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

final kVerbose = false;
final isStreamMode = true;
final PoseDetectorOptions poseDetectorOptions = PoseDetectorOptions(
    model: PoseDetectionModel.accurate, mode: PoseDetectionMode.streamImage);

class WorkoutSession extends StatefulWidget {
  final PoseClass poseClass;
  WorkoutSession(this.poseClass);

  @override
  _WorkoutSessionState createState() => _WorkoutSessionState();
}

class _WorkoutSessionState extends State<WorkoutSession> {
  PoseDetector poseDetector =
      GoogleMlKit.vision.poseDetector(poseDetectorOptions: poseDetectorOptions);
  bool isBusy = false;
  late PoseClassifierProcessor poseClassifierProcessor;
  CustomPaint? customPaint;
  List<String> classificationResult = [];
  List<PoseSample> _poseSamples = [];
  List<WorkoutRecord> _workoutRecordList = [];
  List<BestRecord> _bestRecordList = [];
  late Future future;
  bool isInit = true;
  bool narration = true;
  DateTime _currentDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final _player = AudioPlayer();

  // Level System
  int level = 1;
  bool isLevelUp = false;
  int currentExperience = 0;
  int experienceUpperBound = getExpUpperBound(1);

  // 0 = Loading, 1 = Workout Session, 2 = End of Workout
  int _state = 0;

  late Tuple3<List<String>, List<String>, List<int>> classificationResultTuple;
  List<String> resultClass = [];
  List<int> resultRep = [];

  //To Load Pose Samples from CSV
  Future<List<PoseSample>> loadPoseSamples() async {
    List<PoseSample> poseSamples = [];

    List<String> csvData = await PoseSample.readCSV(widget.poseClass);

    for (var row in csvData)
      poseSamples.add(await PoseSample.getPoseSample(row));

    return poseSamples;
  }

  late Timer _timer;
  int _countDownDuration = 4;
  int _workoutDuration = 15;

  void startTimer() async {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (_countDownDuration <= 0) {
          _player.play();
          setState(() {
            _state = 1;
            timer.cancel();
            startWorkoutTimer();
          });
        } else {
          if (_countDownDuration <= 4 && _countDownDuration >= 2)
            await _player.setAsset('assets/audios/countdown_tick.mp3');
          else
            await _player.setAsset('assets/audios/countdown_go.mp3');
          setState(() {
            _countDownDuration--;
            if (_countDownDuration <= 4 && _countDownDuration >= 2)
              _player.play();
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
        if (_workoutDuration <= 0) {
          poseDetector.close();
          poseClassifierProcessor.stop();
          setState(() {
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
        poseClass: widget.poseClass,
      );
    } else {
      return _workoutFinishedBody();
    }
  }

  Widget _workoutFinishedBody() {
    poseDetector.close();
    return Container(color: kPrimaryColor);
  }

  Widget _countDownBody() {
    return Container(
      color: kPrimaryColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _countDownDuration == 4
                ? Text(
                    'Ready ?',
                    style: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : Text(
                    _countDownDuration == 0
                        ? 'Go !'
                        : _countDownDuration.toString(),
                    style: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 105,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future _initSaveData() async {
    for (var classIdentifier in poseClassesWithoutVariation)
      _bestRecordList.add(
          BestRecord(exerciseClass: classIdentifier, exerciseRepetition: 0));
  }

  Future _saveWorkoutData(String classIdentifier, int classRepetition) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var counter = await prefs.getInt('counter') ?? 0;
    var totalWorkoutDone = await prefs.getInt('Total Workout Done') ?? 0;
    var dailyChallengeExercise = stringToPoseClass(
        prefs.getString('Daily Challenge Exercise') ?? 'Push Up');
    var dailyChallengeRep = prefs.getInt('Daily Challenge Rep') ?? 1;
    var dailyChallengeDone = prefs.getBool('Daily Challenge Done') ?? false;

    currentExperience++;
    if (currentExperience == experienceUpperBound) {
      currentExperience = 0;
      level++;
      isLevelUp = true;
    }
    await prefs.setInt('level', level);
    await prefs.setInt('currentExperience', currentExperience);

    if (classIdentifierToPoseClass(resultClass.last) ==
            dailyChallengeExercise &&
        resultRep.last >= dailyChallengeRep) {
      dailyChallengeDone = true;
    }

    await prefs.setString(
        'Last Workout Class', classIdentifierToClassName(classIdentifier));
    await prefs.setInt('Last Workout Count', classRepetition);
    await prefs.setInt('Total Workout Done', totalWorkoutDone + 1);
    await prefs.setBool('Daily Challenge Done', dailyChallengeDone);

    _workoutRecordList.add(WorkoutRecord(
        dateTime: _currentDate,
        exerciseClass: resultClass.last,
        exerciseRepetition: resultRep.last));

    await prefs.setString(
        'Workout Record List', WorkoutRecord.encode(_workoutRecordList));
    await prefs.setString(
        'Best Record List', BestRecord.encode(_bestRecordList));

    counter++;

    await prefs.setInt('counter', counter);
    await prefs.setBool('narration', narration);
  }

  Future _loadWorkoutRecordData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<WorkoutRecord> decodedData =
        WorkoutRecord.decode(prefs.get('Workout Record List').toString());

    return decodedData;
  }

  Future _loadBestRecordData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var counter = await prefs.getInt('counter') ?? 0;
    narration = await prefs.getBool('narration') ?? true;

    //Level System
    level = await prefs.getInt('level') ?? 1;
    currentExperience = await prefs.getInt('currentExperience') ?? 0;
    experienceUpperBound = getExpUpperBound(level);

    if (counter < 1) _initSaveData();

    List<BestRecord> decodedData =
        BestRecord.decode(prefs.get('Best Record List').toString());

    return decodedData;
  }

  updateBestRecord(String classIdentifier, int classRepetition,
      List<BestRecord> bestRecordList) {
    for (var bestRecord in bestRecordList) {
      if (bestRecord.exerciseClass == classIdentifier) if (classRepetition >
          bestRecord.exerciseRepetition)
        bestRecord.exerciseRepetition = classRepetition;
    }
  }

  Future buildWorkoutFinishedAlert() async {
    String className = 'null';
    String classRepetition = 'null';

    if (resultClass.isNotEmpty) {
      if (isValidClass(resultClass.last)) {
        updateBestRecord(resultClass.last, resultRep.last, _bestRecordList);
        await _saveWorkoutData(resultClass.last, resultRep.last);

        className = resultClass.last;
        classRepetition = resultRep.last.toString();
      } else if (resultClass.length == 2) {
        if (isValidClass(resultClass[resultClass.length - 2])) {
          String validClass = resultClass[resultClass.length - 2];
          int validRep = resultRep[resultClass.length - 2];

          updateBestRecord(validClass, validRep, _bestRecordList);
          await _saveWorkoutData(validClass, validRep);

          className = validClass;
          classRepetition = validRep.toString();
        }
      } else {
        for (int i = 2; i < resultClass.length; i++) {
          if (isValidClass(resultClass[resultClass.length - i])) {
            String validClass = resultClass[resultClass.length - i];
            int validRep = resultRep[resultClass.length - i];

            updateBestRecord(validClass, validRep, _bestRecordList);
            await _saveWorkoutData(validClass, validRep);

            className = validClass;
            classRepetition = validRep.toString();

            break;
          }
        }
      }
    }

    if (narration) {
      if (resultClass.isNotEmpty && isValidClass(className)) {
        await _player.setAsset('assets/audios/completed_female.mp3');
      } else if ((resultClass.isEmpty || className == 'null')) {
        await _player.setAsset('assets/audios/failed_female.mp3');
      } else {
        await _player.setAsset('assets/audios/failed_female.mp3');
      }
      _player.play();
      Future.delayed(Duration(seconds: 5)).whenComplete(() => {
            if (isLevelUp)
              {
                _player.setAsset('assets/audios/level_up.mp3'),
                _player.play(),
              }
          });
    }

    Widget buildLevelPanel(int lv) {
      return WorkoutButton(
        elevation: 0,
        color: Colors.grey.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: lv == 2
                        ? AssetImage('assets/images/lv1.png')
                        : lv == 3
                            ? AssetImage('assets/images/lv2.png')
                            : lv == 4
                                ? AssetImage('assets/images/lv3.png')
                                : AssetImage('assets/images/lv4.png'),
                    height: 70,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(
                      FontAwesomeIcons.arrowRightLong,
                      color: Colors.black54,
                    ),
                  ),
                  Image(
                    image: lv == 2
                        ? AssetImage('assets/images/lv2.png')
                        : lv == 3
                            ? AssetImage('assets/images/lv3.png')
                            : lv == 4
                                ? AssetImage('assets/images/lv4.png')
                                : AssetImage('assets/images/lv5.png'),
                    height: 70,
                  ),
                ],
              ),
              Text('Level Up! \n You are now Level ' + lv.toString() + '!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
    }

    return showDialog(
        barrierColor: kPrimaryColor,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: (resultClass.isNotEmpty && isValidClass(className))
                ? Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Great Job!  \n\n',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'nunito',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900),
                            ),
                            TextSpan(
                              text:
                                  'You have just completed a workout. \n\n\n\n',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'nunito',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900),
                            ),
                            TextSpan(
                                text: classIdentifierToClassName(className) +
                                    ' : ' +
                                    classRepetition +
                                    ' reps.\n\n\n',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'nunito',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    background: Paint()
                                      ..strokeWidth = 30.0
                                      ..color = Colors.grey.withOpacity(0.15)
                                      ..style = PaintingStyle.stroke
                                      ..strokeJoin = StrokeJoin.round)),
                          ],
                        ),
                      ),
                      isLevelUp ? buildLevelPanel(level) : Text(''),
                    ],
                  )
                : Text('No Worries, You can do better next time!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
            elevation: 25.0,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  elevation: 5.0,
                  color: Colors.grey,
                  child: Text('BACK',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  onPressed: () async {
                    await poseDetector.close();
                    setState(() {
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

    _bestRecordList = await _loadBestRecordData();

    _workoutRecordList = await _loadWorkoutRecordData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _state == 1
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    height: 90,
                    width: 90,
                    child: FittedBox(
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(13.9))),
                        onPressed: () {},
                        backgroundColor: Colors.black.withOpacity(0.7),
                        child: Text(
                          _workoutDuration.toString(),
                          style: TextStyle(
                              fontFamily: 'nunito',
                              fontSize: 32,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    height: 86,
                    width: 86,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13.9),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image(
                              image: widget.poseClass == PoseClass.classSquat
                                  ? AssetImage('assets/images/squat.png')
                                  : widget.poseClass ==
                                          PoseClass.classJumpingJack
                                      ? AssetImage(
                                          'assets/images/jumpingJack.png')
                                      : widget.poseClass ==
                                              PoseClass.classPushUp
                                          ? AssetImage(
                                              'assets/images/pushUp.png')
                                          : AssetImage(
                                              'assets/images/pushUp.png')),
                        )),
                  ),
                ),
              ],
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
                      return Stack(
                        children: [
                          buildBody(_state),
                        ],
                      );
                    } else {
                      return Container(
                        color: kPrimaryColor,
                        child: Center(
                            child: Text(
                          'Loading...',
                          style: TextStyle(
                              fontFamily: 'nunito',
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                      );
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

    // -----------------------Classification--------------------------------
    if (isInit) {
      poseClassifierProcessor = await new PoseClassifierProcessor(
          isStreamMode, _poseSamples, widget.poseClass, narration);

      isInit = false;
    }

    for (Pose pose in poses) {
      classificationResultTuple =
          await poseClassifierProcessor.getPoseResult(pose);
      classificationResult = classificationResultTuple.item1;
      resultClass = classificationResultTuple.item2;
      resultRep = classificationResultTuple.item3;
    }
    // -----------------------Classification--------------------------------

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
    if (mounted && _state != 2) {
      setState(() {});
    }
  }
}

// combo system WIP
// if (resultClass.isNotEmpty) {
// if (isValidClass(resultClass.last) && comboInit == false) {
// comboCounter++;
// comboInit = true;
// startComboTimer(comboInit);
// } else if (isValidClass(resultClass.last) && comboInit == true) {
// comboTimer.cancel();
// comboCounter++;
// startComboTimer(comboInit);
// }
// }
// Combo System
// int comboCounter = 0;
// int comboDuration = 0;
// bool comboInit = false;
// late Timer comboTimer;
// void startComboTimer(bool comboInit) async {
//   comboDuration = 3;
//   const oneSec = const Duration(seconds: 1);
//   comboTimer = new Timer.periodic(
//     oneSec,
//         (Timer timer) {
//       if (comboDuration <= 0) {
//         setState(() {
//           comboInit = false;
//           timer.cancel();
//         });
//       } else {
//         setState(() {
//           comboDuration--;
//         });
//       }
//     },
//   );
// }
