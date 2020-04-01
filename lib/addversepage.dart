import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AddVersePage extends StatefulWidget {
  final DataBaseHelper helper;
  final int id;
  final Future<Map<String, bool>> oldLearningStatus;
  AddVersePage(this.helper, this.id) : oldLearningStatus = helper.getLearningStatus(id);
  @override
  _AddVersePageState createState() => _AddVersePageState();
}

class _AddVersePageState extends State<AddVersePage> {
  Future<Map<String, bool>> learnProgress;
  @override
  void initState() {
    super.initState();
    learnProgress = widget.helper.getLearningStatus(widget.id);
  }

  Future<Map<String, bool>> changeLearningStatus(
      int id, Map<String, bool> newLearningStatus) async {
    widget.helper.setLearningStatus(id, newLearningStatus);
    return newLearningStatus;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: learnProgress,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, bool>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = //Column(
            //mainAxisSize: MainAxisSize.min,
            //children: <Widget>[
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  CheckboxListTile(
                    value: snapshot.data["selected"],
                    onChanged: (bool value) {
                      setState(() {
                        learnProgress = changeLearningStatus(widget.id, {
                          "selected": value,
                          "current": snapshot.data["current"],
                          "learned": snapshot.data["learned"],
                        });
                      });
                    },
                    title: Text("Vormerken"),
                    subtitle: snapshot.data["selected"]
                        ? Text("Vers ist zum Lernen vorgemerkt")
                        : Text("Vers ist noch nicht vorgemerkt"),
                  ),
                  CheckboxListTile(
                    value: snapshot.data["current"],
                    onChanged: (bool value) {
                      setState(() {
                        learnProgress = changeLearningStatus(widget.id, {
                          "selected": snapshot.data["selected"],
                          "current": value,
                          "learned": snapshot.data["learned"],
                        });
                      });
                    },
                    title: Text("Lernen"),
                    subtitle: snapshot.data["current"]
                        ? Text("Vers ist in aktueller Lernsammlung enthalten")
                        : Text(
                            "Vers ist in aktueller Lernsammlung nicht enthalten"),
                  ),
                  CheckboxListTile(
                    value: snapshot.data["learned"],
                    onChanged: (bool value) {
                      setState(() {
                        learnProgress = changeLearningStatus(widget.id, {
                          "selected": snapshot.data["selected"],
                          "current": snapshot.data["current"],
                          "learned": value,
                        });
                      });
                    },
                    title: Text("Bereits gelernt"),
                    subtitle: snapshot.data["learned"]
                        ? Text("Du kannst diesen Vers bereits auswendig")
                        : Text("Du kannst diesen Vers noch nicht auswendig"),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton.extended(
                        label: Text("Vers in 'Lernen' ansehen",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Abbrechen"),
                        onPressed: () {
                          widget.oldLearningStatus.then((realOldLearningStatus) {
                            learnProgress = changeLearningStatus(widget.id, realOldLearningStatus);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ],
            //),
            //],
          );
        } else if (snapshot.hasError) {
          result = Text("${snapshot.error}");
        } else {
          result = Text("Awaiting result");
        }
        return result;
      },
    );
  }
}
