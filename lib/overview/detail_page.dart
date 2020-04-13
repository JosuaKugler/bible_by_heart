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
  Future<Verse> verse;
  @override
  void initState() {
    super.initState();
    verse = helper.getVerseFromId(widget.verse.id);
  }

  Future<Verse> changeLearnStatus (
      int id, LearnStatus newLearnStatus) async {
    helper.setLearnStatus(id, newLearnStatus);
    return await helper.getVerseFromId(widget.verse.id);
  }

  Widget createLearnProgressBar(int correct, int maxCorrect) {
    //Future<int> correct = helper.getCorrect(widget.verse.id);
    //Future<int> maxCorrect = helper.getMaxCorrect(widget.verse.id);
    return ListTile(
      leading: Icon(Icons.trending_up),
      title: Text('Lernfortschritt: $correct / $maxCorrect'),
      subtitle: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            flex: correct,
            child: Container(
              height: 20,
              color: Colors.green,
            ),
          ),
          Flexible(
            flex: maxCorrect - correct,
            child: Container(
              height: 20,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  Widget createBibleButton() {
    return GestureDetector(
      onTap: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString("book", widget.verse.book);
        await preferences.setInt("chapter", widget.verse.chapter);
        widget._onItemTapped(2);
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(widget.verse.text),
        )
      )
    );
  }

  Widget createLearnButton() {
    return GestureDetector(
      onTap: () async {
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
      child: ListTile(
          leading: Icon(Icons.forward),
          title: Text("Auf Lernseite ansehen"),
      ),
    );
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

  Widget createSetLStoNone() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.delete),
        title: Text("Lernstatus löschen"),
        subtitle: Text("Vers wird aus 'vorgemerkt', 'Lernen' oder 'bereits gelernt' entfernt"),
      ),
      onTap: () => setLearnStatus(widget.verse, LearnStatus.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: verse,//change to verse
        builder: (BuildContext context, AsyncSnapshot<Verse> snapshot) {
          Widget body;
          if (snapshot.hasData) {
            body = LayoutBuilder(
                builder: (context, BoxConstraints viewPortConstraints) =>
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewPortConstraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                  child: createBibleButton(),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (snapshot.data.learnStatus == LearnStatus.current) createLearnProgressBar(snapshot.data.correct, snapshot.data.maxCorrect),
                                  if (snapshot.data.learnStatus == LearnStatus.current) createLearnButton(),
                                  createSetLStoNone(),
                                  RadioListTile<LearnStatus>(
                                    value: LearnStatus.current,
                                    groupValue: snapshot.data.learnStatus,
                                    onChanged: (LearnStatus learnStatus) async {
                                      //print("onchanged was called!");
                                      await createSnackBar(
                                          "${widget.verse.passageString()} wurde zur aktuellen Lernsammlung hinzugefügt",
                                          context);
                                      setLearnStatus(widget.verse, learnStatus);
                                    },
                                    title: Text("Lernen"),
                                  ),
                                  RadioListTile<LearnStatus>(
                                    value: LearnStatus.selected,
                                    groupValue: snapshot.data.learnStatus,
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
                                    groupValue: snapshot.data.learnStatus,
                                    onChanged: (LearnStatus learnStatus) async {
                                      await createSnackBar(
                                          "${widget.verse.passageString()} wurde als bereits gelernt gekennzeichnet",
                                          context);
                                      setLearnStatus(widget.verse, learnStatus);
                                    },
                                    title: Text("Ich kann diesen Vers schon"),
                                  ),
                                  createButtonBar(snapshot.data.learnStatus),
                                ],
                              )
                            ],
                          ),
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
      this.verse = changeLearnStatus(verse.id, learnStatus);
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
