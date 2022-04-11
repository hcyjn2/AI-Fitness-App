import 'dart:math';

import 'package:fitness_app/constants.dart';
import 'package:fitness_app/services/workout/classification/classification_result.dart';
import 'package:fitness_app/services/workout/classification/pose_embedding.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:collection/collection.dart';
import 'package:fitness_app/services/workout/classification/utils.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tuple/tuple.dart';

const tag = "PoseClassifier";
// "Smaller amount indicates better Sensitivity and Vice Versa"
const defaultMaxDistanceTopK = 30;
// "Smaller amount indicates lesser Sensitivity and Vice Versa"
const defaultMeanDistanceTopK = 9;

class PoseClassifier {
  final List<PoseSample> __poseSamples;
  final int __maxDistanceTopK;
  final int __meanDistanceTopK;
  late final PoseLandmark __axesWeights;
  final PoseClass __poseClass;

  PoseClassifier(
    this.__poseSamples,
    this.__poseClass, [
    this.__maxDistanceTopK = defaultMaxDistanceTopK,
    this.__meanDistanceTopK = defaultMeanDistanceTopK,
  ]) {
    // Z has a lower weight as it is generally less accurate than X & Y.
    __axesWeights = PoseLandmark(PoseLandmarkType.nose, 1, 1, 0.2, 1);
  }

  PoseClassifier.named(
    this.__poseSamples,
    this.__poseClass,
    this.__axesWeights, [
    this.__maxDistanceTopK = defaultMaxDistanceTopK,
    this.__meanDistanceTopK = defaultMeanDistanceTopK,
  ]);

  static List<PoseLandmark> extractPoseLandmarks(Pose pose) {
    List<PoseLandmark> landmarks = [];
    for (PoseLandmark poseLandmark in pose.landmarks.values) {
      landmarks.add(poseLandmark);
    }
    return landmarks;
  }

  /**
   * Returns the max range of confidence values.
   *
   * Since we calculate confidence by counting PoseSamples that survived
   * outlier-filtering by maxDistanceTopK and meanDistanceTopK, this range is the minimum of two.
   */
  int confidenceRange() => min(__maxDistanceTopK, __meanDistanceTopK);

  // Classification (Pose as Input)
  ClassificationResult classifyPose(Pose pose) =>
      classify(extractPoseLandmarks(pose));

