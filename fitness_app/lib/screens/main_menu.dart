// import 'package:charts_painter/chart.dart';
// import 'package:fitness_app/constants.dart';
// import 'package:fitness_app/screens/workout_menu.dart';
// import 'package:fitness_app/services/workout/classification/workout_record.dart';
// import 'package:fitness_app/widgets/custom_card.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Dashboard feature
// class MainMenu extends StatefulWidget {
//   @override
//   _MainMenuState createState() => _MainMenuState();
// }
//
// class _MainMenuState extends State<MainMenu> {
//   late Future future;
//   late String _lastWorkoutClass;
//   late int _lastWorkoutCount;
//   late int _totalWorkoutDone;
//   List<WorkoutRecord> _workoutRecordList = [];
//   List<double> _weeklyActivityChartData = [
//     0.05,
//     0.05,
//     0.05,
//     0.05,
//     0.05,
//     0.05,
//     0.05
//   ];
//   late bool _appTutorial;
//   DateTime today =
//       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//
//   @override
//   void initState() {
//     super.initState();
//     _initData();
//     future = _getFuture();
//   }
//
//   Future _loadWorkoutRecordData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     List<WorkoutRecord> decodedData =
//         WorkoutRecord.decode(prefs.get('Workout Record List').toString());
//
//     if (decodedData.isNotEmpty)
//       return decodedData;
//     else
//       return [];
//   }
//
//   Future _initData() async {
//     List<WorkoutRecord> decodedData = await _loadWorkoutRecordData();
//
//     if (decodedData.isEmpty) return;
//
//     Map<DateTime, double> _weeklyActivityCount = {};
//     DateTime monday = today.subtract(Duration(days: today.weekday - 1));
//     DateTime tuesday = today.subtract(Duration(days: today.weekday - 2));
//     DateTime wednesday = today.subtract(Duration(days: today.weekday - 3));
//     DateTime thursday = today.subtract(Duration(days: today.weekday - 4));
//     DateTime friday = today.subtract(Duration(days: today.weekday - 5));
//     DateTime saturday = today.subtract(Duration(days: today.weekday - 6));
//     DateTime sunday =
//         today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
//
//     if (decodedData.isNotEmpty) {
//       for (var record in decodedData) {
//         if (!_weeklyActivityCount.containsKey(record.dateTime))
//           _weeklyActivityCount.addAll({record.dateTime: 1.0});
//         else
//           _weeklyActivityCount.update(
//               record.dateTime, (value) => value = value + 1.0);
//       }
//
//       _weeklyActivityCount.forEach((key, value) {
//         if (key == monday)
//           _weeklyActivityChartData[0] = value;
//         else if (key == tuesday)
//           _weeklyActivityChartData[1] = value;
//         else if (key == wednesday)
//           _weeklyActivityChartData[2] = value;
//         else if (key == thursday)
//           _weeklyActivityChartData[3] = value;
//         else if (key == friday)
//           _weeklyActivityChartData[4] = value;
//         else if (key == saturday)
//           _weeklyActivityChartData[5] = value;
//         else if (key == sunday) _weeklyActivityChartData[6] = value;
//       });
//     }
//   }
//
//   RichText workoutStartMessage = new RichText(
//     textAlign: TextAlign.center,
//     text: new TextSpan(
//       // Note: Styles for TextSpans must be explicitly defined.
//       // Child text spans will inherit styles from parent
//       style: new TextStyle(
//         fontSize: 14.0,
//         color: Colors.black,
//       ),
//       children: <TextSpan>[
//         new TextSpan(
//             text: 'Please make sure your surrounding is ',
//             style:
//                 workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
//         new TextSpan(text: 'Well-Lit', style: workoutStartMessageStyle),
//         new TextSpan(
//             text: ' & have ',
//             style:
//                 workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
//         new TextSpan(
//             text: 'Ample Physical Space', style: workoutStartMessageStyle),
//         new TextSpan(
//             text: ' for this feature.\n\nDo you wish to start now?',
//             style:
//                 workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
//       ],
//     ),
//   );
//
//   Future buildSquatDemo() {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 0),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             title: Text(
//               'Squat Demonstration',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontFamily: 'nunito',
//                   fontSize: 23,
//                   fontWeight: FontWeight.w900,
//                   color: kPrimaryColor),
//             ),
//             content: Container(
//               height: 600,
//               width: 320,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Container(
//                     child: Column(children: [
//                       Image(
//                         image: AssetImage('assets/images/squat.gif'),
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         'Tips',
//                         style: TextStyle(
//                             fontFamily: 'nunito',
//                             decoration: TextDecoration.underline,
//                             decorationThickness: 3,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w900,
//                             color: kPrimaryColor),
//                         textAlign: TextAlign.center,
//                       ),
//                       Text(
//                           '\u00b7 Hip should be on the same level / lower than your knees.',
//                           style: TextStyle(
//                               fontFamily: 'nunito',
//                               fontSize: 15,
//                               fontWeight: FontWeight.w900,
//                               color: kPrimaryColor))
//                     ]),
//                   ),
//                   Container(
//                       child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
//                     child: MaterialButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       elevation: 5,
//                       color: kPrimaryColor,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 8),
//                         child: Text('Next',
//                             style: TextStyle(
//                                 fontFamily: 'nunito',
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white)),
//                       ),
//                       onPressed: () async {
//                         setState(() {
//                           //NO Action
//                           Navigator.pop(context);
//                           buildConfirmationAlert(PoseClass.classSquat);
//                         });
//                       },
//                     ),
//                   ))
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   Future buildPushUpDemo() {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 0),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             title: Text(
//               'Push Up Demonstration',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontFamily: 'nunito',
//                   fontSize: 23,
//                   fontWeight: FontWeight.w900,
//                   color: kPrimaryColor),
//             ),
//             content: Container(
//               height: 600,
//               width: 320,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 90,
//                   ),
//                   Container(
//                     child: Column(children: [
//                       Image(
//                         image: AssetImage('assets/images/pushup.gif'),
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         'Tips',
//                         style: TextStyle(
//                             fontFamily: 'nunito',
//                             decoration: TextDecoration.underline,
//                             decorationThickness: 3,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w900,
//                             color: kPrimaryColor),
//                         textAlign: TextAlign.center,
//                       ),
//                       Text(
//                           '\u00b7 Hip and Back should be Straight instead of Slouching. \n \u00b7 Chest should touch or almost touch the ground.',
//                           style: TextStyle(
//                               fontFamily: 'nunito',
//                               fontSize: 15,
//                               fontWeight: FontWeight.w900,
//                               color: kPrimaryColor))
//                     ]),
//                   ),
//                   Container(
//                       child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
//                     child: MaterialButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       elevation: 5,
//                       color: kPrimaryColor,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 8),
//                         child: Text('Next',
//                             style: TextStyle(
//                                 fontFamily: 'nunito',
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white)),
//                       ),
//                       onPressed: () async {
//                         setState(() {
//                           //NO Action
//                           Navigator.pop(context);
//                           buildConfirmationAlert(PoseClass.classPushUp);
//                         });
//                       },
//                     ),
//                   ))
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   Future buildJumpingJackDemo() {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 0),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             title: Text(
//               'Jumping Jack Demonstration',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontFamily: 'nunito',
//                   fontSize: 23,
//                   fontWeight: FontWeight.w900,
//                   color: kPrimaryColor),
//             ),
//             content: Container(
//               height: 600,
//               width: 320,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Container(
//                     child: Column(children: [
//                       Image(
//                         image: AssetImage('assets/images/jumpingJack.gif'),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Text(
//                         'Tips',
//                         style: TextStyle(
//                             fontFamily: 'nunito',
//                             decoration: TextDecoration.underline,
//                             decorationThickness: 3,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w900,
//                             color: kPrimaryColor),
//                         textAlign: TextAlign.center,
//                       ),
//                       Text(
//                           '\u00b7 Raise your arms above your head, keeping elbows straight. \n \u00b7 Feet wider than your shoulders.',
//                           style: TextStyle(
//                               fontFamily: 'nunito',
//                               fontSize: 15,
//                               fontWeight: FontWeight.w900,
//                               color: kPrimaryColor))
//                     ]),
//                   ),
//                   Container(
//                       child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
//                     child: MaterialButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       elevation: 5,
//                       color: kPrimaryColor,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 8),
//                         child: Text('Next',
//                             style: TextStyle(
//                                 fontFamily: 'nunito',
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white)),
//                       ),
//                       onPressed: () async {
//                         setState(() {
//                           //NO Action
//                           Navigator.pop(context);
//                           buildConfirmationAlert(PoseClass.classSquat);
//                         });
//                       },
//                     ),
//                   ))
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   Future buildConfirmationAlert(PoseClass poseClass) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: workoutStartMessage,
//             content: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 MaterialButton(
//                   elevation: 5.0,
//                   color: Colors.grey,
//                   child: Text('NO',
//                       style: TextStyle(
//                           fontFamily: 'nunito',
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold)),
//                   onPressed: () async {
//                     setState(() {
//                       //NO Action
//                       Navigator.pop(context);
//                     });
//                   },
//                 ),
//                 SizedBox(width: 30),
//                 MaterialButton(
//                   elevation: 5.0,
//                   color: kPrimaryColor,
//                   child: Text('YES',
//                       style: TextStyle(
//                           fontFamily: 'nunito',
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold)),
//                   onPressed: () async {
//                     setState(() {
//                       //NO Action
//                       Navigator.pop(context);
//                       Navigator.pushNamed(
//                         context,
//                         '/workoutcalibration',
//                         arguments: poseClass,
//                       );
//                     });
//                   },
//                 ),
//               ],
//             ),
//           );
//         });
//   }
//
//   Future _getFuture() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _lastWorkoutClass = prefs.getString('Last Workout Class') ?? 'None';
//     _lastWorkoutCount = prefs.getInt('Last Workout Count') ?? 0;
//     _totalWorkoutDone = prefs.getInt('Total Workout Done') ?? 0;
//     _appTutorial = (await prefs.getBool('App Tutorial')) ?? true;
//
//     buildAppTutorial();
//
//     // if (_appTutorial) {
//     //   buildAppTutorial();
//     //   _appTutorial = false;
//     //   prefs.setBool('App Tutorial', _appTutorial);
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.915,
//       width: MediaQuery.of(context).size.width * 0.995,
//       child: CustomCard(
//         boxShadow: BoxShadow(
//           color: kAccentColor.withOpacity(0.3),
//           spreadRadius: 10,
//           blurRadius: 7,
//           offset: Offset(0, 1), // changes position of shadow
//         ),
//         color: kSecondaryColor.withOpacity(0.39),
//         child: FutureBuilder(
//           future: future,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
//                       child: Container(
//                         child: Text(
//                           '\u00b7 Dashboard',
//                           style: TextStyle(
//                             shadows: <Shadow>[
//                               Shadow(
//                                 offset: Offset(2, 1),
//                                 blurRadius: 8,
//                                 color: Color.fromARGB(125, 106, 106, 106),
//                               ),
//                             ],
//                             fontFamily: 'Insanibu',
//                             fontSize: 41,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
//                       child: WorkoutButton(
//                         elevation: 5,
//                         color: Colors.white.withOpacity(0.95),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * 0.15,
//                           width: MediaQuery.of(context).size.width * 0.75,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 5),
//                             child: Text('Daily Challenge',
//                                 style: TextStyle(
//                                     color: Colors.black45,
//                                     fontFamily: 'nunito',
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w900)),
//                           ),
//                         ),
//                       )),
//                   Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
//                         child: WorkoutButton(
//                           elevation: 5,
//                           color: Colors.white.withOpacity(0.95),
//                           child: Container(
//                             height: MediaQuery.of(context).size.height * 0.20,
//                             width: MediaQuery.of(context).size.width * 0.315,
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(0, 10, 0, 18),
//                                   child: Text('Last Workout',
//                                       style: TextStyle(
//                                           color: Colors.black45,
//                                           height: 1.25,
//                                           fontFamily: 'nunito',
//                                           fontSize: 23,
//                                           fontWeight: FontWeight.w900)),
//                                 ),
//                                 Text(_lastWorkoutClass.toString(),
//                                     style: TextStyle(
//                                         color: kPrimaryColor,
//                                         fontFamily: 'nunito',
//                                         fontSize: 18.5,
//                                         fontWeight: FontWeight.w900)),
//                                 Text(_lastWorkoutCount.toString() + ' reps',
//                                     style: TextStyle(
//                                         color: kPrimaryColor,
//                                         fontFamily: 'nunito',
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w900)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
//                         child: WorkoutButton(
//                           elevation: 5,
//                           color: Colors.white.withOpacity(0.95),
//                           child: Container(
//                             height: MediaQuery.of(context).size.height * 0.20,
//                             width: MediaQuery.of(context).size.width * 0.315,
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(0, 10, 0, 15),
//                                   child: Text('Workouts Done',
//                                       style: TextStyle(
//                                           color: Colors.black45,
//                                           height: 1.25,
//                                           fontFamily: 'nunito',
//                                           fontSize: 23,
//                                           fontWeight: FontWeight.w900)),
//                                 ),
//                                 Text(_totalWorkoutDone.toString(),
//                                     style: TextStyle(
//                                         color: kPrimaryColor,
//                                         fontFamily: 'nunito',
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w900)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
//                     child: WorkoutButton(
//                       elevation: 5,
//                       color: Colors.white.withOpacity(0.95),
//                       child: Container(
//                         height: MediaQuery.of(context).size.height * 0.33,
//                         width: MediaQuery.of(context).size.width * 0.75,
//                         child: Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 5),
//                               child: Text('Weekly Activity',
//                                   style: TextStyle(
//                                       color: Colors.black45,
//                                       fontFamily: 'nunito',
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w900)),
//                             ),
//                             Chart<void>(
//                               state: ChartState(
//                                 ChartData.fromList(
//                                   _weeklyActivityChartData
//                                       .map((e) => BarValue<void>(e.toDouble()))
//                                       .toList(),
//                                   axisMax: 8.0,
//                                 ),
//                                 behaviour:
//                                     ChartBehaviour(onItemClicked: (value) {}),
//                                 itemOptions: BarItemOptions(
//                                   color: kPrimaryColor,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 3.9),
//                                   radius: BorderRadius.vertical(
//                                       top: Radius.circular(30.0)),
//                                 ),
//                                 backgroundDecorations: [],
//                                 foregroundDecorations: [
//                                   ValueDecoration(
//                                       textStyle: TextStyle(
//                                     fontSize: 15,
//                                     color: Colors.black26,
//                                     fontFamily: 'Insanibu',
//                                   ))
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                       padding: const EdgeInsets.fromLTRB(39, 5, 0, 0),
//                       child: weeklyActivityChartLabel())
//                 ],
//               );
//             } else {
//               return Container(
//                   child: Center(
//                       child: Text(
//                 'Loading...',
//                 style: TextStyle(
//                     fontFamily: 'nunito',
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold),
//               )));
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Future buildAppTutorial() async {
//     return showDialog(
//         barrierColor: Colors.black45.withOpacity(0.65),
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             backgroundColor: kPrimaryColor,
//             contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             content: Container(
//               height: 600,
//               width: 450,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Container(
//                     child: Column(children: [
//                       Text(
//                         'Hello!',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontFamily: 'Insanibu',
//                             fontSize: 42,
//                             color: Colors.white),
//                       ),
//                       SizedBox(
//                         height: 30,
//                       ),
//                       Text(
//                         'This must be your first time using the app. \n\n No Worries, Let\'s get into it.  :)',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontFamily: 'nunito',
//                             fontWeight: FontWeight.w900,
//                             fontSize: 30,
//                             color: Colors.white),
//                       ),
//                       SizedBox(
//                         height: 50,
//                       ),
//                     ]),
//                   ),
//                   Container(
//                       child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
//                     child: MaterialButton(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       elevation: 5,
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 5, vertical: 1),
//                         child: Text(' ➜ ',
//                             style: TextStyle(
//                                 fontFamily: 'nunito',
//                                 fontSize: 36,
//                                 fontWeight: FontWeight.w900,
//                                 color: kPrimaryColor)),
//                       ),
//                       onPressed: () async {
//                         Navigator.pop(context);
//                         setState(() {});
//                       },
//                     ),
//                   )),
//                   SizedBox(
//                     height: 50,
//                   ),
//                   Row(
//                     children: [
//                       SizedBox(
//                         width: 233,
//                       ),
//                       Container(
//                           width: 70,
//                           height: 35,
//                           child: MaterialButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15)),
//                             elevation: 5,
//                             color: Colors.grey.withOpacity(0.8),
//                             child: Text('SKIP',
//                                 style: TextStyle(
//                                     fontFamily: 'nunito',
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w900,
//                                     color: Colors.white.withOpacity(0.8))),
//                             onPressed: () async {
//                               Navigator.pop(context);
//                               setState(() {});
//                             },
//                           )),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   Widget weeklyActivityChartLabel() {
//     DateTime monday = today.subtract(Duration(days: today.weekday - 1));
//     DateTime tuesday = today.subtract(Duration(days: today.weekday - 2));
//     DateTime wednesday = today.subtract(Duration(days: today.weekday - 3));
//     DateTime thursday = today.subtract(Duration(days: today.weekday - 4));
//     DateTime friday = today.subtract(Duration(days: today.weekday - 5));
//     DateTime saturday = today.subtract(Duration(days: today.weekday - 6));
//     DateTime sunday =
//         today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
//
//     TextStyle labelTextStyle(DateTime weekday) {
//       return today == weekday
//           ? TextStyle(
//               fontFamily: 'Insanibu',
//               fontSize: 17.5,
//               color: Colors.white,
//               shadows: [
//                   Shadow(
//                     offset: Offset(0, 1),
//                     blurRadius: 3,
//                     color: kPrimaryColor,
//                   ),
//                 ])
//           : TextStyle(
//               fontFamily: 'Insanibu', fontSize: 16, color: Colors.grey[200]);
//     }
//
//     return Row(
//       children: [
//         Text('MON', style: labelTextStyle(monday)),
//         SizedBox(
//           width: 10,
//         ),
//         Text('TUE', style: labelTextStyle(tuesday)),
//         SizedBox(
//           width: 12,
//         ),
//         Text('WED', style: labelTextStyle(wednesday)),
//         SizedBox(
//           width: 11,
//         ),
//         Text('THU', style: labelTextStyle(thursday)),
//         SizedBox(
//           width: 17,
//         ),
//         Text('FRI', style: labelTextStyle(friday)),
//         SizedBox(
//           width: 18,
//         ),
//         Text('SAT', style: labelTextStyle(saturday)),
//         SizedBox(
//           width: 13,
//         ),
//         Text('SUN', style: labelTextStyle(sunday))
//       ],
//     );
//   }
// }

