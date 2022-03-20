import 'dart:convert';

class BestRecord {
  final String exerciseClass;
  int exerciseRepetition;

  BestRecord({required this.exerciseClass, required this.exerciseRepetition});

  factory BestRecord.fromJson(Map<String, dynamic> jsonData) {
    return BestRecord(
        exerciseClass: jsonData['exerciseClass'],
        exerciseRepetition: jsonData['exerciseRepetition']);
  }

  static Map<String, dynamic> toJson(BestRecord bestRecord) => {
        'exerciseClass': bestRecord.exerciseClass,
        'exerciseRepetition': bestRecord.exerciseRepetition
      };

  static String encode(List<BestRecord> bestRecordList) => json.encode(
        bestRecordList
            .map<Map<String, dynamic>>(
                (bestRecord) => BestRecord.toJson(bestRecord))
            .toList(),
      );

  static List<BestRecord> decode(String bestRecordList) =>
      (json.decode(bestRecordList) as List<dynamic>)
          .map<BestRecord>((item) => BestRecord.fromJson(item))
          .toList();
}
