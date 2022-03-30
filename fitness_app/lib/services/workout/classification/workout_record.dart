import 'dart:convert';

class WorkoutRecord {
  final DateTime dateTime;
  final String exerciseClass;
  final int exerciseRepetition;

  WorkoutRecord(
      {required this.dateTime,
      required this.exerciseClass,
      required this.exerciseRepetition});

  factory WorkoutRecord.fromJson(Map<String, dynamic> jsonData) {
    return WorkoutRecord(
        dateTime: DateTime.parse(jsonData['dateTime']),
        exerciseClass: jsonData['exerciseClass'],
        exerciseRepetition: jsonData['exerciseRepetition']);
  }

  static Map<String, dynamic> toJson(WorkoutRecord workoutRecord) => {
        'dateTime': workoutRecord.dateTime.toString(),
        'exerciseClass': workoutRecord.exerciseClass,
        'exerciseRepetition': workoutRecord.exerciseRepetition
      };

  static String encode(List<WorkoutRecord> workoutRecordList) => json.encode(
        workoutRecordList
            .map<Map<String, dynamic>>(
                (workoutRecord) => WorkoutRecord.toJson(workoutRecord))
            .toList(),
      );

  static List<WorkoutRecord> decode(String workoutRecordList) =>
      (json.decode(workoutRecordList) as List<dynamic>)
          .map<WorkoutRecord>((item) => WorkoutRecord.fromJson(item))
          .toList();
}
