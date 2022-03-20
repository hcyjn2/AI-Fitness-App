import 'package:fitness_app/widgets/custom_card.dart';
import 'package:fitness_app/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

// Workout feature
class WorkoutMenu extends StatefulWidget {
  @override
  _WorkoutMenuState createState() => _WorkoutMenuState();
}

class _WorkoutMenuState extends State<WorkoutMenu> {
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
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          crossAxisCount: 2,
          children: <Widget>[
            CustomElevatedButton(
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
                          fontFamily: 'nunito',
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Image(
                          image: AssetImage('assets/images/chest.png'),
                          height: 40,
                        ),
                        SizedBox(
                          width: 40,
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
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 2.5,
                  blurRadius: 7,
                  offset: Offset(0, 5), // changes position of shadow
                ),
                onPressed: () {
                  buildPushUpDemo();
                }),
            CustomElevatedButton(
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
                          fontFamily: 'nunito',
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Image(
                          image: AssetImage('assets/images/quad.png'),
                          height: 40,
                        ),
                        SizedBox(
                          width: 40,
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
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 2.5,
                  blurRadius: 7,
                  offset: Offset(0, 5), // changes position of shadow
                ),
                onPressed: () {
                  buildSquatDemo();
                }),
            CustomElevatedButton(
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
                          fontFamily: 'nunito',
                          fontSize: 15.9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Image(
                          image: AssetImage('assets/images/calf.png'),
                          height: 40,
                        ),
                        SizedBox(
                          width: 40,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 2.5,
                  blurRadius: 7,
                  offset: Offset(0, 5), // changes position of shadow
                ),
                onPressed: () {
                  buildSquatDemo();
                })
          ],
        ),
      ),
    );
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
}

TextStyle workoutStartMessageStyle =
    TextStyle(fontFamily: 'nunito', fontSize: 19, fontWeight: FontWeight.w900);

class WorkoutButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onPressed;
  final double elevation;

  WorkoutButton(
      {required this.child,
      required this.color,
      this.onPressed,
      this.elevation = 10.0});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        enableFeedback: true,
        elevation: MaterialStateProperty.resolveWith((states) => elevation),
        backgroundColor: MaterialStateColor.resolveWith((states) => color),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
