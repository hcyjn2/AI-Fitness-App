import 'package:fitness_app/screens/workout_session.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

// Workout feature
class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.91,
      width: MediaQuery.of(context).size.width * 0.995,
      child: CustomCard(
        color: kSecondaryColor.withOpacity(0.65),
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          crossAxisCount: 2,
          children: <Widget>[
            WorkoutButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Push Up',
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Image(
                      image: AssetImage('assets/images/pushUp.png'),
                      height: 45,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/chest.png'),
                          height: 40,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Image(
                          image: AssetImage('assets/images/easy.png'),
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                color: kPrimaryColor,
                onPressed: () {
                  buildConfirmationAlert();
                }),
            WorkoutButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Squat',
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Image(
                      image: AssetImage('assets/images/squat.png'),
                      height: 60,
                    ),
                    Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/hamstrings.png'),
                          height: 40,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Image(
                          image: AssetImage('assets/images/easy.png'),
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                color: kSecondaryColor,
                onPressed: () {
                  buildConfirmationAlert();
                }),
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
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
        new TextSpan(
            text: 'Well-Lit',
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
        new TextSpan(
            text: ' & have ',
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        new TextSpan(
            text: 'Ample Physical Space',
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
        new TextSpan(
            text: ' for this feature.\n\nDo you wish to start now?',
            style: GoogleFonts.nunito(
                textStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ],
    ),
  );

  Future buildConfirmationAlert() {
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
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold))),
                  onPressed: () async {
                    setState(() {
                      //NO Action
                      Navigator.pop(context);
                    });
                  },
                ),
                SizedBox(
                  width: 30,
                ),
                MaterialButton(
                  elevation: 5.0,
                  color: kPrimaryColor,
                  child: Text('YES',
                      style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold))),
                  onPressed: () async {
                    setState(() {
                      //YES Action
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExperimentScreen(),
                        ),
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

class WorkoutButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onPressed;

  WorkoutButton({required this.child, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
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