  // Classification:
  ClassificationResult classify(List<PoseLandmark> landmarks) {
    ClassificationResult result = new ClassificationResult();

    ClassificationResult evaluateAnkleJointAngle(
        List<PoseLandmark> landmarks, ClassificationResult result) {
      int leftKneeJoint = PoseEmbedding.getJointAngle(
          landmarks.elementAt(PoseLandmarkType.leftHip.index),
          landmarks.elementAt(PoseLandmarkType.leftKnee.index),
          landmarks.elementAt(PoseLandmarkType.leftAnkle.index));
      int rightKneeJoint = PoseEmbedding.getJointAngle(
          landmarks.elementAt(PoseLandmarkType.rightHip.index),
          landmarks.elementAt(PoseLandmarkType.rightKnee.index),
          landmarks.elementAt(PoseLandmarkType.rightAnkle.index));
      int leftAnkleJoint = PoseEmbedding.getJointAngle(
          landmarks.elementAt(PoseLandmarkType.leftKnee.index),
          landmarks.elementAt(PoseLandmarkType.leftAnkle.index),
          landmarks.elementAt(PoseLandmarkType.leftFootIndex.index));
      int rightAnkleJoint = PoseEmbedding.getJointAngle(
          landmarks.elementAt(PoseLandmarkType.rightKnee.index),
          landmarks.elementAt(PoseLandmarkType.rightAnkle.index),
          landmarks.elementAt(PoseLandmarkType.rightFootIndex.index));

      // Able to identify the angles but not consistently
      // if (leftAnkleJoint > 177 &&
      //     leftAnkleJoint <= 195 &&
      //     rightAnkleJoint <= 180 &&
      //     leftKneeJoint >= 172 &&
      //     leftKneeJoint <= 185 &&
      //     rightKneeJoint >= 172 &&
      //     rightKneeJoint <= 185) {
      //   result.incrementClassConfidence('jumpsquats_down');
      // }

      return result;
    }

    // Return early if no landmarks detected.
    if (landmarks.isEmpty) {
      return result;
    }

    // Flipping on X-axis so that we are horizontal (mirror) invariant.
    List<PoseLandmark> flippedLandmarks = landmarks;
    for (var lm in flippedLandmarks) {
      Utils.multiply(lm, PoseLandmark(lm.type, -1, 1, 1, lm.likelihood));
    }

    // TODO
    List<PoseLandmark> embedding =
        PoseEmbedding.getPoseEmbedding(landmarks, __poseClass);
    List<PoseLandmark> flippedEmbedding =
        PoseEmbedding.getPoseEmbedding(flippedLandmarks, __poseClass);

    // Classification is done in two stages:
    //  * First we pick top-K samples by MAX distance. It allows to remove samples that are almost
    //    the same as given pose, but maybe has few joints bent in the other direction.
    //  * Then we pick top-K samples by MEAN distance. After outliers are removed, we pick samples
    //    that are closest by average.

    // Keeps max distance on top so we can pop it when top_k size is reached.
    // TODO compare & PriorityQueue function might be wrong.
    PriorityQueue<Tuple2<PoseSample, double>> maxDistances =
        new PriorityQueue((o1, o2) => -compare(o1, o2));

    // Retrieve top K poseSamples by least distance to remove outliers.
    for (PoseSample poseSample in __poseSamples) {
      List<PoseLandmark> sampleEmbedding = poseSample.embedding;

      double originalMax = 0;
      double flippedMax = 0;
      for (int i = 0; i < embedding.length; i++) {
        originalMax = max(
          originalMax,
          Utils.maxAbs(
            Utils.multiply(
                Utils.subtract(
                    embedding.elementAt(i), sampleEmbedding.elementAt(i)),
                __axesWeights),
          ),
        );
        flippedMax = max(
          flippedMax,
          Utils.maxAbs(
            Utils.multiply(
                Utils.subtract(flippedEmbedding.elementAt(i),
                    sampleEmbedding.elementAt(i)),
                __axesWeights),
          ),
        );
      }
      // Set the max distance as min of original and flipped max distance.
      maxDistances.add(new Tuple2(poseSample, min(originalMax, flippedMax)));
      // We only want to retain top n so pop the highest distance.
      if (maxDistances.length > __maxDistanceTopK) {
        maxDistances.removeFirst();
      }
    }

    // Keeps higher mean distances on top so we can pop it when top_k size is reached.
    PriorityQueue<Tuple2<PoseSample, double>> meanDistances =
        new PriorityQueue((o1, o2) => -compare(o1, o2));

    // Retrieve top K poseSamples by least mean distance to remove outliers.
    for (Tuple2<PoseSample, double> sampleDistances in maxDistances.toList()) {
      PoseSample poseSample = sampleDistances.item1;
      List<PoseLandmark> sampleEmbedding = poseSample.embedding;

      double originalSum = 0;
      double flippedSum = 0;
      for (int i = 0; i < embedding.length; i++) {
        originalSum += Utils.sumAbs(Utils.multiply(
            Utils.subtract(
                embedding.elementAt(i), sampleEmbedding.elementAt(i)),
            __axesWeights));
        flippedSum += Utils.sumAbs(Utils.multiply(
            Utils.subtract(
                flippedEmbedding.elementAt(i), sampleEmbedding.elementAt(i)),
            __axesWeights));
      }
      // Set the mean distance as min of original and flipped mean distances.
      double meanDistance =
          min(originalSum, flippedSum) / (embedding.length * 2);

      meanDistances.add(new Tuple2(poseSample, meanDistance));
      // We only want to retain top k so pop the highest mean distance.
      if (meanDistances.length > __meanDistanceTopK) {
        meanDistances.removeFirst();
      }
    }

    // Increase Class Confidence based on the filtered mean distances.
    for (Tuple2<PoseSample, double> sampleDistances in meanDistances.toList()) {
      String className = sampleDistances.item1.className;

      result.incrementClassConfidence(className);
    }

    // result = evaluateAnkleJointAngle(landmarks, result);

    return result;
  }

  int compare(Tuple2<PoseSample, double> o1, Tuple2<PoseSample, double> o2) {
    if (o1.item2 > o2.item2)
      return 1;
    else if (o1.item2 < o2.item2)
      return -1;
    else
      return 0;
  }
}
