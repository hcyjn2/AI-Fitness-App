/**
 * Represents Pose classification result as outputted by {@link PoseClassifier}. Can be manipulated.
 */
class ClassificationResult {
  // For an entry in this map, the key is the class name, and the value is how many times this class
  // appears in the top K nearest neighbors. The value is in range [0, K] and could be a double after
  // EMA smoothing. We use this number to represent the confidence of a pose being in this class.
  late final Map<String, double> __classConfidences;

  ClassificationResult() {
    __classConfidences = new Map();
  }

  Set<String> getAllClasses() {
    Set<String> out = {};

    for (var key in __classConfidences.keys) out.add(key);

    return out;
  }

  double? getClassConfidence(String className) {
    return (__classConfidences.containsKey(className)
        ? __classConfidences[className]
        : 0);
  }

  String getMaxConfidenceClass() {
    double maxValue = -1;
    String maxKey = 'null';
    for (var key in __classConfidences.keys) {
      if (__classConfidences[key]! > maxValue) {
        maxValue = __classConfidences[key] as double;
        maxKey = key;
      }
    }
    return maxKey;
  }

  void incrementClassConfidence(String className) {
    __classConfidences.update(className, (value) => value += 1,
        ifAbsent: () => 1);
  }

  void putClassConfidence(String className, double confidence) {
    __classConfidences[className] = confidence;
  }
}
