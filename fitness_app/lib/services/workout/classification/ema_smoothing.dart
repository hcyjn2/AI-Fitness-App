import 'package:fitness_app/services/workout/classification/classification_result.dart';
import 'dart:collection';

const __defaultWindowSize = 10;
const __defaultAlpha = 0.2;

/**
 * Smooths given pose classification.
 *
 *  Smoothing is done by computing Exponential Moving Average for every pose
 *   class observed in the given time window. Missed pose classes are replaced
 *   with 0.
 *
 *  Args:
 *    data: Dictionary with pose classification. Sample:
 *        {
 *          'pushups_down': 8,
 *          'pushups_up': 2,
 *        }
 *
 *   Result:
 *    Dictionary in the same format but with smoothed and float instead of
 *    integer values. Sample:
 *       {
 *         'pushups_down': 8.3,
 *         'pushups_up': 1.7,
 *     }
*/

class EMASmoothing {
  final int __windowSize;
  final double __alpha;
  // This is a window of {@link ClassificationResult}s as outputted by the {@link PoseClassifier}.
  // We run smoothing over this window of size {@link windowSize}.
  final DoubleLinkedQueue<ClassificationResult> __window =
      new DoubleLinkedQueue();

  EMASmoothing(
      [this.__windowSize = __defaultWindowSize, this.__alpha = __defaultAlpha]);

  ClassificationResult getSmoothedResult(
      ClassificationResult classificationResult) {
    // If we are at window size, remove the last (oldest) result.
    if (__window.length == __windowSize) {
      __window.removeLast();
    }
    // Insert at the beginning of the window.
    __window.addFirst(classificationResult);

    Set<String> allClasses = new HashSet();
    for (ClassificationResult result in __window) {
      allClasses.addAll(result.getAllClasses());
    }

    ClassificationResult smoothedResult = new ClassificationResult();

    for (String className in allClasses) {
      double factor = 1;
      double topSum = 0;
      double bottomSum = 0;
      for (ClassificationResult result in __window) {
        double value = result.getClassConfidence(className) ?? 0;

        topSum += factor * value;
        bottomSum += factor;

        factor = factor * (1.0 - __alpha);
      }
      smoothedResult.putClassConfidence(className, topSum / bottomSum);
    }

    return smoothedResult;
  }
}
