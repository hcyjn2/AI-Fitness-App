import 'package:fitness_app/constants.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:fitness_app/widgets/custom_elevated_button.dart';
import 'package:fitness_app/widgets/workout_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement extends StatefulWidget {
  const Achievement({Key? key}) : super(key: key);

  @override
  _AchievementState createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  late Future future;

  bool firstStepCheck = false;
  bool champCheck = false;

  bool firstStepDone = false;
  bool champDone = false;

  final _player = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = getFuture();
  }

  Future getFuture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int totalWorkoutDone = prefs.getInt('Total Workout Done') ?? 0;

    totalWorkoutDone >= 1 ? firstStepCheck = true : firstStepCheck = false;
    totalWorkoutDone >= 50 ? champCheck = true : champCheck = false;

    firstStepDone = prefs.getBool('firstStepDone') ?? false;
    champDone = prefs.getBool('champDone') ?? false;
  }

  Future _saveSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('firstStepDone', firstStepDone);
    prefs.setBool('champDone', champDone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/a.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
                child: CustomCard(
                  boxShadow: BoxShadow(
                    color: Colors.black.withOpacity(0.31),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                  color: Color.fromARGB(179, 85, 85, 85),
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            'Achievements',
                            style: TextStyle(
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 80,
                                  color: kAccentColor,
                                ),
                              ],
                              fontFamily: 'Insanibu',
                              fontSize: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GridView.count(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            crossAxisCount: 2,
                            children: <Widget>[
                              firstStepButton(),
                              champButton()
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 390,
                        ),
                        MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 10,
                            color: kSecondaryColor,
                            height: 60,
                            child: Text(
                              '  BACK  ',
                              style: TextStyle(
                                  fontFamily: 'nunito',
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                            })
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                  child: Center(
                      child: Text(
                'Loading...',
                style: TextStyle(
                    fontFamily: 'nunito',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )));
            }
          }),
    ));
  }

  Widget firstStepButton() {
    return CustomElevatedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                radius: 41,
                backgroundColor: Colors.black.withOpacity(0.1),
                child: Image(
                  image: AssetImage('assets/images/first_step.png'),
                  height: 80,
                ),
              ),
            ),
            Text(
              'First Step',
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 0.85,
                  fontFamily: 'Insanibu',
                  fontSize: 21,
                  color: firstStepDone ? kSecondaryColor : Colors.white54),
            ),
          ],
        ),
        gradient: firstStepCheck && firstStepDone
            ? LinearGradient(colors: [
                Colors.white,
                kAccentColor,
              ], begin: Alignment.topRight, end: Alignment.bottomLeft)
            : firstStepCheck
                ? LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft)
                : LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: firstStepDone
            ? BoxShadow(
                color: kAccentColor,
                spreadRadius: 2.5,
                blurRadius: 7,
                offset: Offset(0, 0), // changes position of shadow
              )
            : BoxShadow(
                color: Colors.black26,
                spreadRadius: 2.5,
                blurRadius: 7,
                offset: Offset(0, 5), // changes position of shadow
              ),
        onPressed: () async {
          if (firstStepCheck && !firstStepDone) {
            firstStepDone = true;
            achievementCompleteAlert(2);
          } else if (!firstStepCheck) {
            achievementErrorAlert('Atleast 1 Workout Done');
          } else {}

          await _saveSetting();

          setState(() {});
        });
  }

  Widget champButton() {
    return CustomElevatedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/50_workout.png'),
              height: 105,
            ),
            Text(
              'Champ!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 0.85,
                  fontFamily: 'Insanibu',
                  fontSize: 21,
                  color: champDone ? kSecondaryColor : Colors.white54),
            ),
          ],
        ),
        gradient: champCheck && champDone
            ? LinearGradient(colors: [
                Colors.white,
                kAccentColor,
              ], begin: Alignment.topRight, end: Alignment.bottomLeft)
            : champCheck
                ? LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft)
                : LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: champDone
            ? BoxShadow(
                color: kAccentColor,
                spreadRadius: 2.5,
                blurRadius: 7,
                offset: Offset(0, 0), // changes position of shadow
              )
            : BoxShadow(
                color: Colors.black26,
                spreadRadius: 2.5,
                blurRadius: 7,
                offset: Offset(0, 5), // changes position of shadow
              ),
        onPressed: () async {
          if (champCheck && !champDone) {
            champDone = true;
            achievementCompleteAlert(5);
          } else if (!champCheck) {
            achievementErrorAlert('50 x Workouts');
          } else {}

          await _saveSetting();

          setState(() {});
        });
  }

  Widget achievementCompleteButton() {
    return CustomElevatedButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.2),
              child: Image(
                image: AssetImage('assets/images/pushUp.png'),
                height: 50,
              ),
            ),
            Text(
              'PUSH UP',
              style: TextStyle(
                  fontFamily: 'Insanibu', fontSize: 21, color: kSecondaryColor),
            ),
          ],
        ),
        gradient: LinearGradient(colors: [
          Colors.white,
          kAccentColor,
        ], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: BoxShadow(
          color: kAccentColor,
          spreadRadius: 2.5,
          blurRadius: 7,
          offset: Offset(0, 0), // changes position of shadow
        ),
        onPressed: () {});
  }

  Future achievementCompleteAlert(int experienceReward) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int currentExperience = await prefs.getInt('currentExperience') ?? 0;
    int level = await prefs.getInt('level') ?? 1;
    int experienceUpperBound = getExpUpperBound(level);
    bool isLevelUp = false;

    await _player.setAsset('assets/audios/achievement_complete.mp3');
    _player.play();

    currentExperience = currentExperience + experienceReward;
    await prefs.setInt('currentExperience', currentExperience);

    if (currentExperience == experienceUpperBound) {
      currentExperience = 0;
      level++;
      isLevelUp = true;

      await prefs.setInt('level', level);
      await prefs.setInt('currentExperience', currentExperience);

      Future.delayed(Duration(seconds: 1, milliseconds: 39))
          .whenComplete(() => {
                if (isLevelUp)
                  {
                    _player.setAsset('assets/audios/level_up.mp3'),
                    _player.play(),
                  }
              });
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: kPrimaryColor,
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text('Achievement Completed!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                      'Experience Increased by ' +
                          experienceReward.toString() +
                          '!\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'nunito',
                          fontSize: 19,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold)),
                  isLevelUp ? buildLevelPanel(level) : Container()
                ],
              ),
            ),
            elevation: 20.0,
          );
        });
  }

  Future achievementErrorAlert(String achievementRequirementText) async {
    await _player.setVolume(0.8);
    await _player.setAsset('assets/audios/error.mp3');
    _player.play();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Column(
              children: [
                Image(
                  image: AssetImage('assets/images/cross.png'),
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('You have not completed this Achievement yet !\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'nunito',
                        fontSize: 21.5,
                        color: Colors.black54,
                        fontWeight: FontWeight.w900)),
                WorkoutButton(
                  color: Colors.grey.withOpacity(0.5),
                  elevation: 0,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
                    child: Text(achievementRequirementText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'nunito',
                            fontSize: 23,
                            color: Colors.black,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
            elevation: 20.0,
          );
        });
  }

  Widget buildLevelPanel(int lv) {
    return WorkoutButton(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: lv == 2
                      ? AssetImage('assets/images/lv1.png')
                      : lv == 3
                          ? AssetImage('assets/images/lv2.png')
                          : lv == 4
                              ? AssetImage('assets/images/lv3.png')
                              : AssetImage('assets/images/lv4.png'),
                  height: 70,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    FontAwesomeIcons.arrowRightLong,
                    color: Colors.black54,
                  ),
                ),
                Image(
                  image: lv == 2
                      ? AssetImage('assets/images/lv2.png')
                      : lv == 3
                          ? AssetImage('assets/images/lv3.png')
                          : lv == 4
                              ? AssetImage('assets/images/lv4.png')
                              : AssetImage('assets/images/lv5.png'),
                  height: 70,
                ),
              ],
            ),
            Text('Level Up! \n You are now Level ' + lv.toString() + '!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
