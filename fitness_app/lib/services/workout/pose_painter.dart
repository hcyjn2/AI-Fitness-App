import 'dart:ui';

import 'package:fitness_app/constants.dart';
import 'package:flutter/material.dart';
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
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0
      ..color = Colors.transparent;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0
      ..color = Color(0x45FFFFFF);

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0
      ..color = Color(0x45FFFFFF);

    /*
      Joint Angle Test
     */
    // final testPaint = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 30.0
    //   ..color = Colors.red;
    //
    // void paintLine(
    //     PoseLandmark lm1, PoseLandmark lm2, Paint paintType) {
    //   PoseLandmark joint1 = lm1;
    //   PoseLandmark joint2 = lm2;
    //   canvas.drawLine(
    //       Offset(translateX(joint1.x, rotation, size, absoluteImageSize),
    //           translateY(joint1.y, rotation, size, absoluteImageSize)),
    //       Offset(translateX(joint2.x, rotation, size, absoluteImageSize),
    //           translateY(joint2.y, rotation, size, absoluteImageSize)),
    //       paintType);
    // }
    //
    // Pose A = poses.first;
    //
    // PoseLandmark testPose1 = A.landmarks.values.elementAt(PoseLandmarkType.rightHip.index);
    // PoseLandmark testPose2 = A.landmarks.values.elementAt(PoseLandmarkType.rightKnee.index);
    // PoseLandmark testPose3 = A.landmarks.values.elementAt(PoseLandmarkType.rightAnkle.index);
    //
    // int angle;
    //
    // canvas.drawCircle(
    //     Offset(
    //       translateX(testPose1.x, rotation, size, absoluteImageSize),
    //       translateY(testPose1.y, rotation, size, absoluteImageSize),
    //     ),
    //     1,
    //     testPaint);
    //
    // canvas.drawCircle(
    //     Offset(
    //       translateX(testPose2.x, rotation, size, absoluteImageSize),
    //       translateY(testPose2.y, rotation, size, absoluteImageSize),
    //     ),
    //     1,
    //     testPaint);
    //
    // canvas.drawCircle(
    //     Offset(
    //       translateX(testPose3.x, rotation, size, absoluteImageSize),
    //       translateY(testPose3.y, rotation, size, absoluteImageSize),
    //     ),
    //     1,
    //     testPaint);
    //
    // paintLine(testPose1, testPose2, leftPaint);
    // paintLine(testPose2, testPose3, leftPaint);
    //
    // angle = PoseEmbedding.getJointAngle(testPose1, testPose2, testPose3);
    //
    // String angleText = angle.toString();
    //
    // TextPainter angleTextPaint = new TextPainter()
    //   ..text = new TextSpan(
    //     text: angleText,
    //     style: GoogleFonts.nunito(
    //         textStyle: TextStyle(fontSize: 80, fontWeight: FontWeight.w900),
    //         color: Colors.redAccent,
    //         background: Paint()
    //           ..strokeWidth = 70.0
    //           ..color = Colors.transparent
    //           ..style = PaintingStyle.stroke
    //           ..strokeJoin = StrokeJoin.round),
    //   )
    //   ..textDirection = TextDirection.ltr;
    //
    // angleTextPaint.layout();
    //
    // final xCenter = testPose2.x;
    // final yCenter = testPose2.y;
    // final offset = Offset(xCenter - 20, yCenter);
    // angleTextPaint.paint(canvas, offset);

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

    String classificationResultText = 'Come on! You can do it !';
    String adviceText = '';
    bool properForm = true;

    if (resultClass.isNotEmpty) {
      String className = classIdentifierToClassName(resultClass.last);
      String classRepetition = resultRep.last.toString();

      if (isValidClass(resultClass.last)) {
        properForm = true;
        classificationResultText = className + '  :  ' + classRepetition;
      } else if (classIdentifierToPoseClass(resultClass.last) ==
          PoseClass.classSquatBackSlouching) {
        properForm = false;
        adviceText = 'Try to Straighten your Back!';
      } else if (classIdentifierToPoseClass(resultClass.last) ==
          PoseClass.classSquatHalfRep) {
        properForm = false;
        adviceText = 'Go even Lower than that!';
      } else if (classIdentifierToPoseClass(resultClass.last) ==
          PoseClass.classJumpingJackBentArm) {
        properForm = false;
        adviceText = 'Keep your Elbows Straight!';
      } else if (classIdentifierToPoseClass(resultClass.last) ==
          PoseClass.classPushUpBackSlouching) {
        properForm = false;
        adviceText = 'Keep your back Straight!';
      }
    }

    TextPainter classificationTextPaint = new TextPainter()
      ..text = (properForm == true)
          ? new TextSpan(
              text: classificationResultText,
              style: TextStyle(
                  fontFamily: 'nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  background: Paint()
                    ..strokeWidth = 50.0
                    ..color = Colors.black.withOpacity(0.7)
                    ..style = PaintingStyle.stroke
                    ..strokeJoin = StrokeJoin.round),
            )
          : new TextSpan(
              text: adviceText,
              style: TextStyle(
                  fontFamily: 'nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  background: Paint()
                    ..strokeWidth = 50.0
                    ..color = Colors.deepOrangeAccent.withOpacity(0.7)
                    ..style = PaintingStyle.stroke
                    ..strokeJoin = StrokeJoin.round),
            )
      ..textDirection = TextDirection.ltr;

    classificationTextPaint.layout();

    final xCenter = (size.width - classificationTextPaint.width) / 2;
    final yCenter = (size.height - classificationTextPaint.height) * 0.93;
    final offset = Offset(xCenter, yCenter);
    classificationTextPaint.paint(canvas, offset);

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
