import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../backend/db_interaction.dart';

class AddVersePage extends StatefulWidget {
  final Verse verse;
  final Future<LearnStatus> oldLearnStatus;
  final Function _onItemTapped;
  AddVersePage(this.verse, this._onItemTapped) : oldLearnStatus = helper.getLearnStatus(verse.id);
  @override
  _AddVersePageState createState() => _AddVersePageState();
}

class _AddVersePageState extends State<AddVersePage> {
  Future<LearnStatus> learnStatus;
  @override
  void initState() {
    super.initState();
    learnStatus = helper.getLearnStatus(widget.verse.id);
  }

  Future<LearnStatus> changeLearnStatus(int id, LearnStatus newLearnStatus) async {
    helper.setLearnStatus(id, newLearnStatus);
    return newLearnStatus;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: learnStatus,
      builder:
          (BuildContext context, AsyncSnapshot<LearnStatus> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Container(height: 10,),
                  Text(widget.verse.passageString(),
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.current,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) {
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });
                    },
                    title: Text("Lernen"),
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.selected,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) {
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });
                    },
                    title: Text("Vormerken"),
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.learned,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) {
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });
                    },
                    title: Text("Ich kann diesen Vers schon"),
                  ),



                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Abbrechen"),
                        onPressed: () {
                          widget.oldLearnStatus.then((realOldLearnStatus) {
                            learnStatus = changeLearnStatus(widget.verse.id, realOldLearnStatus);
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
          );
        } else if (snapshot.hasError) {
          result = Text("${snapshot.error}");
        } else {
          result = Text("Laden...");
        }
        return result;
      },
    );
  }
}
