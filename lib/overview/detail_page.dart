import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/db_interaction.dart';

class DetailPage extends StatefulWidget {
  final Function rebuild;
  final Verse verse;
  final LearnStatus oldLearnStatus;
  final Function _onItemTapped;
  DetailPage(this.rebuild, this.verse, this.oldLearnStatus, this._onItemTapped);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Future<LearnStatus> learnStatus;
  @override
  void initState() {
    super.initState();
    learnStatus = helper.getLearnStatus(widget.verse.id);
  }

  Future<LearnStatus> changeLearnStatus(
      int id, LearnStatus newLearnStatus) async {
    helper.setLearnStatus(id, newLearnStatus);
    return newLearnStatus;
  }

  Widget createBibleButton() {
    return RaisedButton(
      onPressed: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString("book", widget.verse.book);
        await preferences.setInt("chapter", widget.verse.chapter);
        widget._onItemTapped(2);
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Row(
        children: <Widget>[
          Icon(Icons.forward),
          Text('Im Kontext ansehen'),
        ],
      ),
    );
  }

  Widget createLearnButton() {
    return RaisedButton(
      onPressed: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        List<String> shuffleFromPreferences =
            preferences.getStringList("shuffledList") ?? null;
        if (shuffleFromPreferences == null) {
          List<Verse> verseList = await helper
              .getVersesOnLearnStatus(LearnStatus.current)
              .then((List<Verse> currentVerses) {
            currentVerses.shuffle();
            return currentVerses;
          });
          List<String> idStringList =
              verseList.fold([], (previousValue, element) {
            if (element.id != widget.verse.id) {
              previousValue.add('${element.id}');
            }
            return previousValue;
          });
          idStringList.add('${widget.verse.id}');
          preferences.setStringList("shuffledList", idStringList);
          preferences.setInt("shuffleCounter", idStringList.length);
        } else {
          shuffleFromPreferences.remove("${widget.verse.id}");
          shuffleFromPreferences.add("${widget.verse.id}");
          preferences.setStringList("shuffledList", shuffleFromPreferences);
        }
        widget._onItemTapped(1);
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Row(
        children: <Widget>[
          Icon(Icons.forward),
          Text("Auf Lernseite ansehen"),
        ],
      ),
    );
  }

  List<Widget> createRadioSelection(LearnStatus oldLearnStatus) {
    return <Widget>[
      RadioListTile<LearnStatus>(
        value: LearnStatus.current,
        groupValue: oldLearnStatus,
        onChanged: (LearnStatus learnStatus) async {
          await createSnackBar(
              "${widget.verse.passageString()} wurde zur aktuellen Lernsammlung hinzugefügt",
              context);
          setLearnStatus(widget.verse, learnStatus);
        },
        title: Text("Lernen"),
      ),
      RadioListTile<LearnStatus>(
        value: LearnStatus.selected,
        groupValue: oldLearnStatus,
        onChanged: (LearnStatus learnStatus) async {
          await createSnackBar(
              "${widget.verse.passageString()} wurde zum Lernen vorgemerkt",
              context);
          setLearnStatus(widget.verse, learnStatus);
        },
        title: Text("Vormerken"),
      ),
      RadioListTile<LearnStatus>(
        value: LearnStatus.learned,
        groupValue: oldLearnStatus,
        onChanged: (LearnStatus learnStatus) async {
          await createSnackBar(
              "${widget.verse.passageString()} wurde als bereits gelernt gekennzeichnet",
              context);
          setLearnStatus(widget.verse, learnStatus);
        },
        title: Text("Ich kann diesen Vers schon"),
      ),
    ];
  }

  Widget createButtonBar(LearnStatus oldLearnStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
          child: Text("Abbrechen"),
          onPressed: () {
            setLearnStatus(widget.verse, oldLearnStatus);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: learnStatus,
        builder: (BuildContext context, AsyncSnapshot<LearnStatus> snapshot) {
          Widget body;
          if (snapshot.hasData) {
            List<Widget> listChildren = [createBibleButton()];
            if (snapshot.data == LearnStatus.current)
              listChildren.add(createLearnButton());
            listChildren.addAll(createRadioSelection(snapshot.data));
            listChildren.add(createButtonBar(snapshot.data));
            body = LayoutBuilder(
                builder: (context, BoxConstraints viewPortConstraints) =>
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewPortConstraints.maxHeight),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                                child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(widget.verse.text))),
                            Column(
                              children: listChildren,
                            )
                          ],
                        ),
                      ),
                    ));
          } else if (snapshot.hasError) {
            body = Center(child: Text('${snapshot.error}'));
          } else {
            body = Center(child: Text('Laden...'));
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.verse.passageString()),
            ),
            body: body,
          );
        });
  }

  void setLearnStatus(Verse verse, LearnStatus learnStatus) {
    setState(() {
      this.learnStatus = changeLearnStatus(verse.id, learnStatus);
    });
  }
}

createSnackBar(String text, BuildContext context) {
  Scaffold.of(context).removeCurrentSnackBar();
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: Duration(seconds: 2),
  ));
}
