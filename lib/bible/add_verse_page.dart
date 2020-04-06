import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../backend/db_interaction.dart';

class AddVersePage extends StatefulWidget {
  final Verse verse;
  final Future<LearnStatus> oldLearnStatus;
  final BuildContext scaffoldContext;
  final bool showHeaderBool;
  AddVersePage(this.verse, this.showHeaderBool, {this.scaffoldContext}) : oldLearnStatus = helper.getLearnStatus(verse.id);
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
                  if (widget.showHeaderBool) Container(height: 10,),
                  if (widget.showHeaderBool) Text(widget.verse.passageString(),
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.current,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) async {
                      await createSnackBar("${widget.verse.passageString()} wurde zur aktuellen Lernsammlung hinzugefügt", context);
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });

                    },
                    title: Text("Lernen"),
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.selected,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) async {
                      await createSnackBar("${widget.verse.passageString()} wurde zum Lernen vorgemerkt", context);
                      setState(() {
                        this.learnStatus = changeLearnStatus(widget.verse.id, learnStatus);
                      });
                    },
                    title: Text("Vormerken"),
                  ),
                  RadioListTile<LearnStatus>(
                    value: LearnStatus.learned,
                    groupValue: snapshot.data,
                    onChanged: (LearnStatus learnStatus) async {
                      await createSnackBar("${widget.verse.passageString()} wurde als bereits gelernt gekennzeichnet", context);
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

  Future createSnackBar(String text, BuildContext context) async {
    var thisContext;
    if (widget.scaffoldContext == null) {
      thisContext = context;
    } else {
      thisContext = widget.scaffoldContext;
    }
    Scaffold.of(thisContext).removeCurrentSnackBar();
    LearnStatus oldLearnStatus = await widget.oldLearnStatus.then((value) => value);
    Scaffold.of(thisContext).showSnackBar(SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: "Rückgängig",
        onPressed: () {
          helper.setLearnStatus(widget.verse.id, oldLearnStatus);
          if (widget.scaffoldContext == null) {//then you still are in the same context
            setState(() {
              Function temp = () async => oldLearnStatus; //trick to turn value into future
              this.learnStatus = temp();
            });
          }
        },
      ),
    ));
  }
}
