import 'dart:io';
import 'dart:convert';

import 'package:fitness_app/services/workout/classification/pose_embedding.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

/**
 * Reads Pose samples from a csv file.
 */

const tag = "PoseSample";

//x1,y1,z1 * 33 positions
const numOfLandmarks = 33;
const numOfDims = 3;

class PoseSample {
  final String __name;
  final String __className;
  final List<PoseLandmark> __landmarks;
  List<PoseLandmark> __embedding = [];

  PoseSample(this.__name, this.__className, this.__landmarks) {
    __embedding = PoseEmbedding.getPoseEmbedding(__landmarks);
  }

  String get name => __name;

  String get className => __className;

  List<PoseLandmark> get embedding => __embedding;

  //#TODO Might be wrong
  static Future<List<String>> readCSV() async {
    var csv = await rootBundle
        .loadString('assets/data/fitness_pose_samples.csv')
        .asStream()
        .transform(new LineSplitter())
        .toList();
    return csv;
  }

  static Future<PoseSample> getPoseSample(String csvDataRow) async {
    List<String> row = csvDataRow.split(',');

    String name = row[0];
    String className = row[1];
    List<PoseLandmark> landmarks = [];

    if (row.length != (numOfLandmarks * numOfDims) + 2) {
      // Log.e(tag, "Invalid number of tokens for PoseSample");
      print(tag + "Invalid number of tokens for PoseSample");
      exit(1);
    }

    for (int i = 2; i < row.length; i += numOfDims) {
      int poseLandmarkTypeIndex = 0;
      try {
        landmarks.add(PoseLandmark(
            PoseLandmarkType.values.elementAt(poseLandmarkTypeIndex),
            double.parse(row[i]),
            double.parse(row[i + 1]),
            double.parse(row[i + 2]),
            0));

        poseLandmarkTypeIndex += 1;
      } catch (e) {
        // Log.e(tag, "Invalid value " + tokens.get(i) + " for landmark position.");
        print(e.toString() +
            '\n\n' +
            tag +
            "Invalid value " +
            row[i] +
            " for landmark position.");
        exit(2);
      }
    }

    return new PoseSample(name, className, landmarks);
  }

// static Future<PoseSample> getPoseSample(
//     String csvLine, String separator) async {
//   var row = await readCSV();
//
//   String name = row[0];
//   String className = row[1];
//   List<PoseLandmark> landmarks = [];
//
//   if (row != (numOfLandmarks * numOfDims) + 2) {
//     // Log.e(tag, "Invalid number of tokens for PoseSample");
//     print(tag + "Invalid number of tokens for PoseSample");
//     exit(1);
//   }
//
//   for (int i = 2; i < row.length; i += numOfDims) {
//     try {
//       landmarks.add(PoseLandmark(
//           PoseLandmarkType.values.elementAt(i - 2),
//           double.parse(row[i]),
//           double.parse(row[i + 1]),
//           double.parse(row[i + 2]),
//           0));
//     } catch (e) {
//       // Log.e(tag, "Invalid value " + tokens.get(i) + " for landmark position.");
//       print(e.toString() +
//           '\n\n' +
//           tag +
//           "Invalid value " +
//           row[i] +
//           " for landmark position.");
//       exit(2);
//     }
//   }
//
//   return new PoseSample(name, className, landmarks);
// }

  // List<String> tokens = csvLine.split(separator);
  // // Format is expected to be Name,Class,X1,Y1,Z1,X2,Y2,Z2...
  // // + 2 is for Name & Class.
  // if (tokens.length != (numOfLandmarks * numOfDims) + 2) {
  //   // Log.e(tag, "Invalid number of tokens for PoseSample");
  //   print(tag + "Invalid number of tokens for PoseSample");
  //   exit(1);
  // }
  // String name = tokens.elementAt(0);
  // String className = tokens.elementAt(1);
  // List<PoseLandmark> landmarks = [];
  //
  // //#TODO line48 might not be 0 but the likelihood of the landmark
  // // Read from the third token, first 2 tokens are name and class.
  // for (int i = 2; i < tokens.length; i += numOfDims) {
  //   try {
  //     landmarks.add(PoseLandmark(
  //         PoseLandmarkType.values.elementAt(i - 2),
  //         double.parse(tokens.elementAt(i)),
  //         double.parse(tokens.elementAt(i + 1)),
  //         double.parse(tokens.elementAt(i + 2)),
  //         0));
  //   } on NullThrownError {
  //     // Log.e(tag, "Invalid value " + tokens.get(i) + " for landmark position.");
  //     print(tag +
  //         "Invalid value " +
  //         tokens.elementAt(i) +
  //         " for landmark position.");
  //     exit(2);
  //   }
  // }

}
