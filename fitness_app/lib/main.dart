import 'package:camera/camera.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/screens/scoreboard.dart';
import 'package:fitness_app/screens/main_menu.dart';
import 'package:fitness_app/screens/workout.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// initialize variables
List<Widget> listWidgets = [
  WorkoutScreen(),
  MainMenu(),
  ScoreboardScreen(),
];

int pageIndex = 1;

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    //Starting point of the app will be the WelcomeScreen. if user is logged in then the starting screen is MainMenuScreen().
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: listWidgets[pageIndex],
        ),
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: kPrimaryColor,
          activeColor: kSecondaryColor,
          items: [
            TabItem(
              icon: Icon(
                FontAwesomeIcons.dumbbell,
                color: Colors.white,
              ),
            ),
            TabItem(
              icon: Icon(
                FontAwesomeIcons.home,
                color: Colors.white,
              ),
            ),
            TabItem(
              icon: Icon(
                FontAwesomeIcons.chartBar,
                color: Colors.white,
              ),
            ),
          ],
          initialActiveIndex: pageIndex, //optional, default as 0
          onTap: (int i) {
            setState(() {
              pageIndex = i;
            });
          },
        ),
      ),
    );
  }
}
