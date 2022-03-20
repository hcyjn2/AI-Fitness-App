import 'package:fitness_app/services/workout/classification/classification_result.dart';

// These thresholds can be tuned in conjunction with the Top K values in {@link PoseClassifier}.
// The default Top K value is 10 so the range here is [0-10].
const defaultEnterThreshold = 6.0;
const defaultExitThreshold = 4.0;

class RepetitionCounter {
  final String __className;
  final double __enterThreshold;
  final double __exitThreshold;

  int __numRepeats;
  bool __poseEntered;

  RepetitionCounter(this.__className,
      [this.__numRepeats = 0,
      this.__poseEntered = false,
      this.__enterThreshold = defaultEnterThreshold,
      this.__exitThreshold = defaultExitThreshold]);

  /**
   * Adds a new Pose classification result and updates reps for given class.
   *
   * @param classificationResult {link ClassificationResult} of class to confidence values.
   * @return number of reps.
   */
  int addClassificationResult(ClassificationResult classificationResult) {
    double poseConfidence =
        classificationResult.getClassConfidence(__className) ?? 0;

    // print(__className + ' : ' + poseConfidence.toString());

    if (!__poseEntered) {
      __poseEntered = poseConfidence > __enterThreshold;
      return __numRepeats;
    }

    if (poseConfidence < __exitThreshold) {
      __numRepeats++;
      __poseEntered = false;
    }

    return __numRepeats;
  }

  int get numRepeats => __numRepeats;

  String get className => __className;
}
