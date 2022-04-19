import 'package:fitness_app/screens/settings.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:fitness_app/widgets/custom_elevated_button.dart';
import 'package:fitness_app/widgets/workout_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants.dart';

// Workout feature
class WorkoutMenu extends StatefulWidget {
  @override
  _WorkoutMenuState createState() => _WorkoutMenuState();
}

class _WorkoutMenuState extends State<WorkoutMenu> {
  final _key1 = GlobalKey();
  final _key2 = GlobalKey();
  final _key3 = GlobalKey();
  final _key4 = GlobalKey();
  final _key5 = GlobalKey();

  var workoutMenuTutorial = true;
  late Future future;

  Future _workoutMenuTutorialOff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('workoutMenuTutorial', workoutMenuTutorial);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = getFuture();
  }

  Future getFuture() async {
    await _loadTutorial();
  }

  Future _loadTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    workoutMenuTutorial = await prefs.getBool('workoutMenuTutorial') ?? true;

    if (workoutMenuTutorial) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => {
            ShowCaseWidget.of(context)!.startShowCase(
              [_key1, _key2, _key3, _key4, _key5],
            ),
            workoutMenuTutorial = false,
            _workoutMenuTutorialOff()
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.915,
              width: MediaQuery.of(context).size.width * 0.995,
              child: Showcase(
                overlayPadding: EdgeInsets.fromLTRB(-10, -10, -10, -200),
                key: _key1,
                description:
                    'You can select different exercises from this menu.',
                shapeBorder: const RoundedRectangleBorder(),
                contentPadding: EdgeInsets.all(20),
                showcaseBackgroundColor: kPrimaryColor,
                descTextStyle: TextStyle(
                    fontFamily: 'nunito',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
                child: CustomCard(
                  boxShadow: BoxShadow(
                    color: kAccentColor.withOpacity(0.3),
                    spreadRadius: 10,
                    blurRadius: 7,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                  color: kSecondaryColor.withOpacity(0.39),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                '\u00b7 Workout',
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
                            SizedBox(
                              width: 51,
                            ),
                            Container(
                              height: 33.9,
                              width: 50,
                              child: Showcase(
                                key: _key5,
                                description:
                                    'This navigates you to the Setting Page, where you can Turn Off/On Narration during Workout.',
                                shapeBorder: const RoundedRectangleBorder(),
                                overlayPadding: EdgeInsets.all(8),
                                contentPadding: EdgeInsets.all(20),
                                showcaseBackgroundColor: kPrimaryColor,
                                descTextStyle: TextStyle(
                                    fontFamily: 'nunito',
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    enableFeedback: true,
                                    elevation:
                                        MaterialStateProperty.resolveWith(
                                            (states) => 3.0),
                                    backgroundColor:
                                        MaterialStateColor.resolveWith(
                                            (states) => Colors.grey),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Settings()));
                                  },
                                  child: Icon(
                                    FontAwesomeIcons.gear,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 55),
                          child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            crossAxisCount: 2,
                            children: <Widget>[
                              pushUpButton(),
                              squatButton(),
                              jumpingJackButton()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        });
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
            text:
                'Please ensure a few things before you proceed with this feature: \n\n',
            style:
                workoutStartMessageStyle.copyWith(fontWeight: FontWeight.bold)),
        new TextSpan(
            text: '1. Well-Lit Surroundings\n',
            style: workoutStartMessageStyle),
        new TextSpan(
            text: '2. Ample of Physical Space\n',
            style: workoutStartMessageStyle),
        new TextSpan(
            text:
                '3. Device is around Waist Height & Able to Capture Full Body\n',
            style: workoutStartMessageStyle),
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
            title: WorkoutButton(
              color: kAccentColor.withOpacity(0.3),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                  'Squat Demonstration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'nunito',
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: kPrimaryColor),
                ),
              ),
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
            title: WorkoutButton(
              color: kAccentColor.withOpacity(0.3),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                  'Push Up Demonstration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'nunito',
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: kPrimaryColor),
                ),
              ),
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
            title: WorkoutButton(
              color: kAccentColor.withOpacity(0.3),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                  'Jumping Jack Demonstration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'nunito',
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: kPrimaryColor),
                ),
              ),
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
                        height: 370,
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
                          buildConfirmationAlert(PoseClass.classJumpingJack);
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
            content: Container(
              height: 360,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(
                      opacity: 0.9,
                      child: Image(
                        height: 220,
                        image: AssetImage('assets/images/cameraAngle.png'),
                      ),
                    ),
                  ),
                  Text('\nDo you wish to start now?\n',
                      style: workoutStartMessageStyle.copyWith(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
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
                ],
              ),
            ),
          );
        });
  }

  Widget pushUpButton() {
    return CustomElevatedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.2),
              child: Image(
                image: AssetImage('assets/images/pushUp.png'),
                height: 50,
              ),
            ),
            Text(
              'PUSH UP',
              style: TextStyle(
                  fontFamily: 'Insanibu', fontSize: 21, color: Colors.white),
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                SizedBox(
                  width: 9,
                ),
                Showcase(
                  key: _key2,
                  description: 'Targeted Muscle of the Exercise.',
                  shapeBorder: const RoundedRectangleBorder(),
                  overlayPadding: EdgeInsets.all(8),
                  contentPadding: EdgeInsets.all(20),
                  showcaseBackgroundColor: kPrimaryColor,
                  descTextStyle: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                  child: Image(
                    image: AssetImage('assets/images/chest.png'),
                    height: 33,
                  ),
                ),
                SizedBox(
                  width: 46,
                ),
                Showcase(
                  key: _key3,
                  description:
                      'Type of Exercise. \n\n eg.\n\n Heart = Cardio \n Dumbell = Resistance',
                  shapeBorder: const RoundedRectangleBorder(),
                  overlayPadding: EdgeInsets.all(8),
                  contentPadding: EdgeInsets.all(20),
                  showcaseBackgroundColor: kPrimaryColor,
                  descTextStyle: TextStyle(
                      fontFamily: 'nunito',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                  child: Image(
                    image: AssetImage('assets/images/Resistance.png'),
                    height: 32,
                  ),
                ),
              ],
            ),
            Showcase(
              key: _key4,
              description: 'Difficulty of the Exercise.',
              shapeBorder: const RoundedRectangleBorder(),
              overlayPadding: EdgeInsets.all(8),
              contentPadding: EdgeInsets.all(20),
              showcaseBackgroundColor: kPrimaryColor,
              descTextStyle: TextStyle(
                  fontFamily: 'nunito',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900),
              child: Image(
                image: AssetImage('assets/images/easy.png'),
                height: 22,
              ),
            ),
          ],
        ),
        gradient: LinearGradient(
            colors: [kPrimaryColor, kAccentColor],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: BoxShadow(
          color: Colors.black26,
          spreadRadius: 2.5,
          blurRadius: 7,
          offset: Offset(0, 5), // changes position of shadow
        ),
        onPressed: () {
          buildPushUpDemo();
        });
  }

  Widget squatButton() {
    return CustomElevatedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Image(
                image: AssetImage('assets/images/squat.png'),
                height: 55,
              ),
            ),
            Text(
              'SQUAT',
              style: TextStyle(
                  fontFamily: 'Insanibu', fontSize: 21, color: Colors.white),
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                SizedBox(
                  width: 9,
                ),
                Image(
                  image: AssetImage('assets/images/quad.png'),
                  height: 33,
                ),
                SizedBox(
                  width: 46,
                ),
                Image(
                  image: AssetImage('assets/images/Resistance.png'),
                  height: 32,
                ),
              ],
            ),
            Image(
              image: AssetImage('assets/images/easy.png'),
              height: 22,
            ),
          ],
        ),
        gradient: LinearGradient(
            colors: [kPrimaryColor, kAccentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: BoxShadow(
          color: Colors.black26,
          spreadRadius: 2.5,
          blurRadius: 7,
          offset: Offset(0, 5), // changes position of shadow
        ),
        onPressed: () {
          buildSquatDemo();
        });
  }

  Widget jumpingJackButton() {
    return CustomElevatedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image(
                image: AssetImage('assets/images/jumpingJack.png'),
                height: 55,
              ),
            ),
            Text(
              'JUMPING JACK',
              style: TextStyle(
                  fontFamily: 'Insanibu', fontSize: 18.05, color: Colors.white),
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                SizedBox(
                  width: 9,
                ),
                Image(
                  image: AssetImage('assets/images/calf.png'),
                  height: 33,
                ),
                SizedBox(
                  width: 46,
                ),
                Image(
                  image: AssetImage('assets/images/Cardio.png'),
                  height: 32,
                ),
              ],
            ),
            Image(
              image: AssetImage('assets/images/easy.png'),
              height: 22,
            ),
          ],
        ),
        gradient: LinearGradient(
            colors: [kPrimaryColor, kAccentColor],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: BoxShadow(
          color: Colors.black26,
          spreadRadius: 2.5,
          blurRadius: 7,
          offset: Offset(0, 5), // changes position of shadow
        ),
        onPressed: () {
          buildJumpingJackDemo();
        });
  }
}

TextStyle workoutStartMessageStyle =
    TextStyle(fontFamily: 'nunito', fontSize: 19, fontWeight: FontWeight.w900);
