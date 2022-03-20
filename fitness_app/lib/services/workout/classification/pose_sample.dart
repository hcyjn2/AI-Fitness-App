import 'dart:io';
import 'dart:convert';

import 'package:fitness_app/constants.dart';
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
  final PoseClass __poseClass;
  List<PoseLandmark> __embedding = [];

  PoseSample(this.__name, this.__className, this.__landmarks, this.__poseClass) {
    __embedding = PoseEmbedding.getPoseEmbedding(__landmarks, this.__poseClass);
  }

  String get name => __name;

  String get className => __className;

  List<PoseLandmark> get embedding => __embedding;

  static Future<List<String>> readCSV(PoseClass poseClass) async {
    String dataDirectory = '';
    // String dataDirectory = 'assets/data/fitness_pose_samples.csv';

    if(poseClass == PoseClass.classPushUp){
      dataDirectory = 'assets/data/pushup_samples.csv';
    }else if(poseClass == PoseClass.classJumpSquat || poseClass == PoseClass.classSquat){
      dataDirectory = 'assets/data/squat_samples.csv';
    }

    var csv = await rootBundle
        .loadString(dataDirectory)
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
    PoseClass poseClass = classIdentifierToPoseClass(className);

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

    return new PoseSample(name, className, landmarks, poseClass);
  }
}
