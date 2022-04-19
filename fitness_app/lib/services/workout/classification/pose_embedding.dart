//Constants
import 'package:fitness_app/constants.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'utils.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

const torsoMultiplier = 2.5;

class PoseEmbedding {
  PoseEmbedding._();

  // Translation normalization should've been done prior to calling this method.
  static double getPoseSize(List<PoseLandmark> landmarks) {
    // Note: This approach uses only 2D landmarks to compute pose size as using Z wasn't helpful.
    PoseLandmark hipsCenter = Utils.average(
        landmarks.elementAt(PoseLandmarkType.leftHip.index),
        landmarks.elementAt(PoseLandmarkType.rightHip.index));
    PoseLandmark shouldersCenter = Utils.average(
        landmarks.elementAt(PoseLandmarkType.leftShoulder.index),
        landmarks.elementAt(PoseLandmarkType.rightShoulder.index));

    double torsoSize =
        Utils.l2Norm2D(Utils.subtract(hipsCenter, shouldersCenter));

    double maxDistance = torsoSize * torsoMultiplier;
    // torsoSize * torsoMultiplier is the floor we want based on experimentation but actual size
    // can be bigger for a given pose depending on extension of limbs etc so we calculate that.
    for (PoseLandmark landmark in landmarks) {
      double distance = Utils.l2Norm2D(Utils.subtract(hipsCenter, landmark));
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }
    return maxDistance;
  }

  static List<PoseLandmark> normalize(List<PoseLandmark> landmarks) {
    List<PoseLandmark> normalizedLandmarks = landmarks;
    // Normalize translation.
    PoseLandmark center = Utils.average(
        landmarks.elementAt(PoseLandmarkType.leftHip.index),
        landmarks.elementAt(PoseLandmarkType.rightHip.index));
    normalizedLandmarks = Utils.subtractAll(center, normalizedLandmarks);

    // Normalize scale.
    normalizedLandmarks = Utils.multiplyWithDoubleAll(
        normalizedLandmarks, 1 / getPoseSize(normalizedLandmarks));

    // Multiplication by 100 is not required, but makes it easier to debug.
    normalizedLandmarks = Utils.multiplyWithDoubleAll(normalizedLandmarks, 100);

    return normalizedLandmarks;
  }

  static int getJointAngle(
      PoseLandmark lm1, PoseLandmark lm2, PoseLandmark lm3) {
    double x1 = lm1.x;
    double y1 = lm1.y;
    double x2 = lm2.x;
    double y2 = lm2.y;
    double x3 = lm3.x;
    double y3 = lm3.y;

    double angle = 0;

    angle = degrees(atan2(y3 - y2, x3 - x2) - atan2(y1 - y2, x1 - x2));

    if (angle < 0) angle += 360;

    return angle.toInt();
  }

  static List<PoseLandmark> getPoseEmbedding(
      List<PoseLandmark> landmarks, PoseClass poseClass) {
    List<PoseLandmark> normalizedLandmarks = normalize(landmarks);
    return getEmbedding(normalizedLandmarks, poseClass);
  }

