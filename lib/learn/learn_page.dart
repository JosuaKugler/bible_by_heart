import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/db_interaction.dart';
import 'cue_card.dart';
import 'select_verse_page.dart';

class LearnPage extends StatefulWidget {
  final Function _onItemTapped;
  LearnPage(this._onItemTapped);
  @override
  _LearnPageState createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  Future<List<Verse>> currentVersesShuffle;
  int shuffleCounter;

  @override
  void initState() {
    super.initState();
    currentVersesShuffle = getCurrentVersesShuffle();
  }

  void reloadVerses () {
    setState(() {
      currentVersesShuffle = getCurrentVersesShuffle();
    });
  }

  Future<List<Verse>> getCurrentVersesShuffle() async {
    //print("Hi from getCurrentVerseShuffle: $shuffleCounter");
    Future<List<Verse>> currentVerses =
        helper.getVersesOnLearnStatus(LearnStatus.current);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> shuffleFromPreferences =
        preferences.getStringList("shuffledList") ?? null;
    shuffleCounter = preferences.getInt("shuffleCounter") ?? 0;
    if (shuffleFromPreferences == null) {
      return await currentVerses.then((List<Verse> currentVerses) {
        currentVerses.shuffle();
        return currentVerses;
      });
    } else {
      List<Verse> fromPrefs = [];
      for (String idString in shuffleFromPreferences) {
        Verse verse = await helper.getVerseFromId(int.parse(idString));
        fromPrefs.add(verse);
      }
      //match fromPrefs with currentVerses.
      return await currentVerses.then((List<Verse> presentCurrentVerses) {
        List<Verse> localCVS = [];
        for (Verse verse in presentCurrentVerses) {
          if (!fromPrefs.contains(verse)) {
            fromPrefs.insert(0, verse);
          }
        }
        for (Verse verse in fromPrefs) {
          if (presentCurrentVerses.contains(verse)) {
            localCVS.add(verse);
          }
        }
        if (shuffleCounter <= 0) {
          localCVS.shuffle();
          shuffleCounter = localCVS.length;
        }
        return localCVS;
      });
    }
  }

  //call when Verse specific updates have been done and Verse hasn't reached LearnStatus.learned
  void continueCurrentVerse() async {
    setState(() {
      currentVersesShuffle =
          currentVersesShuffle.then((List<Verse> presentCVS) {
        Verse localCurrentVerse = presentCVS.removeLast();
        presentCVS.insert(0, localCurrentVerse);
        shuffleCounter--;
        if (shuffleCounter <= 0) {
          presentCVS.shuffle();
          shuffleCounter = presentCVS.length;
        }
        return presentCVS;
      });
    });
  }

  void continueCurrentVerseAnyway(int newMaxCorrect) async {
    setState(() {
      currentVersesShuffle =
          currentVersesShuffle.then((List<Verse> presentCVS) {
        Verse localCurrentVerse = presentCVS.removeLast();
        helper.setMaxCorrect(localCurrentVerse.id, newMaxCorrect);
        helper.setCorrect(localCurrentVerse.id, 0);
        presentCVS.insert(0, localCurrentVerse);
        shuffleCounter--;
        if (shuffleCounter <= 0) {
          presentCVS.shuffle();
          shuffleCounter = presentCVS.length;
        }
        return presentCVS;
      });
    });
  }

  //call when the current Verse was correct
  Future<bool> currentVerseLearned() async {
    Verse verse = await currentVersesShuffle.then((list) => list.last);
    await helper.increaseCorrect(verse.id);
    int correct = await helper.getCorrect(verse.id);
    int maxCorrect = await helper.getMaxCorrect(verse.id);
    bool maxCorrectReached = correct >= maxCorrect;
    return maxCorrectReached;
  }

  //call when the current Verse has reached LearnStatus.learned
  void finishCurrentVerse() async {
    Verse verse = await currentVersesShuffle.then((list) => list.last);
    helper.setLearnStatus(verse.id, LearnStatus.learned);
    helper.setMaxCorrect(
        verse.id, 10); // probably add different defaultMaxCorrect
    helper.setCorrect(verse.id, 0);
    setState(() {
      currentVersesShuffle =
          currentVersesShuffle.then((List<Verse> presentCVS) {
        presentCVS.removeLast();
        shuffleCounter--;
        if (shuffleCounter <= 0) {
          presentCVS.shuffle();
          shuffleCounter = presentCVS.length;
        }
        return presentCVS;
      });

    });
  }

  //call when current Verse was wrong
  void currentVerseWrong() async {
    Verse verse = await currentVersesShuffle.then((list) => list.last);
    await helper.decreaseCorrect(verse.id, 2); //probably change default
    await this.continueCurrentVerse();
  }

  writePreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await currentVersesShuffle.then((List<Verse> presentCVS) {
      List<String> presentCVSasString =
          presentCVS.map((Verse verse) => '${verse.id}').toList();
      preferences.setStringList("shuffledList", presentCVSasString);
      preferences.setInt("shuffleCounter", shuffleCounter);
    });
  }

  @override
  void dispose() {
    super.dispose();
    writePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: currentVersesShuffle,
      builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          return CueCard(
              snapshot.data,
              this.reloadVerses,
              this.currentVerseLearned,
              this.currentVerseWrong,
              this.continueCurrentVerse,
              this.finishCurrentVerse,
              this.continueCurrentVerseAnyway,
            );
        } else if (snapshot.hasError) {
          result = Text('${snapshot.error}');
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Lernen"),
            ),
            body: Center(
              child: Text("Laden..."),
            ),
          );
        }
        return result;
      },
    );
  }
}
