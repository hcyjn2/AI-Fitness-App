import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFF3D27A);
const Color kSecondaryColor = Color(0xFFDCBE6F);
const Color kAccentColor = Color(0xFFFFE296);
// const Color kSecondaryColor = Color(0xffd4bda5);
// const Color kSecondaryColor = Color(0xffb6d5bc);

const classPushUp = "pushups_down";
const classSquat = "squats_down";
const classSquatHalfRep = "squatshalfrep_down";
const classSquatBackSlouching = "squatsbackslouching_down";
const classJumpingJack = "jumpingjacks_down";
const classJumpingJackBentArm = "jumpingjacksbentarm_down";

const poseClasses = {
  classPushUp,
  classSquat,
  classSquatHalfRep,
  classSquatBackSlouching,
  classJumpingJack,
  classJumpingJackBentArm,
};

enum PoseClass {
  classPushUp,
  classSquat,
  classSquatHalfRep,
  classSquatBackSlouching,
  classJumpingJack,
  classJumpingJackBentArm,
}

String poseClassToString(PoseClass poseClass) {
  if (poseClass == PoseClass.classSquat)
    return 'Squat';
  else if (poseClass == PoseClass.classSquatHalfRep)
    return 'Squat(Half Rep)';
  else if (poseClass == PoseClass.classSquatBackSlouching)
    return 'Squat(Back Slouch)';
  else if (poseClass == PoseClass.classPushUp)
    return 'Push Up';
  else if (poseClass == PoseClass.classJumpingJack)
    return 'Jumping Jack';
  else if (poseClass == PoseClass.classJumpingJackBentArm)
    return 'Jumping Jack(Bent Arm)';
  else
    return '';
}

String classIdentifierToClassName(String classText) {
  if (classText == classPushUp)
    return 'Push Up';
  else if (classText == classSquat)
    return 'Squat';
  else if (classText == classSquatHalfRep)
    return 'Squat(Half Rep)';
  else if (classText == classSquatBackSlouching)
    return 'Squat(Back Slouch)';
  else if (classText == classJumpingJack)
    return 'Jumping Jack';
  else if (classText == classJumpingJackBentArm)
    return 'Jumping Jack(Bent Arm)';
  else
    return classText;
}

PoseClass classIdentifierToPoseClass(String classText) {
  if (classText == 'pushups_down' || classText == 'pushups_up')
    return PoseClass.classPushUp;
  else if (classText == 'squats_down' || classText == 'squats_up')
    return PoseClass.classSquat;
  else if (classText == 'squatshalfrep_down' || classText == 'squats_up')
    return PoseClass.classSquatHalfRep;
  else if (classText == 'squatsbackslouching_down' || classText == 'squats_up')
    return PoseClass.classSquatBackSlouching;
  else if (classText == 'jumpingjacks_down' || classText == 'jumpingjacks_up')
    return PoseClass.classJumpingJack;
  else if (classText == 'jumpingjacksbentarm_down' ||
      classText == 'jumpingjacks_up')
    return PoseClass.classJumpingJackBentArm;
  else
    print('Error: No such Class.');
  return PoseClass.classPushUp;
}
