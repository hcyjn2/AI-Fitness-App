import 'package:fitness_app/screens/experiment.dart';
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
                      style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 15,),
                    Image(image: AssetImage('assets/images/pushUp.png'), height: 50,),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Image(image: AssetImage('assets/images/chest.png'), height: 40,),
                        SizedBox(width: 15,),
                        Image(image: AssetImage('assets/images/easy.png'), height: 20,),
                      ],
                    ),
                  ],
                ),
                color: kPrimaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExperimentScreen(),
                    ),
                  );
                }),
            WorkoutButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Squat',
                      style: GoogleFonts.nunito(textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 8,),
                    Image(image: AssetImage('assets/images/squat.png'), height: 70,),
                    Row(
                      children: [
                        Image(image: AssetImage('assets/images/hamstrings.png'), height: 40,),
                        SizedBox(width: 15,),
                        Image(image: AssetImage('assets/images/easy.png'), height: 20,),
                      ],
                    ),
                  ],
                ),
                color: kSecondaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExperimentScreen(),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
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
