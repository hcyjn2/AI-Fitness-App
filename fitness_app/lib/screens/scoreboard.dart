import 'package:fitness_app/screens/achievement.dart';
import 'package:fitness_app/services/workout/classification/best_record.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:fitness_app/widgets/workout_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../constants.dart';

class ScoreboardScreen extends StatefulWidget {
  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final _key1 = GlobalKey();
  final _key2 = GlobalKey();
  var scoreboardTutorial = true;

  Map<String, int> records = {};
  late Future future;
  List<BestRecord> _bestRecordList = [];

  int level = 1;
  int currentExperience = 0;
  int experienceUpperBound = getExpUpperBound(1);

  @override
  void initState() {
    super.initState();
    future = _getFuture();

    setState(() {});
  }

  Future _scoreboardTutorialOff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('scoreboardTutorial', scoreboardTutorial);
  }

  Future _initSaveData() async {
    for (var classIdentifier in poseClassesWithoutVariation)
      _bestRecordList.add(
          BestRecord(exerciseClass: classIdentifier, exerciseRepetition: 0));
  }

  Future _loadDataAndTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var counter = await prefs.getInt('counter') ?? 0;
    scoreboardTutorial = await prefs.getBool('scoreboardTutorial') ?? true;
    level = await prefs.getInt('level') ?? 1;
    currentExperience = await prefs.getInt('currentExperience') ?? 0;
    experienceUpperBound = getExpUpperBound(level);

    if (scoreboardTutorial) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => {
            ShowCaseWidget.of(context)!.startShowCase(
              [
                _key1,
                _key2,
              ],
            ),
            scoreboardTutorial = false,
            _scoreboardTutorialOff()
          });
    }

    if (counter < 1) _initSaveData();

    List<BestRecord> decodedData =
        BestRecord.decode(prefs.get('Best Record List').toString());

    return decodedData;
  }

  _getFuture() async {
    _bestRecordList = await _loadDataAndTutorial();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 0, 5),
                child: Container(
                  child: Text(
                    '\u00b7 Progress',
                    style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2, 1),
                          blurRadius: 8.0,
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
              Container(
                child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.195,
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 31.0),
                              child: Showcase(
                                overlayPadding: EdgeInsets.all(10),
                                key: _key1,
                                description:
                                    'This is the Level and EXP indicator. \n\nPress it to access Achievement page.',
                                shapeBorder: const RoundedRectangleBorder(),
                                contentPadding: EdgeInsets.all(20),
                                showcaseBackgroundColor: kPrimaryColor,
                                descTextStyle: TextStyle(
                                    fontFamily: 'nunito',
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                                child: WorkoutButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Achievement())).then((value) {
                                      future = _getFuture();
                                      setState(() {});
                                    });
                                  },
                                  elevation: 5,
                                  color: level == 1
                                      ? Color(0xFFF0FFF6).withOpacity(0.95)
                                      : level == 2
                                          ? Color(0xFFDDEEFF).withOpacity(0.95)
                                          : level == 3
                                              ? Color(0xFFDEDAFF)
                                                  .withOpacity(0.95)
                                              : level == 4
                                                  ? Color(0xFFFFE2DA)
                                                      .withOpacity(0.95)
                                                  : Color(0xFF262626)
                                                      .withOpacity(0.95),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: generateLevelBadge(level),
                                          height: 102,
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        StepProgressIndicator(
                                          totalSteps: experienceUpperBound,
                                          currentStep: currentExperience,
                                          size: 30,
                                          padding: 0,
                                          selectedGradientColor: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              kSecondaryColor,
                                              kAccentColor
                                            ],
                                          ),
                                          unselectedColor: Color(0xFF57524C),
                                          roundedEdges: Radius.circular(15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )));
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 55, 0, 0),
                child: Container(
                  child: Text(
                    '\u00b7 Scoreboard',
                    style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(2, 1),
                          blurRadius: 8.0,
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
              Container(
                child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        children: [
                          Showcase(
                            key: _key2,
                            description:
                                'This is the scoreboard which shows your High Score on each exercise.',
                            shapeBorder: const RoundedRectangleBorder(),
                            contentPadding: EdgeInsets.all(20),
                            showcaseBackgroundColor: kPrimaryColor,
                            descTextStyle: TextStyle(
                                fontFamily: 'nunito',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                            child: Container(
                              child: ListView.builder(
                                itemCount: _bestRecordList.length,
                                itemBuilder: (context, index) {
                                  String className = classIdentifierToClassName(
                                          _bestRecordList
                                              .elementAt(index)
                                              .exerciseClass)
                                      .toUpperCase();
                                  String classRepetition = _bestRecordList
                                      .elementAt(index)
                                      .exerciseRepetition
                                      .toString();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 20),
                                    child: Card(
                                      color: kPrimaryColor,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: ListTile(
                                          title: Text(
                                            className,
                                            style: TextStyle(
                                                fontFamily: 'nunito',
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900),
                                          ),
                                          trailing: Text(
                                            classRepetition,
                                            style: TextStyle(
                                                fontFamily: 'nunito',
                                                fontSize: 24,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              height: MediaQuery.of(context).size.height * 0.38,
                              width: double.infinity,
                              color: Colors.transparent,
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )));
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  AssetImage generateLevelBadge(int level) {
    if (level == 1) {
      return AssetImage(
        'assets/images/lv1.png',
      );
    } else if (level == 2) {
      return AssetImage(
        'assets/images/lv2.png',
      );
    } else if (level == 3) {
      return AssetImage(
        'assets/images/lv3.png',
      );
    } else if (level == 4) {
      return AssetImage(
        'assets/images/lv4.png',
      );
    } else if (level == 5) {
      return AssetImage(
        'assets/images/lv5.png',
      );
    } else {
      return AssetImage(
        'assets/images/lv1.png',
      );
    }
  }

  // For Testing
  Future testAlert(int Level) async {
    AudioPlayer _player = AudioPlayer();
    await _player.setAsset('assets/audios/level_up.mp3');
    _player.play();

    SharedPreferences prefs = await SharedPreferences.getInstance();

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

    ;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: kPrimaryColor,
            title: Padding(
              padding: const EdgeInsets.all(30.0),
              child: buildLevelPanel(Level),
            ),
            elevation: 20.0,
          );
        });
  }
}

// To test Level System
// Row(
//   children: [
//     Expanded(
//         child: Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: new Align(
//           alignment: Alignment.bottomCenter,
//           child: new Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextButton(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20.0),
//                     child: Text(
//                       'Reset',
//                       style: TextStyle(
//                           fontFamily: 'nunito',
//                           fontSize: 20,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   style: ButtonStyle(
//                       backgroundColor:
//                           MaterialStateProperty.all<Color>(
//                               Colors.grey),
//                       shape: MaterialStateProperty.all<
//                               RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ))),
//                   onPressed: () async {
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     prefs.clear();
//
//                     future = _getFuture();
//                     setState(() {});
//                   }),
//             ],
//           )),
//     )),
//     Expanded(
//         child: Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: new Align(
//           alignment: Alignment.bottomCenter,
//           child: new Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextButton(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20.0),
//                     child: Text(
//                       'EXP ++',
//                       style: TextStyle(
//                           fontFamily: 'nunito',
//                           fontSize: 20,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   style: ButtonStyle(
//                       backgroundColor:
//                           MaterialStateProperty.all<Color>(
//                               Colors.grey),
//                       shape: MaterialStateProperty.all<
//                               RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ))),
//                   onPressed: () async {
//                     bool isLevelUp = false;
//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//
//                     currentExperience++;
//                     if (currentExperience ==
//                         experienceUpperBound) {
//                       currentExperience = 0;
//                       level++;
//                       isLevelUp = true;
//
//                       if (isLevelUp) {
//                         testAlert(level);
//                       }
//                     }
//                     await prefs.setInt('level', level);
//                     await prefs.setInt(
//                         'currentExperience', currentExperience);
//
//                     future = _getFuture();
//                     setState(() {});
//                   }),
//             ],
//           )),
//     ))
//   ],
// )
