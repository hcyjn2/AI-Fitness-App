import 'dart:core';
import 'dart:math';

import 'package:fitness_app/services/workout/classification/classification_result.dart';
import 'package:fitness_app/services/workout/classification/ema_smoothing.dart';
import 'package:fitness_app/services/workout/classification/pose_classifier.dart';
import 'package:fitness_app/services/workout/classification/pose_sample.dart';
import 'package:fitness_app/services/workout/classification/repetition_counter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tuple/tuple.dart';
import 'package:fitness_app/constants.dart';
import 'package:just_audio/just_audio.dart';

const tag = "PoseClassifierProcessor";

class PoseClassifierProcessor {
  bool __isStreamMode;
  bool __narration;
  late EMASmoothing __emaSmoothing;
  late List<RepetitionCounter> __repCounters;
  late PoseClassifier __poseClassifier;
  late String __lastRepResult;
  late List<PoseSample> __poseSamples;
  late List<String> resultClass;
  late List<int> resultRep;
  final PoseClass __poseClass;
  bool effect = false;
  final _player = AudioPlayer();

  PoseClassifierProcessor(this.__isStreamMode, this.__poseSamples,
      this.__poseClass, this.__narration) {
    if (__isStreamMode) {
      __emaSmoothing = new EMASmoothing();
      __repCounters = [];
      __lastRepResult = '';
      resultClass = [];
      resultRep = [];

      __poseClassifier = new PoseClassifier(__poseSamples, __poseClass);

      for (String className in poseClasses) {
        __repCounters.add(new RepetitionCounter(className));
      }
    }
  }

  void loadPoseSamples() async {
    List<PoseSample> poseSamples = [];

    List<String> csvData = await PoseSample.readCSV(__poseClass);

    for (var row in csvData)
      poseSamples.add(await PoseSample.getPoseSample(row));

    __poseClassifier = new PoseClassifier(__poseSamples, __poseClass);

    if (__isStreamMode) {
      for (String className in poseClasses) {
        __repCounters.add(new RepetitionCounter(className));
      }
    }
  }

  /**
     * Given a new {@link Pose} input, returns a list of formatted {@link String}s with Pose
     * classification results.
     *
     * <p>Currently it returns up to 2 strings as following:
     * 0: PoseClass : X reps
     * 1: PoseClass : [0.0-1.0] confidence
     */

  Future<Tuple3<List<String>, List<String>, List<int>>> getPoseResult(
      Pose pose) async {
    List<String> classificationResult = [];

    Tuple3<List<String>, List<String>, List<int>> resultTuple =
        Tuple3([], [], []);

    ClassificationResult classification = __poseClassifier.classifyPose(pose);

    // Update RepetitionCounter if isStreamMode.
    if (__isStreamMode) {
      // Feed pose to smoothing even if no pose found.
      classification = __emaSmoothing.getSmoothedResult(classification);

      // Return early without updating repCounter if no pose found.
      if (pose.landmarks.isEmpty) {
        classificationResult.add(__lastRepResult);
        resultTuple.item1.addAll(classificationResult);
        resultTuple.item2.addAll(resultClass);
        resultTuple.item3.addAll(resultRep);
        return resultTuple;
      }

      for (RepetitionCounter repCounter in __repCounters) {
        int repsBefore = repCounter.numRepeats;
        int repsAfter = repCounter.addClassificationResult(classification);
        if (repsAfter > repsBefore) {
          resultClass.add(repCounter.className);
          resultRep.add(repsAfter);

          // Play Advice Audio
          if (__narration) {
            if (classIdentifierToPoseClass(repCounter.className) ==
                PoseClass.classJumpingJackBentArm) {
              await _player.setAsset('assets/audios/bentarm_female.mp3');
            } else if (classIdentifierToPoseClass(repCounter.className) ==
                PoseClass.classSquatHalfRep) {
              await _player.setAsset('assets/audios/halfrep_female.mp3');
            } else if (classIdentifierToPoseClass(repCounter.className) ==
                PoseClass.classSquatBackSlouching) {
              Random().nextInt(2) == 1
                  ? await _player
                      .setAsset('assets/audios/backslouch_female.mp3')
                  : await _player
                      .setAsset('assets/audios/pushupbackslouch_female.mp3');
            } else if (classIdentifierToPoseClass(repCounter.className) ==
                PoseClass.classPushUpBackSlouching) {
              Random().nextInt(2) == 1
                  ? await _player
                      .setAsset('assets/audios/pushupbackslouch_female.mp3')
                  : await _player.setAsset(
                      'assets/audios/pushupbackslouch_alt_female.mp3');
            }

            // Play Repetition Counting Audio
            if (isValidClass(repCounter.className)) {
              if (repsAfter == 1) {
                await _player.setAsset('assets/audios/one_female.mp3');
              } else if (repsAfter == 2) {
                await _player.setAsset('assets/audios/two_female.mp3');
              } else if (repsAfter == 3) {
                await _player.setAsset('assets/audios/three_female.mp3');
              } else if (repsAfter == 4) {
                await _player.setAsset('assets/audios/four_female.mp3');
              } else if (repsAfter == 5) {
                Random().nextInt(2) == 1
                    ? await _player.setAsset('assets/audios/five_female.mp3')
                    : await _player
                        .setAsset('assets/audios/five_alt_female.mp3');
              } else if (repsAfter == 6) {
                await _player.setAsset('assets/audios/six_female.mp3');
              } else if (repsAfter == 7) {
                await _player.setAsset('assets/audios/seven_female.mp3');
              } else if (repsAfter == 8) {
                await _player.setAsset('assets/audios/eight_female.mp3');
              } else if (repsAfter == 9) {
                await _player.setAsset('assets/audios/nine_female.mp3');
              } else if (repsAfter == 10) {
                Random().nextInt(2) == 1
                    ? await _player.setAsset('assets/audios/ten_female.mp3')
                    : Random().nextInt(2) == 2
                        ? await _player
                            .setAsset('assets/audios/ten_alt1_female.mp3')
                        : await _player
                            .setAsset('assets/audios/ten_alt2_female.mp3');
              } else if (repsAfter == 11) {
                await _player.setAsset('assets/audios/eleven_female.mp3');
              } else if (repsAfter == 12) {
                await _player.setAsset('assets/audios/twelve_female.mp3');
              } else if (repsAfter == 13) {
                await _player.setAsset('assets/audios/thirteen_female.mp3');
              } else if (repsAfter == 15) {
                await _player.setAsset('assets/audios/fourteen_female.mp3');
              } else if (repsAfter == 16) {
                await _player.setAsset('assets/audios/fifteen_female.mp3');
              } else {
                await _player.setAsset('assets/audios/ding.mp3');
              }
            }
            _player.play();
          }

          __lastRepResult =
              (repCounter.className + ' : ' + repsAfter.toString() + ' reps');

          break;
        }
      }
      classificationResult.add(__lastRepResult);

      // Add maxConfidence class of current frame to result if pose is found.
      if (pose.landmarks.isNotEmpty) {
        String maxConfidenceClass = classification.getMaxConfidenceClass();
        String maxConfidenceClassResult = (maxConfidenceClass +
            ' : ' +
            (classification.getClassConfidence(maxConfidenceClass)! /
                    __poseClassifier.confidenceRange())
                .toString() +
            ' confidence');
        classificationResult.add(maxConfidenceClassResult);
      }
    }

    resultTuple.item1.addAll(classificationResult);
    resultTuple.item2.addAll(resultClass);
    resultTuple.item3.addAll(resultRep);

    return resultTuple;
  }

  void stop() {
    __isStreamMode = false;
  }
}
