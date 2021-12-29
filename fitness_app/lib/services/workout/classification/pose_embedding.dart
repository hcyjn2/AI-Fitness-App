//Constants
import 'package:google_ml_kit/google_ml_kit.dart';
import 'utils.dart';

const torsoMultiplier = 2.5;

class PoseEmbedding {
  PoseEmbedding._();

  // Translation normalization should've been done prior to calling this method.
  static double getPoseSize(List<PoseLandmark> landmarks) {
    // Note: This approach uses only 2D landmarks to compute pose size as using Z wasn't helpful
    // in our experimentation but you're welcome to tweak.
    PoseLandmark hipsCenter = Utils.average(
        landmarks.elementAt(PoseLandmarkType.leftHip.index),
        landmarks.elementAt(PoseLandmarkType.rightHip.index));
    PoseLandmark shouldersCenter = Utils.average(
        landmarks.elementAt(PoseLandmarkType.leftShoulder.index),
        landmarks.elementAt(PoseLandmarkType.rightShoulder.index));

    double torsoSize =
        Utils.l2Norm2D(Utils.subtract(hipsCenter, shouldersCenter));

    double maxDistance = torsoSize * torsoMultiplier;
    // torsoSize * TORSO_MULTIPLIER is the floor we want based on experimentation but actual size
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

  static List<PoseLandmark> getPoseEmbedding(List<PoseLandmark> landmarks) {
    List<PoseLandmark> normalizedLandmarks = normalize(landmarks);
    return getEmbedding(normalizedLandmarks);
  }

  static List<PoseLandmark> getEmbedding(List<PoseLandmark> landmark) {
    List<PoseLandmark> embedding = [];

    // We use several pairwise 3D distances to form pose embedding. These were selected
    // based on experimentation for best results with our default pose classes as captued in the
    // pose samples csv. Feel free to play with this and add or remove for your use-cases.

    // We group our distances by number of joints between the pairs.
    // One joint.
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
        landmark.elementAt(PoseLandmarkType.leftElbow.index),
        landmark.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightElbow.index),
        landmark.elementAt(PoseLandmarkType.rightWrist.index)));

    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftHip.index),
        landmark.elementAt(PoseLandmarkType.leftKnee.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightHip.index),
        landmark.elementAt(PoseLandmarkType.rightKnee.index)));

    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftKnee.index),
        landmark.elementAt(PoseLandmarkType.leftAnkle.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightKnee.index),
        landmark.elementAt(PoseLandmarkType.rightAnkle.index)));

    // Two joints.
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftShoulder.index),
        landmark.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightShoulder.index),
        landmark.elementAt(PoseLandmarkType.rightWrist.index)));

    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftHip.index),
        landmark.elementAt(PoseLandmarkType.leftAnkle.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightHip.index),
        landmark.elementAt(PoseLandmarkType.rightAnkle.index)));

    // Four joints.
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftHip.index),
        landmark.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightHip.index),
        landmark.elementAt(PoseLandmarkType.rightWrist.index)));

    // Five joints.
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftShoulder.index),
        landmark.elementAt(PoseLandmarkType.leftAnkle.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightShoulder.index),
        landmark.elementAt(PoseLandmarkType.rightAnkle.index)));

    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftHip.index),
        landmark.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.rightHip.index),
        landmark.elementAt(PoseLandmarkType.rightWrist.index)));

    // Cross body.
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftElbow.index),
        landmark.elementAt(PoseLandmarkType.rightElbow.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftKnee.index),
        landmark.elementAt(PoseLandmarkType.rightKnee.index)));

    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftWrist.index),
        landmark.elementAt(PoseLandmarkType.rightWrist.index)));
    embedding.add(Utils.subtract(
        landmark.elementAt(PoseLandmarkType.leftAnkle.index),
        landmark.elementAt(PoseLandmarkType.rightAnkle.index)));

    return embedding;
  }
}
