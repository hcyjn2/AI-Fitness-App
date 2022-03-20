import 'package:fitness_app/services/workout/classification/best_record.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class ScoreboardScreen extends StatefulWidget {
  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  Map<String, int> records = {};
  late Future future;
  List<BestRecord> _bestRecordList = [];

  @override
  void initState() {
    super.initState();
    future = _getFuture();
  }

  Future _initSaveData() async {
    for (var classIdentifier in poseClasses)
      _bestRecordList.add(
          BestRecord(exerciseClass: classIdentifier, exerciseRepetition: 0));
  }

  Future _loadBestRecordData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var counter = await prefs.getInt('counter') ?? 0;

    if (counter < 1) _initSaveData();

    List<BestRecord> decodedData =
        BestRecord.decode(prefs.get('Best Record List').toString());

    return decodedData;
  }

  _getFuture() async {
    _bestRecordList = await _loadBestRecordData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.915,
      width: MediaQuery.of(context).size.width * 0.995,
      child: CustomCard(
          boxShadow: BoxShadow(
            color: kSecondaryColor.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
          color: kSecondaryColor.withOpacity(0.39),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
                child: Container(
                  child: Text(
                    '\u00b7 Scoreboard',
                    style: TextStyle(
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.5, 2.5),
                            blurRadius: 8.0,
                            color: Color.fromARGB(125, 106, 106, 106),
                          ),
                        ],
                        fontFamily: 'nunito',
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Container(
                child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        child: ListView.builder(
                          itemCount: _bestRecordList.length,
                          itemBuilder: (context, index) {
                            String className = classIdentifierToClassName(
                                _bestRecordList.elementAt(index).exerciseClass);
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
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: ListTile(
                                    title: Text(
                                      className,
                                      style: TextStyle(
                                          fontFamily: 'nunito',
                                          fontSize: 20,
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
                        height: MediaQuery.of(context).size.height * 0.65,
                        width: double.infinity,
                        color: Colors.transparent,
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
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Reset Scoreboard',
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
}