  static List<PoseLandmark> getEmbedding(
      List<PoseLandmark> landmark, PoseClass poseClass) {
    List<PoseLandmark> embedding = [];

    // We use several pairwise 3D distances to form pose embedding. These were selected
    // based on experimentation for best results with our default pose classes as captured in the
    // pose samples csv.

    // We group our distances by number of joints between the pairs.

    if (poseClass == PoseClass.classPushUp ||
        poseClass == PoseClass.classPushUpBackSlouching) {
      // One joint.
      embedding.add(Utils.subtract(
          Utils.average(landmark.elementAt(PoseLandmarkType.leftHip.index),
              landmark.elementAt(PoseLandmarkType.rightHip.index)),
          Utils.average(landmark.elementAt(PoseLandmarkType.leftShoulder.index),
              landmark.elementAt(PoseLandmarkType.rightShoulder.index))));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftEar.index),
          landmark.elementAt(PoseLandmarkType.leftHip.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightEar.index),
          landmark.elementAt(PoseLandmarkType.rightHip.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftWrist.index),
          landmark.elementAt(PoseLandmarkType.leftHip.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightWrist.index),
          landmark.elementAt(PoseLandmarkType.rightHip.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftWrist.index),
          landmark.elementAt(PoseLandmarkType.leftEar.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightWrist.index),
          landmark.elementAt(PoseLandmarkType.rightEar.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftWrist.index),
          landmark.elementAt(PoseLandmarkType.nose.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightWrist.index),
          landmark.elementAt(PoseLandmarkType.nose.index)));

      // Two joints.
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.rightElbow.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.leftEar.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightElbow.index),
          landmark.elementAt(PoseLandmarkType.rightEar.index)));

      // Four joints.
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftPinky.index),
          landmark.elementAt(PoseLandmarkType.leftEar.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightPinky.index),
          landmark.elementAt(PoseLandmarkType.rightEar.index)));
    } else if (poseClass == PoseClass.classSquat ||
        poseClass == PoseClass.classSquatHalfRep ||
        poseClass == PoseClass.classSquatBackSlouching) {
      // One joint.
      embedding.add(Utils.subtract(
          Utils.average(landmark.elementAt(PoseLandmarkType.leftHip.index),
              landmark.elementAt(PoseLandmarkType.rightHip.index)),
          Utils.average(landmark.elementAt(PoseLandmarkType.leftShoulder.index),
              landmark.elementAt(PoseLandmarkType.rightShoulder.index))));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.leftFootIndex.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightElbow.index),
          landmark.elementAt(PoseLandmarkType.rightFootIndex.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.nose.index),
          landmark.elementAt(PoseLandmarkType.leftFootIndex.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.nose.index),
          landmark.elementAt(PoseLandmarkType.rightFootIndex.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.leftAnkle.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightElbow.index),
          landmark.elementAt(PoseLandmarkType.rightAnkle.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftShoulder.index),
          landmark.elementAt(PoseLandmarkType.leftAnkle.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightShoulder.index),
          landmark.elementAt(PoseLandmarkType.rightAnkle.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftShoulder.index),
          landmark.elementAt(PoseLandmarkType.leftKnee.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightShoulder.index),
          landmark.elementAt(PoseLandmarkType.rightKnee.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftHip.index),
          landmark.elementAt(PoseLandmarkType.leftHeel.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightHip.index),
          landmark.elementAt(PoseLandmarkType.rightHeel.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.leftHeel.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightElbow.index),
          landmark.elementAt(PoseLandmarkType.rightHeel.index)));
    } else if (poseClass == PoseClass.classJumpingJack ||
        poseClass == PoseClass.classJumpingJackBentArm) {
      embedding.add(Utils.subtract(
          Utils.average(landmark.elementAt(PoseLandmarkType.leftHip.index),
              landmark.elementAt(PoseLandmarkType.rightHip.index)),
          Utils.average(landmark.elementAt(PoseLandmarkType.leftShoulder.index),
              landmark.elementAt(PoseLandmarkType.rightShoulder.index))));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftShoulder.index),
          landmark.elementAt(PoseLandmarkType.leftElbow.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightShoulder.index),
          landmark.elementAt(PoseLandmarkType.rightElbow.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftWrist.index),
          landmark.elementAt(PoseLandmarkType.leftShoulder.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightWrist.index),
          landmark.elementAt(PoseLandmarkType.rightShoulder.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.rightElbow.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftWrist.index),
          landmark.elementAt(PoseLandmarkType.rightWrist.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftIndex.index),
          landmark.elementAt(PoseLandmarkType.rightIndex.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftIndex.index),
          landmark.elementAt(PoseLandmarkType.leftHip.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightIndex.index),
          landmark.elementAt(PoseLandmarkType.rightHip.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftElbow.index),
          landmark.elementAt(PoseLandmarkType.nose.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.rightElbow.index),
          landmark.elementAt(PoseLandmarkType.nose.index)));

      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftAnkle.index),
          landmark.elementAt(PoseLandmarkType.rightAnkle.index)));
      embedding.add(Utils.subtract(
          landmark.elementAt(PoseLandmarkType.leftKnee.index),
          landmark.elementAt(PoseLandmarkType.rightKnee.index)));
    }

    return embedding;
  }
}
