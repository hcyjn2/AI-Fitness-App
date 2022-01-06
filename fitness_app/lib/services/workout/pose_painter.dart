import 'dart:ui';

import 'package:fitness_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'coordinates_translator.dart';

final double poseClassificationTextSize = 60.0;
final bool showInFrameLikelihood = true;

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation,
      this.resultClass, this.resultRep);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final List<String> resultClass;
  final List<int> resultRep;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    poses.forEach((pose) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(landmark.x, rotation, size, absoluteImageSize),
              translateY(landmark.y, rotation, size, absoluteImageSize),
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        PoseLandmark joint1 = pose.landmarks[type1]!;
        PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
                translateY(joint1.y, rotation, size, absoluteImageSize)),
            Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
                translateY(joint2.y, rotation, size, absoluteImageSize)),
            paintType);
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(
          PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle, rightPaint);
    });

    if (resultClass.isNotEmpty) {
      // double classificationX = poseClassificationTextSize * 0.5;
      // double classificationY = -poseClassificationTextSize *
      //     1.5 *
      //     classificationResult.elementAt(0).length;
      var width = window.physicalSize.width;
      var height = window.physicalSize.height;

      String className = classIdentifierToClassName(resultClass.last);
      String classRepetition = resultRep.last.toString();

      String classificationResultText =
          className + ' : ' + classRepetition + ' reps.';

      TextPainter classificationTextPaint = new TextPainter()
        ..text = new TextSpan(
          text: classificationResultText,
          style: GoogleFonts.nunito(
              textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              color: Colors.white,
              background: Paint()
                ..strokeWidth = 50.0
                ..color = kPrimaryColor
                ..style = PaintingStyle.stroke
                ..strokeJoin = StrokeJoin.round),
        )
        ..textDirection = TextDirection.ltr;

      classificationTextPaint.layout();

      final xCenter = (size.width - classificationTextPaint.width) / 2;
      final yCenter = (size.height - classificationTextPaint.height) * 0.90;
      final offset = Offset(xCenter, yCenter);
      classificationTextPaint.paint(canvas, offset);
    }

    // Classification Confidence
    // for (var pose in poses) {
    //   for (PoseLandmark landmark in pose.landmarks.values) {
    //     // Draw inFrameLikelihood for all points
    //     if (showInFrameLikelihood)
    //       TextPainter(text: TextSpan(text: landmark.likelihood.toString()))
    //           .paint(canvas, Offset(landmark.x, landmark.y));
    //   }
    // }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
