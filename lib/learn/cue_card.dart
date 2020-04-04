import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';
import 'flip_cue_card.dart';

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
  }

  void setMaxReachedState(bool value) {
    setState(() {
      maxReached = value;
    });
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
              "Du hast den Vers",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${short2long[verse.book]} ${verse.chapter}, ${verse.verse}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "oft genug richtig gewusst.",
              style: TextStyle(fontSize: 20),
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
    } else {
      result = FlipCueCard(widget.currentVersesShuffle.last, widget.currentVerseLearned, this.setMaxReachedState, widget.continueCurrentVerse, widget.currentVerseWrong);
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
