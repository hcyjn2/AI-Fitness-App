import 'package:fitness_app/constants.dart';
import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late Future future;
  bool narration = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = getFuture();
  }

  Future getFuture() async {
    narration = await _getNarration();
  }

  Future _getNarration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var bool = await prefs.getBool('narration')!;

    return bool;
  }

  Future _saveSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('narration', narration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 100, horizontal: 15),
                  child: CustomCard(
                    boxShadow: BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                    color: Colors.white,
                    child: Container(
                      height: 600,
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontFamily: 'Insanibu',
                                fontSize: 49,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              'NARRATOR',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 30,
                                color: Colors.black45,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(
                                        0, 0), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: ToggleSwitch(
                                minWidth: 90.0,
                                minHeight: 70.0,
                                initialLabelIndex: narration ? 1 : 0,
                                cornerRadius: 20.0,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                inactiveFgColor: Colors.white70,
                                totalSwitches: 2,
                                icons: [
                                  FontAwesomeIcons.volumeOff,
                                  FontAwesomeIcons.volumeHigh,
                                ],
                                iconSize: 30.0,
                                activeBgColors: [
                                  [Colors.black45],
                                  [kPrimaryColor, kAccentColor]
                                ],
                                animate: true,
                                animationDuration: 300,
                                curve: Curves.easeInOutCubic,
                                // animate must be set to true when using custom curve
                                onToggle: (index) {
                                  index == 1
                                      ? narration = true
                                      : narration = false;
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              height: 45,
                            ),
                            narration
                                ? Text(
                                    'NARRATOR\nTYPE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 30,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 15,
                            ),
                            narration
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: ToggleSwitch(
                                      minWidth: 90.0,
                                      minHeight: 70.0,
                                      initialLabelIndex: 1,
                                      cornerRadius: 20.0,
                                      activeFgColor: Colors.white,
                                      inactiveBgColor: Colors.grey,
                                      inactiveFgColor: Colors.white70,
                                      totalSwitches: 2,
                                      icons: [
                                        FontAwesomeIcons.male,
                                        FontAwesomeIcons.female,
                                      ],
                                      iconSize: 80.0,
                                      activeBgColors: [
                                        [Colors.blue, Colors.blueAccent],
                                        [Colors.pinkAccent, Colors.pink]
                                      ],
                                      animate: true,
                                      animationDuration: 300,
                                      curve: Curves.easeInOutCubic,
                                      // animate must be set to true when using custom curve
                                      onToggle: (index) {
                                        print('switched to: $index');
                                      },
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: narration ? 50 : 210,
                            ),
                            MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 10,
                                color: kSecondaryColor,
                                height: 60,
                                child: Text(
                                  '  SAVE  ',
                                  style: TextStyle(
                                      fontFamily: 'nunito',
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                                ),
                                onPressed: () async {
                                  await _saveSetting();
                                  Navigator.pop(context);
                                })
                          ],
                        ),
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
            }));
  }
}
