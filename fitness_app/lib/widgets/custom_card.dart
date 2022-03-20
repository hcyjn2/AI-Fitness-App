import 'package:fitness_app/constants.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Color color;
  final Widget? child;
  final BoxShadow? boxShadow;

  CustomCard({Key? key, required this.color, this.child, this.boxShadow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        boxShadow: [
          boxShadow ??
              BoxShadow(
                color: Colors.transparent,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              )
        ],
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}

// GestureDetector(
// onTap: () {
// setState(() {
// selectedGender = Gender.male;
// });
// },
// child: CustomCard(
// selectedGender == Gender.male
// ? activeCardColor
//     : inactiveCardColor,
// IconContent(FontAwesomeIcons.mars, "MALE"),
// ),
// ),
