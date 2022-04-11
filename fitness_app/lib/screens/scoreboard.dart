import 'package:fitness_app/screens/workout_menu.dart';
import 'package:fitness_app/services/workout/classification/best_record.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
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
  var scoreboardTutorial = true;

  Map<String, int> records = {};
  late Future future;
  List<BestRecord> _bestRecordList = [];
  int level = 1;
  int currentExperience = 0;
  int experienceUpperBound = 10;

  @override
  void initState() {
    super.initState();
    future = _getFuture();
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
                              child: WorkoutButton(
                                elevation: 5,
                                color: Colors.white.withOpacity(0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        selectedColor: kPrimaryColor,
                                        unselectedColor: Color(0xFF57524C),
                                        roundedEdges: Radius.circular(15),
                                      ),
                                    ],
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
                padding: const EdgeInsets.fromLTRB(25, 35, 0, 0),
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
                            key: _key1,
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
                              height: MediaQuery.of(context).size.height * 0.3,
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
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Align(
                    alignment: Alignment.bottomCenter,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                    fontFamily: 'nunito',
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ))),
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.clear();

                              future = _getFuture();
                              setState(() {});
                            }),
                      ],
                    )),
              ))
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
}
