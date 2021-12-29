import 'dart:collection';
import 'dart:core';

import 'package:fitness_app/services/workout/classification/classification_result.dart';
import 'package:fitness_app/services/workout/classification/ema_smoothing.dart';
import 'package:fitness_app/services/workout/classification/pose_classifier.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:fitness_app/services/workout/classification/repetition_counter.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tuple/tuple.dart';

const tag = "PoseClassifierProcessor";
const poseSamplesFile = "fitness_pose_samples.csv";

const __classPushUp = "pushups_down";
const __classSquats = "squats_down";
// const __classJumpSquat = "jumpsquat_down";
// const __poseClasses = {__classPushUp, __classSquats, __classJumpSquat};
const __poseClasses = {__classPushUp, __classSquats};

class PoseClassifierProcessor {
  // Specify classes for which we want rep counting.
  // These are the labels in the given {@code POSE_SAMPLES_FILE}. You can set your own class labels
  // for your pose samples.

  final bool __isStreamMode;

  late EMASmoothing __emaSmoothing;
  late List<RepetitionCounter> __repCounters;
  late PoseClassifier __poseClassifier;
  late String __lastRepResult;
  late List<PoseSample> __poseSamples;
  List<String> resultClass = [];
  List<int> resultRepetition = [];

  PoseClassifierProcessor(this.__isStreamMode, this.__poseSamples) {
    if (__isStreamMode) {
      __emaSmoothing = new EMASmoothing();
      __repCounters = [];
      __lastRepResult = '';

      __poseClassifier = new PoseClassifier(__poseSamples);

      for (String className in __poseClasses) {
        __repCounters.add(new RepetitionCounter(className));
      }
    }
  }

  void loadPoseSamples() async {
    List<PoseSample> poseSamples = [];

    List<String> csvData = await PoseSample.readCSV();

    for (var row in csvData)
      poseSamples.add(await PoseSample.getPoseSample(row));

    __poseClassifier = new PoseClassifier(__poseSamples);

    if (__isStreamMode) {
      for (String className in __poseClasses) {
        __repCounters.add(new RepetitionCounter(className));
      }
    }

    // try {
    // BufferedReader reader = new BufferedReader(
    //     new InputStreamReader(context.getAssets().open(poseSamplesFile)));
    // String csvLine = reader.readLine();
    // while (csvLine != null) {
    //   // If line is not a valid {@link PoseSample}, we'll get null and skip adding to the list.
    //   PoseSample poseSample = PoseSample.getPoseSample(csvLine, ",");
    //   if (poseSample != null) {
    //     poseSamples.add(poseSample);
    //   }
    //   csvLine = reader.readLine();
    // }
    // }

    // __poseClassifier = new PoseClassifier(poseSamples);
    //
    // if (__isStreamMode) {
    //   for (String className in __poseClasses) {
    //     __repCounters.add(new RepetitionCounter(className));
    //   }
    // }
  }

  /**
   * Given a new {@link Pose} input, returns a list of formatted {@link String}s with Pose
   * classification results.
   *
   * <p>Currently it returns up to 2 strings as following:
   * 0: PoseClass : X reps
   * 1: PoseClass : [0.0-1.0] confidence
   */
// @WorkerThread
  List<String> getPoseResult(Pose pose) {
    // Preconditions.checkState(Looper.myLooper() != Looper.getMainLooper());

    List<String> classificationResult = [];
    ClassificationResult classification = __poseClassifier.classifyPose(pose);

    // Update {@link RepetitionCounter}s if {@code isStreamMode}.
    if (__isStreamMode) {
      // Feed pose to smoothing even if no pose found.
      classification = __emaSmoothing.getSmoothedResult(classification);

      // Return early without updating repCounter if no pose found.
      if (pose.landmarks.isEmpty) {
        classificationResult.add(__lastRepResult);
        return classificationResult;
      }

      for (RepetitionCounter repCounter in __repCounters) {
        int repsBefore = repCounter.numRepeats;
        int repsAfter = repCounter.addClassificationResult(classification);
        if (repsAfter > repsBefore) {
          // Play a fun beep when rep counter updates.
          FlutterBeep.beep();

          __lastRepResult =
              (repCounter.className + ' : ' + repsAfter.toString() + ' reps');

          break;
        }
      }
      classificationResult.add(__lastRepResult);
    }

    // Add maxConfidence class of current frame to result if pose is found.
    if (pose.landmarks.isNotEmpty) {
      String maxConfidenceClass = classification.getMaxConfidenceClass();
      String maxConfidenceClassResult = (maxConfidenceClass +
          ' : ' +
          (classification.getClassConfidence(maxConfidenceClass)! /
                  __poseClassifier.confidenceRange())
              .toString() +
          ' confidence');
      classificationResult.add(maxConfidenceClassResult);
    }

    return classificationResult;
  }
}
