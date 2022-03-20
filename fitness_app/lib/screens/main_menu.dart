import 'package:charts_painter/chart.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/screens/workout_menu.dart';
import 'package:fitness_app/services/workout/classification/workout_record.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

// Dashboard feature
class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late Future future;
  late String _lastWorkoutClass;
  late int _lastWorkoutCount;
  late int _totalWorkoutDone;
  List<WorkoutRecord> _workoutRecordList = [];
  Map<DateTime, int> _weeklyActivityCount = {};
  List<int> _weeklyActivityChartData = [0, 0, 0, 0, 0, 0, 0];
  List<DateTime> _weeklyActivityChartDataTimeStamp = [];

  @override
  void initState() {
    super.initState();
    future = _getFuture();
  }

  // Future _loadWorkoutRecordData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   List<WorkoutRecord> decodedData =
  //       WorkoutRecord.decode(prefs.get('Workout Record List').toString());
  //
  //   return decodedData;
  // }

  calculateWeeklyActivity(List<WorkoutRecord> workoutRecordList) {
    for (var i = 0; i < workoutRecordList.length; i += 1) {
      var counter = 0;
      if (!_weeklyActivityCount.containsKey(workoutRecordList[i].dateTime)) {
        for (var j = 0; i < workoutRecordList.length; j += 1) {
          if (workoutRecordList[i].dateTime == workoutRecordList[j].dateTime)
            counter += 1;
        }

        _weeklyActivityCount.addAll({workoutRecordList[i].dateTime: counter});
        print(_weeklyActivityCount);
      }
    }

    var temp1 = _weeklyActivityCount.values.toList();
    var temp2 = _weeklyActivityCount.keys.toList();

    if (temp2[-1].year == DateTime.now().year &&
        temp2[-1].month == DateTime.now().month &&
        temp2[-1].day == DateTime.now().day) {
      _weeklyActivityChartData[-1] = temp1[-1];
    }
    if (temp2[-2].year == DateTime.now().year &&
        temp2[-2].month == DateTime.now().month &&
        (temp2[-2].day - temp2[-1].day) <= 1) {
      _weeklyActivityChartData[-2] = temp1[-2];
    }
    if (temp2[-3].year == DateTime.now().year &&
        temp2[-3].month == DateTime.now().month &&
        (temp2[-3].day - temp2[-2].day) <= 1) {
      _weeklyActivityChartData[-3] = temp1[-3];
    }
    if (temp2[-4].year == DateTime.now().year &&
        temp2[-4].month == DateTime.now().month &&
        (temp2[-4].day - temp2[-3].day) <= 1) {
      _weeklyActivityChartData[-4] = temp1[-4];
    }
    if (temp2[-5].year == DateTime.now().year &&
        temp2[-5].month == DateTime.now().month &&
        (temp2[-5].day - temp2[-4].day) <= 1) {
      _weeklyActivityChartData[-5] = temp1[-5];
    }
    if (temp2[-6].year == DateTime.now().year &&
        temp2[-6].month == DateTime.now().month &&
        (temp2[-6].day - temp2[-5].day) <= 1) {
      _weeklyActivityChartData[-6] = temp1[-6];
    }
    if (temp2[-7].year == DateTime.now().year &&
        temp2[-7].month == DateTime.now().month &&
        (temp2[-7].day - temp2[-7].day) <= 1) {
      _weeklyActivityChartData[-7] = temp1[-7];
    }
  }

  Future _getFuture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _lastWorkoutClass = prefs.getString('Last Workout Class') ?? 'None';
    _lastWorkoutCount = prefs.getInt('Last Workout Count') ?? 0;
    _totalWorkoutDone = prefs.getInt('Total Workout Done') ?? 0;

    _workoutRecordList =
        WorkoutRecord.decode(prefs.get('Workout Record List').toString());
    calculateWeeklyActivity(_workoutRecordList);
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
                      padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
                      child: Container(
                        child: Text(
                          '\u00b7 Dashboard',
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
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
                      child: WorkoutButton(
                        elevation: 5,
                        color: Colors.white.withOpacity(0.95),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.15,
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text('Daily Challenge',
                                style: TextStyle(
                                    fontFamily: 'nunito',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      )),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                        child: WorkoutButton(
                          elevation: 5,
                          color: Colors.white.withOpacity(0.95),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.20,
                            width: MediaQuery.of(context).size.width * 0.315,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 18),
                                  child: Text('Last Workout',
                                      style: TextStyle(
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                        child: WorkoutButton(
                          elevation: 5,
                          color: Colors.white.withOpacity(0.95),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.20,
                            width: MediaQuery.of(context).size.width * 0.315,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  child: Text('Workouts Done',
                                      style: TextStyle(
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 0, 0),
                    child: WorkoutButton(
                      elevation: 5,
                      color: Colors.white.withOpacity(0.95),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.33,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text('Weekly Activity',
                                  style: TextStyle(
                                      fontFamily: 'nunito',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900)),
                            ),
                            Chart<void>(
                              state: ChartState(
                                ChartData.fromList(
                                  _weeklyActivityChartData
                                      .map((e) => BarValue<void>(e.toDouble()))
                                      .toList(),
                                  axisMax: 8.0,
                                ),
                                behaviour:
                                    ChartBehaviour(onItemClicked: (value) {
                                  print(value);
                                }),
                                itemOptions: BarItemOptions(
                                  color: kPrimaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.9),
                                  radius: BorderRadius.vertical(
                                      top: Radius.circular(30.0)),
                                ),
                                backgroundDecorations: [],
                                foregroundDecorations: [],
                              ),
                            ),
                          ],
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
    );
  }
}
