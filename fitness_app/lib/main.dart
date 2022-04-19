import 'package:camera/camera.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:fitness_app/constants.dart';
import 'package:fitness_app/screens/achievement.dart';
import 'package:fitness_app/screens/scoreboard.dart';
import 'package:fitness_app/screens/main_menu.dart';
import 'package:fitness_app/screens/workout_calibration.dart';
import 'package:fitness_app/screens/workout_menu.dart';
import 'package:fitness_app/screens/workout_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showcaseview/showcaseview.dart';

// initialize variables
List<Widget> listWidgets = [
  WorkoutMenu(),
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
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    //Starting point of the app will be the WelcomeScreen. if user is logged in then the starting screen is MainMenuScreen().
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ShowCaseWidget(
          builder: Builder(
            builder: (context) => menuContent(),
          ),
        ),
        routes: {
          '/achievement': (context) => const Achievement(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/workoutcalibration') {
            return MaterialPageRoute(
              builder: (context) => WorkoutCalibration(
                (settings.arguments is PoseClass)
                    ? settings.arguments as PoseClass
                    : PoseClass.classSquat,
              ),
            );
          } else if (settings.name == '/workoutsession') {
            return MaterialPageRoute(
              builder: (context) => WorkoutSession(
                (settings.arguments is PoseClass)
                    ? settings.arguments as PoseClass
                    : PoseClass.classSquat,
              ),
            );
          }
        });
  }

  Widget menuContent() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: listWidgets[pageIndex],
        ),
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: kPrimaryColor.withOpacity(0.9),
          activeColor: kSecondaryColor.withOpacity(0.9),
          items: [
            TabItem(
              icon: Icon(
                FontAwesomeIcons.dumbbell,
                color: Colors.white,
              ),
            ),
            TabItem(
              icon: Icon(
                FontAwesomeIcons.chartSimple,
                color: Colors.white,
              ),
            ),
            TabItem(
              icon: Icon(
                FontAwesomeIcons.trophy,
                color: Colors.white,
              ),
            ),
          ],
          initialActiveIndex: pageIndex,
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
