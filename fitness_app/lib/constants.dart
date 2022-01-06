import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFF3D27A);
const Color kSecondaryColor = Color(0xffd4bda5);

const classPushUp = "pushups_down";
const classSquat = "squats_down";
// const __classJumpSquat = "jumpsquat_down";
// const __poseClasses = {__classPushUp, __classSquats, __classJumpSquat};
const poseClasses = {classPushUp, classSquat};

String classIdentifierToClassName(String classText) {
  if (classText == classPushUp)
    return 'Push Up';
  else if (classText == classSquat)
    return 'Squat';
  else
    return classText;
}
