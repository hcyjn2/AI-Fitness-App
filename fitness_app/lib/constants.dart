import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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

const poseClassesWithoutVariation = {
  classPushUp,
  classSquat,
  classJumpingJack,
};

enum PoseClass {
  classPushUp,
  classSquat,
  classSquatHalfRep,
  classSquatBackSlouching,
  classJumpingJack,
  classJumpingJackBentArm,
}

enum poseClassWithoutVariation {
  classPushUp,
  classSquat,
  classJumpingJack,
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

PoseClass stringToPoseClass(String string) {
  if (string == 'Squat')
    return PoseClass.classSquat;
  else if (string == 'Push Up')
    return PoseClass.classPushUp;
  else if (string == 'Jumping Jack')
    return PoseClass.classJumpingJack;
  else
    return PoseClass.classPushUp;
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

bool isValidClass(var input) {
  PoseClass poseClass;

  if (input is String)
    poseClass = classIdentifierToPoseClass(input);
  else
    poseClass = input;

  bool out = (poseClass == PoseClass.classSquat ||
      poseClass == PoseClass.classJumpingJack ||
      poseClass == PoseClass.classPushUp);

  return out;
}

List<Tuple2<int, PoseClass>> dailyChallenges = [
  Tuple2(3, PoseClass.classPushUp),
  Tuple2(8, PoseClass.classJumpingJack),
  Tuple2(5, PoseClass.classSquat)
];

int getExpUpperBound(int level) {
  if (level == 1) {
    return 10;
  } else if (level == 2) {
    return 18;
  } else if (level == 3) {
    return 30;
  } else if (level == 4) {
    return 50;
  } else if (level == 5) {
    return 1000;
  } else {
    return 5000;
  }
}
