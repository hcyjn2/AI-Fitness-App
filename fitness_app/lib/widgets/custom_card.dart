import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Color color;
  final Widget? child;

  CustomCard({
    Key? key,
    required this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
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
