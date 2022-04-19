import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/screens/workout_menu.dart';
import 'package:fitness_app/services/workout/classification/workout_record.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:fitness_app/widgets/workout_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tuple/tuple.dart';

// Dashboard feature
class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final _key1 = GlobalKey();
  final _key2 = GlobalKey();
  final _key3 = GlobalKey();
  final _key4 = GlobalKey();
  final _key5 = GlobalKey();

  late Future future;
  late String _lastWorkoutClass;
  late int _lastWorkoutCount;
  late int _totalWorkoutDone;
  List<double> _weeklyActivityChartData = [
    0.05,
    0.05,
    0.05,
    0.05,
    0.05,
    0.05,
    0.05
  ];
  bool _appTutorial = true;
  late bool showcaseStart;
  final _player = AudioPlayer();

  // Daily Challenge Variables
  bool _dailyChallengeInit = true;
  bool _dailyChallengeDone = false;
  bool _dailyChallengeChecked = false;
  PoseClass _dailyChallengeExercise = PoseClass.classPushUp;
  int _dailyChallengeRep = 1;
  Tuple2<int, PoseClass> _dailyChallenge = Tuple2(1, PoseClass.classPushUp);
  DateTime _dailyChallengeInitDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _initData();
    future = _getFuture();
  }

  Future _loadWorkoutRecordData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<WorkoutRecord> decodedData =
        WorkoutRecord.decode(prefs.get('Workout Record List').toString());

    if (decodedData.isNotEmpty)
      return decodedData;
    else
      return [];
  }

  Future _initData() async {
    List<WorkoutRecord> decodedData = await _loadWorkoutRecordData();

    if (decodedData.isEmpty) return;

    Map<DateTime, double> _weeklyActivityCount = {};
    DateTime monday = today.subtract(Duration(days: today.weekday - 1));
    DateTime tuesday = today.subtract(Duration(days: today.weekday - 2));
    DateTime wednesday = today.subtract(Duration(days: today.weekday - 3));
    DateTime thursday = today.subtract(Duration(days: today.weekday - 4));
    DateTime friday = today.subtract(Duration(days: today.weekday - 5));
    DateTime saturday = today.subtract(Duration(days: today.weekday - 6));
    DateTime sunday =
        today.add(Duration(days: DateTime.daysPerWeek - today.weekday));

    if (decodedData.isNotEmpty) {
      for (var record in decodedData) {
        if (!_weeklyActivityCount.containsKey(record.dateTime))
          _weeklyActivityCount.addAll({record.dateTime: 1.0});
        else
          _weeklyActivityCount.update(
              record.dateTime, (value) => value = value + 1.0);
      }

      _weeklyActivityCount.forEach((key, value) {
        if (key == monday)
          _weeklyActivityChartData[0] = value;
        else if (key == tuesday)
          _weeklyActivityChartData[1] = value;
        else if (key == wednesday)
          _weeklyActivityChartData[2] = value;
        else if (key == thursday)
          _weeklyActivityChartData[3] = value;
        else if (key == friday)
          _weeklyActivityChartData[4] = value;
        else if (key == saturday)
          _weeklyActivityChartData[5] = value;
        else if (key == sunday) _weeklyActivityChartData[6] = value;
      });
    }
  }

  RichText workoutStartMessage = RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      // Note: Styles for TextSpans must be explicitly defined.
      // Child text spans will inherit styles from parent
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        TextSpan(
            text: 'Please make sure your surrounding is ',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Well-Lit', style: workoutStartMessageStyle),
        TextSpan(
            text: ' & have ',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Ample Physical Space', style: workoutStartMessageStyle),
        TextSpan(
            text: ' for this feature.\n\nDo you wish to start now?',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget buildLevelPanel(int lv) {
    return WorkoutButton(
      elevation: 0,
      color: Colors.white,
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

  Future skipTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('App Tutorial', false);
    prefs.setBool('workoutMenuTutorial', false);
    prefs.setBool('scoreboardTutorial', false);
  }

  Future _getFuture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _lastWorkoutClass = prefs.getString('Last Workout Class') ?? 'None';
    _lastWorkoutCount = prefs.getInt('Last Workout Count') ?? 0;
    _totalWorkoutDone = prefs.getInt('Total Workout Done') ?? 0;

    // Load Daily Challenge
    _dailyChallengeExercise = stringToPoseClass(
        prefs.getString('Daily Challenge Exercise') ?? 'Push Up');
    _dailyChallengeRep = prefs.getInt('Daily Challenge Rep') ?? 1;
    _dailyChallengeInit = prefs.getBool('Daily Challenge Init') ?? true;
    _dailyChallengeDone = prefs.getBool('Daily Challenge Done') ?? false;
    _dailyChallengeChecked = prefs.getBool('Daily Challenge Checked') ?? false;
    _dailyChallengeInitDate = DateTime.parse(
        prefs.getString('Daily Challenge Init Date') ?? today.toString());

    // Reset Daily Challenge daily
    if (_dailyChallengeInitDate != today || _dailyChallengeInit == true) {
      _dailyChallengeInit = false;
      _dailyChallenge =
          dailyChallenges.elementAt(Random().nextInt(dailyChallenges.length));
      _dailyChallengeChecked = false;
      _dailyChallengeDone = false;
      _dailyChallengeInitDate = today;
      _dailyChallengeExercise = _dailyChallenge.item2;
      _dailyChallengeRep = _dailyChallenge.item1;

      prefs.setString(
          'Daily Challenge Init Date', _dailyChallengeInitDate.toString());
      prefs.setBool('Daily Challenge Init', _dailyChallengeInit);
      prefs.setBool('Daily Challenge Done', _dailyChallengeDone);
      prefs.setBool('Daily Challenge Checked', _dailyChallengeChecked);
      prefs.setString('Daily Challenge Exercise',
          poseClassToString(_dailyChallengeExercise));
      prefs.setInt('Daily Challenge Rep', _dailyChallengeRep);
    }

    _appTutorial = (await prefs.getBool('App Tutorial')) ?? true;

    if (_appTutorial) {
      buildAppTutorial();
      _appTutorial = false;
      prefs.setBool('App Tutorial', _appTutorial);
    }

    if (showcaseStart) {
      WidgetsBinding.instance!.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context)!.startShowCase(
          [
            _key1,
            _key2,
            _key3,
            _key4,
            _key5,
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.915,
      width: MediaQuery.of(context).size.width * 0.995,
      child: CustomCard(
        boxShadow: BoxShadow(
          color: kAccentColor.withOpacity(0.3),
          spreadRadius: 10,
          blurRadius: 7,
          offset: Offset(0, 1), // changes position of shadow
        ),
        color: kSecondaryColor.withOpacity(0.39),
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 0, 5),
                      child: Container(
                        child: Text(
                          '\u00b7 Dashboard',
                          style: TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2, 1),
                                blurRadius: 8,
                                color: Color.fromARGB(125, 106, 106, 106),
                              ),
                            ],
                            fontFamily: 'Insanibu',
                            fontSize: 41,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                      child: Showcase(
                        key: _key1,
                        description:
                            'This is the Daily Challenge which you can complete to get EXP.',
                        shapeBorder: const RoundedRectangleBorder(),
                        overlayPadding: EdgeInsets.all(8),
                        contentPadding: EdgeInsets.all(20),
                        showcaseBackgroundColor: kPrimaryColor,
                        descTextStyle: TextStyle(
                            fontFamily: 'nunito',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900),
                        child: WorkoutButton(
                          elevation: 5,
                          color: Colors.white.withOpacity(0.95),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.14,
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                children: [
                                  Text('Daily Challenge',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontFamily: 'nunito',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _dailyChallengeChecked
                                      ? Icon(
                                          FontAwesomeIcons.circleCheck,
                                          color: Colors.greenAccent,
                                          size: 55,
                                        )
                                      : Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.075,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.72,
                                          child: Showcase(
                                            key: _key2,
                                            description:
                                                'After Completing Daily Challenge, \n\n This Button will turn Yellow \n\n & You may Press it to Obtain EXP. \n\n Grey = Incomplete. \n Yellow = Press to Obtain EXP.',
                                            shapeBorder:
                                                const RoundedRectangleBorder(),
                                            overlayPadding: EdgeInsets.all(8),
                                            contentPadding: EdgeInsets.all(20),
                                            showcaseBackgroundColor:
                                                kPrimaryColor,
                                            descTextStyle: TextStyle(
                                                fontFamily: 'nunito',
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900),
                                            child: WorkoutButton(
                                              onPressed: () async {
                                                if (_dailyChallengeDone ==
                                                        true &&
                                                    _dailyChallengeChecked ==
                                                        false) {
                                                  dailyChallengeCompletedAlert();

                                                  setState(() {});
                                                } else {
                                                  dailyChallengeNotCompletedAlert();
                                                }
                                              },
                                              elevation: 3.5,
                                              color: _dailyChallengeDone
                                                  ? kPrimaryColor
                                                  : Colors.grey,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Text(
                                                  _dailyChallengeRep
                                                          .toString() +
                                                      ' x ' +
                                                      poseClassToString(
                                                          _dailyChallengeExercise) +
                                                      's in a Session',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      height: 1.16,
                                                      color: _dailyChallengeDone
                                                          ? Colors.white
                                                          : Colors.white
                                                              .withOpacity(0.7),
                                                      fontFamily: 'nunito',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                        child: Showcase(
                          key: _key3,
                          description:
                              'This shows the Last Workout you have done.',
                          shapeBorder: const RoundedRectangleBorder(),
                          overlayPadding: EdgeInsets.all(8),
                          contentPadding: EdgeInsets.all(20),
                          showcaseBackgroundColor: kPrimaryColor,
                          descTextStyle: TextStyle(
                              fontFamily: 'nunito',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                          child: WorkoutButton(
                            elevation: 5,
                            color: Colors.white.withOpacity(0.95),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.185,
                              width: MediaQuery.of(context).size.width * 0.315,
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 12),
                                    child: Text('Last Workout',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            height: 1.25,
                                            fontFamily: 'nunito',
                                            fontSize: 23,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                  Text(_lastWorkoutClass.toString(),
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontFamily: 'nunito',
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.w900)),
                                  Text(_lastWorkoutCount.toString() + ' reps',
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontFamily: 'nunito',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                        child: Showcase(
                          key: _key4,
                          description:
                              'This shows the Total Amount of Workouts you have completed so far.',
                          shapeBorder: const RoundedRectangleBorder(),
                          overlayPadding: EdgeInsets.all(8),
                          contentPadding: EdgeInsets.all(20),
                          showcaseBackgroundColor: kPrimaryColor,
                          descTextStyle: TextStyle(
                              fontFamily: 'nunito',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                          child: WorkoutButton(
                            elevation: 5,
                            color: Colors.white.withOpacity(0.95),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.185,
                              width: MediaQuery.of(context).size.width * 0.315,
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 8),
                                    child: Text('Workouts Done',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            height: 1.25,
                                            fontFamily: 'nunito',
                                            fontSize: 23,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                  Text(_totalWorkoutDone.toString(),
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontFamily: 'nunito',
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Showcase(
                    key: _key5,
                    description:
                        'This shows your Workout Activity through out the Week.',
                    shapeBorder: const RoundedRectangleBorder(),
                    overlayPadding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    contentPadding: EdgeInsets.all(20),
                    showcaseBackgroundColor: kPrimaryColor,
                    descTextStyle: TextStyle(
                        fontFamily: 'nunito',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: WorkoutButton(
                            elevation: 5,
                            color: Colors.white.withOpacity(0.95),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.37,
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 7, bottom: 30),
                                    child: Text('Weekly Activity',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontFamily: 'nunito',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                  Chart<void>(
                                    state: ChartState(
                                      ChartData.fromList(
                                        _weeklyActivityChartData
                                            .map((e) =>
                                                BarValue<void>(e.toDouble()))
                                            .toList(),
                                        axisMax: 12.0,
                                      ),
                                      behaviour: ChartBehaviour(
                                          onItemClicked: (value) {}),
                                      itemOptions: BarItemOptions(
                                        color: kPrimaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3.9),
                                        radius: BorderRadius.vertical(
                                            top: Radius.circular(30.0)),
                                      ),
                                      backgroundDecorations: [],
                                      foregroundDecorations: [
                                        ValueDecoration(
                                            textStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black26,
                                          fontFamily: 'Insanibu',
                                        ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(39, 5, 0, 0),
                            child: weeklyActivityChartLabel())
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Container(
                  child: Center(
                      child: Text(
                'Loading...',
                style: TextStyle(
                    fontFamily: 'nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )));
            }
          },
        ),
      ),
    );
  }

  Future buildAppTutorial() async {
    return showDialog(
        barrierDismissible: false,
        barrierColor: Colors.black45.withOpacity(0.65),
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: kPrimaryColor,
            contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: 600,
              width: 450,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Column(children: [
                      Text(
                        'Hello!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Insanibu',
                            fontSize: 42,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        'Newcomer? \n\n No Worries, Let\'s get into it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 33,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                    ]),
                  ),
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        child: Text(' ➜ ',
                            style: TextStyle(
                                fontFamily: 'nunito',
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: kPrimaryColor)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        showcaseStart = true;
                        setState(() {
                          future = _getFuture();
                        });
                      },
                    ),
                  )),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 233,
                      ),
                      Container(
                          width: 70,
                          height: 35,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                            color: Colors.grey.withOpacity(0.8),
                            child: Text('SKIP',
                                style: TextStyle(
                                    fontFamily: 'nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white.withOpacity(0.8))),
                            onPressed: () async {
                              await skipTutorial();
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget weeklyActivityChartLabel() {
    DateTime monday = today.subtract(Duration(days: today.weekday - 1));
    DateTime tuesday = today.subtract(Duration(days: today.weekday - 2));
    DateTime wednesday = today.subtract(Duration(days: today.weekday - 3));
    DateTime thursday = today.subtract(Duration(days: today.weekday - 4));
    DateTime friday = today.subtract(Duration(days: today.weekday - 5));
    DateTime saturday = today.subtract(Duration(days: today.weekday - 6));
    DateTime sunday =
        today.add(Duration(days: DateTime.daysPerWeek - today.weekday));

    TextStyle labelTextStyle(DateTime weekday) {
      return today == weekday
          ? TextStyle(
              fontFamily: 'Insanibu',
              fontSize: 17.5,
              color: Colors.white,
              shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: kPrimaryColor,
                  ),
                ])
          : TextStyle(
              fontFamily: 'Insanibu', fontSize: 16, color: Colors.grey[200]);
    }

    return Row(
      children: [
        Text('MON', style: labelTextStyle(monday)),
        SizedBox(
          width: 10,
        ),
        Text('TUE', style: labelTextStyle(tuesday)),
        SizedBox(
          width: 12,
        ),
        Text('WED', style: labelTextStyle(wednesday)),
        SizedBox(
          width: 11,
        ),
        Text('THU', style: labelTextStyle(thursday)),
        SizedBox(
          width: 17,
        ),
        Text('FRI', style: labelTextStyle(friday)),
        SizedBox(
          width: 18,
        ),
        Text('SAT', style: labelTextStyle(saturday)),
        SizedBox(
          width: 13,
        ),
        Text('SUN', style: labelTextStyle(sunday))
      ],
    );
  }

  Future dailyChallengeNotCompletedAlert() async {
    await _player.setVolume(0.8);
    await _player.setAsset('assets/audios/error.mp3');
    _player.play();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Column(
              children: [
                Image(
                  image: AssetImage('assets/images/cross.png'),
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('You have not completed the Daily Challenge yet !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'nunito',
                        fontSize: 21.5,
                        color: Colors.black54,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            elevation: 20.0,
          );
        });
  }

  Future dailyChallengeCompletedAlert() async {
    bool isLevelUp = false;
    _dailyChallengeChecked = true;
    await _player.setAsset('assets/audios/daily_challenge_complete.mp3');
    _player.play();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Daily Challenge Checked', _dailyChallengeChecked);
    int currentExperience = await prefs.getInt('currentExperience') ?? 0;
    int level = await prefs.getInt('level') ?? 1;
    int experienceUpperBound = getExpUpperBound(level);

    currentExperience++;
    await prefs.setInt('currentExperience', currentExperience);

    if (currentExperience == experienceUpperBound) {
      currentExperience = 0;
      level++;
      isLevelUp = true;

      await prefs.setInt('level', level);
      await prefs.setInt('currentExperience', currentExperience);

      Future.delayed(Duration(seconds: 1, milliseconds: 39))
          .whenComplete(() => {
                if (isLevelUp)
                  {
                    _player.setAsset('assets/audios/level_up.mp3'),
                    _player.play(),
                  }
              });
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: kPrimaryColor,
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text('Daily Challenge Completed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Experience Increased by 1!\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 19,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold)),
                  isLevelUp ? buildLevelPanel(level) : Container()
                ],
              ),
            ),
            elevation: 20.0,
          );
        });
  }
}
