import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';

class CueCard extends StatefulWidget {
  final List<Verse> currentVersesShuffle;
  final Function currentVerseLearned;
  final Function currentVerseWrong;
  final Function continueCurrentVerse;
  final Function finishCurrentVerse;
  final Function continueCurrentVerseAnyway;

  CueCard(
      this.currentVersesShuffle,
      this.currentVerseLearned,
      this.currentVerseWrong,
      this.continueCurrentVerse,
      this.finishCurrentVerse,
      this.continueCurrentVerseAnyway);

  @override
  _CueCardState createState() => _CueCardState();
}

class _CueCardState extends State<CueCard> {
  bool maxReached;
  bool front;

  @override
  void initState() {
    super.initState();
    maxReached = false;
    front = true;
  }

  void _learned(bool yes) {
    if (yes) {
      widget.finishCurrentVerse();
    } else {
      widget.continueCurrentVerse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (widget.currentVersesShuffle.length == 0) {
      result = Container(
        child: Center(child: Text('keine Lernverse')),
      );
    } else if (maxReached) {
      Verse verse = widget.currentVersesShuffle.last;
      result = Container(
        color: Colors.amber,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Glückwunsch!",
              style: TextStyle(fontSize: 40),
            ),
            Text(
              "Der Vers",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${short2long[verse.book]} ${verse.chapter}, ${verse.verse}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "war die letzen 10 Mal",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "Richtig!",
              style: TextStyle(fontSize: 30),
            ),
            Container(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: () async {
                    final int newMaxCorrect = await showDialog<int>(
                      context: context,
                      builder: (context) => NewMaxCorrectDialog(),
                    );
                    if (newMaxCorrect > 0) {
                      await widget.continueCurrentVerseAnyway(newMaxCorrect);
                      setState(() {
                        maxReached = false;
                        front = true;
                      });
                    }
                  },
                  tooltip: "Vers trotzdem weiterlernen",
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () async {
                    await widget.finishCurrentVerse();
                    setState(() {
                      maxReached = false;
                      front = true;
                    });
                  },
                  tooltip: 'Vers als gelernt markieren',
                )
              ],
            )
          ],
        )),
      );
    } else if (front) {
      Verse verse = widget.currentVersesShuffle.last;
      result = GestureDetector(
        onTap: () {
          setState(() {
            front = false;
          });
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Container(
            color: Colors.lightGreenAccent,
            child: Center(
              child: Text(
                  '${short2long[verse.book]} ${verse.chapter}, ${verse.verse}'),
            ),
          ),
        ),
      );
    } else {
      Verse verse = widget.currentVersesShuffle.last;
      result = Container(
        padding: EdgeInsets.all(20),
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.startToEnd) {
              bool localMaxReached = await widget.currentVerseLearned();
              if (localMaxReached) {
                setState(() {
                  maxReached = true;
                });
              } else {
                await widget.continueCurrentVerse();
                setState(() {
                  front = true;
                });
              }
            } else {
              await widget.currentVerseWrong();
              setState(() {
                front = true;
              });
            }
          },
          direction: DismissDirection.horizontal,
          child: GestureDetector(
            onTap: () {
              setState(() {
                front = true;
              });
            },
            child: Container(
              color: Colors.teal,
              child: Center(
                  child: Text('${verse.text}')
              ),
            ),
          ),
          background: Container(
            color: Colors.green,
            child: Text("Richtig"),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            child: Text("Falsch"),
          ),
        ),
      );
    }
    return result;
  }
}

class NewMaxCorrectDialog extends StatefulWidget {
  @override
  _NewMaxCorrectDialogState createState() => _NewMaxCorrectDialogState();
}

class _NewMaxCorrectDialogState extends State<NewMaxCorrectDialog> {
  double newMaxCorrect;

  @override
  void initState() {
    super.initState();
    newMaxCorrect = 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('newMaxCorrect'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Wähle aus, wie oft du den Vers richtig wiederholen möchtest, bis er als 'gelernt' markiert wird"),
            Slider(
              value: newMaxCorrect,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  newMaxCorrect = value;
                });
              },
            ),
            Text('${newMaxCorrect.floor()}'),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Text('Abbrechen'),
            ),
            FlatButton(
              onPressed: () {
                // Use the second argument of Navigator.pop(...) to pass
                // back a result to the page that opened the dialog
                Navigator.pop(context, newMaxCorrect.floor());
              },
              child: Text('Ok'),
            )
          ],
        ),
      ],
    );
  }
}
