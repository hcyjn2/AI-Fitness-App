import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFF3D27A);
const Color kSecondaryColor = Color(0xFFDCBE6F);
const Color kAccentColor = Color(0xFFFFE296);
// const Color kSecondaryColor = Color(0xffd4bda5);
// const Color kSecondaryColor = Color(0xffb6d5bc);

const classPushUp = "pushups_down";
const classSquat = "squats_down";
const classJumpSquat = "jumpsquats_down";
const poseClasses = {classPushUp, classJumpSquat, classSquat};

enum PoseClass {
  classPushUp,
  classSquat,
  classJumpSquat,
}

String poseClassToString(PoseClass poseClass) {
  if (poseClass == PoseClass.classSquat)
    return 'Squat';
  else if (poseClass == PoseClass.classPushUp)
    return 'Push Up';
  else if (poseClass == PoseClass.classJumpSquat)
    return 'Jump Squat';
  else
    return '';
}

String classIdentifierToClassName(String classText) {
  if (classText == classPushUp)
    return 'Push Up';
  else if (classText == classSquat)
    return 'Squat';
  else if (classText == classJumpSquat)
    return 'Jump Squat';
  else
    return classText;
}

PoseClass classIdentifierToPoseClass(String classText) {
  if (classText == 'pushups_down' || classText == 'pushups_up')
    return PoseClass.classPushUp;
  else if (classText == 'squats_down' || classText == 'squats_up')
    return PoseClass.classSquat;
  else if (classText == 'jumpsquats_down' || classText == 'jumpsquats_up')
    return PoseClass.classJumpSquat;
  else
    print('Error: No such Class.');
  return PoseClass.classPushUp;
}
