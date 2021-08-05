import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

// Calorie Tracking feature
class CalorieTrackingScreen extends StatefulWidget {
  @override
  _CalorieTrackingScreenState createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.91,
      width: MediaQuery.of(context).size.width * 0.995,
      child: CustomCard(
          color: kSecondaryColor.withOpacity(0.65),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Calorie',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )),
    );
  }
}
