import 'package:fitness_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

// Calorie Tracking feature
class ScoreboardScreen extends StatefulWidget {
  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  Map<String, int> records = {};
  late Future future;

  @override
  void initState() {
    super.initState();
    future = _getFuture();
  }

  _getFuture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var existedRecords = prefs.getKeys();

    if (existedRecords.isNotEmpty) {
      for (var record in existedRecords) {
        records.putIfAbsent(record, () => prefs.getInt(record) ?? 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.91,
      width: MediaQuery.of(context).size.width * 0.995,
      child: CustomCard(
          color: kSecondaryColor.withOpacity(0.65),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: Text(
                    'Scoreboard',
                    style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              Container(
                child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            String className = classIdentifierToClassName(
                                records.keys.elementAt(index));
                            String classRepetition =
                                records.values.elementAt(index).toString();

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 20),
                              child: Card(
                                color: kPrimaryColor,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: ListTile(
                                    title: Text(
                                      className,
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    trailing: Text(
                                      classRepetition,
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        height: MediaQuery.of(context).size.height * 0.26,
                        width: double.infinity,
                        color: Colors.transparent,
                      );
                    } else {
                      return Text('Loading...');
                    }
                  },
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Align(
                    alignment: Alignment.bottomCenter,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Reset Scoreboard',
                                style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ))),
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.clear();

                              future = _getFuture();
                              setState(() {});
                            }),
                      ],
                    )),
              ))
            ],
          )),
    );
  }
}
