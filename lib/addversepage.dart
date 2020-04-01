import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AddVersePage extends StatefulWidget {
  final DataBaseHelper helper;
  final Verse verse;
  final Future<LearnStatus> oldLearnStatus;
  final Function _onItemTapped;
  final Map<String, String> short2long;
  AddVersePage(this.helper, this.verse, this._onItemTapped, this.short2long) : oldLearnStatus = helper.getLearnStatus(verse.id);
  @override
  _AddVersePageState createState() => _AddVersePageState();
}

class _AddVersePageState extends State<AddVersePage> {
  Future<LearnStatus> learnStatus;
  @override
  void initState() {
    super.initState();
    learnStatus = widget.helper.getLearnStatus(widget.verse.id);
  }

  Future<LearnStatus> changeLearnStatus(int id, LearnStatus newLearnStatus) async {
    widget.helper.setLearnStatus(id, newLearnStatus);
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
                  Text(
                    "${widget.short2long[widget.verse.book]} ${widget.verse.chapter}, ${widget.verse.verse}",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.none,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) {
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });
                    },
                    title: Text("Nicht auswählen"),
                    subtitle: snapshot.data == LearnStatus.none
                        ? Text("Vers ist überhaupt nicht ausgewählt")
                        : Text("Vers ist ausgewählt"),
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
                    subtitle: snapshot.data == LearnStatus.selected
                        ? Text("Vers ist zum Lernen vorgemerkt")
                        : Text("Vers ist noch nicht vorgemerkt"),
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
                    subtitle: snapshot.data == LearnStatus.current
                        ? Text("Vers ist in aktueller Lernsammlung enthalten")
                        : Text(
                            "Vers ist in aktueller Lernsammlung nicht enthalten"),
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.learned,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) {
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });
                    },
                    title: Text("Bereits gelernt"),
                    subtitle: snapshot.data == LearnStatus.learned
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
                        onPressed: () {
                          Navigator.pop(context);
                          widget._onItemTapped(1);
                        },
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
          result = Text("Awaiting result");
        }
        return result;
      },
    );
  }
}