import 'package:charts_painter/chart.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/screens/workout_menu.dart';
import 'package:fitness_app/services/workout/classification/workout_record.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

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

  late Future future;
  late String _lastWorkoutClass;
  late int _lastWorkoutCount;
  late int _totalWorkoutDone;
  List<WorkoutRecord> _workoutRecordList = [];
  List<double> _weeklyActivityChartData = [
    0.05,
    0.05,
    0.05,
    0.05,
    0.05,
    0.05,
    0.05
  ];
  late bool _appTutorial = true;
  late bool showcaseStart;
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

  RichText workoutStartMessage = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
      // Note: Styles for TextSpans must be explicitly defined.
      // Child text spans will inherit styles from parent
      style: new TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        new TextSpan(
            text: 'Please make sure your surrounding is ',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
        new TextSpan(text: 'Well-Lit', style: workoutStartMessageStyle),
        new TextSpan(
            text: ' & have ',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
        new TextSpan(
            text: 'Ample Physical Space', style: workoutStartMessageStyle),
        new TextSpan(
            text: ' for this feature.\n\nDo you wish to start now?',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Future buildSquatDemo() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              'Squat Demonstration',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: kPrimaryColor),
            ),
            content: Container(
              height: 600,
              width: 320,
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Column(children: [
                      Image(
                        image: AssetImage('assets/images/squat.gif'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Tips',
                        style: TextStyle(
                            fontFamily: 'nunito',
                            decoration: TextDecoration.underline,
                            decorationThickness: 3,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                          '\u00b7 Hip should be on the same level / lower than your knees.',
                          style: TextStyle(
                              fontFamily: 'nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: kPrimaryColor))
                    ]),
                  ),
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      color: kPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('Next',
                            style: TextStyle(
                                fontFamily: 'nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      onPressed: () async {
                        setState(() {
                          //NO Action
                          Navigator.pop(context);
                          buildConfirmationAlert(PoseClass.classSquat);
                        });
                      },
                    ),
                  ))
                ],
              ),
            ),
          );
        });
  }

  Future buildPushUpDemo() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              'Push Up Demonstration',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: kPrimaryColor),
            ),
            content: Container(
              height: 600,
              width: 320,
              child: Column(
                children: [
                  SizedBox(
                    height: 90,
                  ),
                  Container(
                    child: Column(children: [
                      Image(
                        image: AssetImage('assets/images/pushup.gif'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Tips',
                        style: TextStyle(
                            fontFamily: 'nunito',
                            decoration: TextDecoration.underline,
                            decorationThickness: 3,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                          '\u00b7 Hip and Back should be Straight instead of Slouching. \n \u00b7 Chest should touch or almost touch the ground.',
                          style: TextStyle(
                              fontFamily: 'nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: kPrimaryColor))
                    ]),
                  ),
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      color: kPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('Next',
                            style: TextStyle(
                                fontFamily: 'nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      onPressed: () async {
                        setState(() {
                          //NO Action
                          Navigator.pop(context);
                          buildConfirmationAlert(PoseClass.classPushUp);
                        });
                      },
                    ),
                  ))
                ],
              ),
            ),
          );
        });
  }

  Future buildJumpingJackDemo() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 10, 24, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              'Jumping Jack Demonstration',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: kPrimaryColor),
            ),
            content: Container(
              height: 600,
              width: 320,
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Column(children: [
                      Image(
                        image: AssetImage('assets/images/jumpingJack.gif'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Tips',
                        style: TextStyle(
                            fontFamily: 'nunito',
                            decoration: TextDecoration.underline,
                            decorationThickness: 3,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kPrimaryColor),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                          '\u00b7 Raise your arms above your head, keeping elbows straight. \n \u00b7 Feet wider than your shoulders.',
                          style: TextStyle(
                              fontFamily: 'nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: kPrimaryColor))
                    ]),
                  ),
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      color: kPrimaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Text('Next',
                            style: TextStyle(
                                fontFamily: 'nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      onPressed: () async {
                        setState(() {
                          //NO Action
                          Navigator.pop(context);
                          buildConfirmationAlert(PoseClass.classSquat);
                        });
                      },
                    ),
                  ))
                ],
              ),
            ),
          );
        });
  }

  Future buildConfirmationAlert(PoseClass poseClass) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: workoutStartMessage,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  elevation: 5.0,
                  color: Colors.grey,
                  child: Text('NO',
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    setState(() {
                      //NO Action
                      Navigator.pop(context);
                    });
                  },
                ),
                SizedBox(width: 30),
                MaterialButton(
                  elevation: 5.0,
                  color: kPrimaryColor,
                  child: Text('YES',
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    setState(() {
                      //NO Action
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/workoutcalibration',
                        arguments: poseClass,
                      );
                    });
                  },
                ),
              ],
            ),
          );
        });
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
                      padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
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
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text('Daily Challenge',
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontFamily: 'nunito',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ),
                      )),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                        child: Showcase(
                          key: _key2,
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
                              height: MediaQuery.of(context).size.height * 0.20,
                              width: MediaQuery.of(context).size.width * 0.315,
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 18),
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
                          key: _key3,
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
                              height: MediaQuery.of(context).size.height * 0.20,
                              width: MediaQuery.of(context).size.width * 0.315,
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 15),
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
                    key: _key4,
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
                              height: MediaQuery.of(context).size.height * 0.33,
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
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
                                        axisMax: 8.0,
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
                        height: 30,
                      ),
                      Text(
                        'This must be your first time using the app. \n\n No Worries, Let\'s get into it.  :)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 50,
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

  _displayDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        var counter = 0;
        var pageIndex = 0;
        return SafeArea(
            child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Text(''),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          bottomNavigationBar: ConvexAppBar(
            initialActiveIndex: pageIndex,
            backgroundColor: kPrimaryColor.withOpacity(0.9),
            activeColor: kSecondaryColor.withOpacity(0.9),
            items: [
              TabItem(
                icon: Showcase(
                  key: _key1,
                  description: 'Workout',
                  shapeBorder: const RoundedRectangleBorder(),
                  overlayPadding: EdgeInsets.all(8),
                  contentPadding: EdgeInsets.all(20),
                  showcaseBackgroundColor: kPrimaryColor,
                  descTextStyle: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                  child: Icon(
                    FontAwesomeIcons.dumbbell,
                    color: Colors.white,
                  ),
                ),
              ),
              TabItem(
                icon: Showcase(
                  key: _key2,
                  description: 'Dashboard',
                  shapeBorder: const RoundedRectangleBorder(),
                  overlayPadding: EdgeInsets.all(8),
                  contentPadding: EdgeInsets.all(20),
                  showcaseBackgroundColor: kPrimaryColor,
                  descTextStyle: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                  child: Icon(
                    FontAwesomeIcons.home,
                    color: Colors.white,
                  ),
                ),
              ),
              TabItem(
                icon: Showcase(
                  key: _key3,
                  description: 'Scoreboard',
                  shapeBorder: const RoundedRectangleBorder(),
                  overlayPadding: EdgeInsets.all(8),
                  contentPadding: EdgeInsets.all(20),
                  showcaseBackgroundColor: kPrimaryColor,
                  descTextStyle: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                  child: Icon(
                    FontAwesomeIcons.trophy,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            onTap: (int i) {
              setState(() {
                pageIndex = i;
                counter++;
                if (counter >= 2) Navigator.pop(context);
              });
            },
          ),
        ));
      },
    );
  }
}
