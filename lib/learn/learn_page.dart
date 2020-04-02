import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';

class LearnPage extends StatefulWidget {
  final DataBaseHelper helper;
  final Function _onItemTapped;
  LearnPage(this.helper, this._onItemTapped);
  @override
  _LearnPageState createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  Future<List<Verse>> selectedVerses;
  Future<List<Verse>> currentVerses;
  Future<List<Verse>> learnedVerses;
  Future<List<Verse>> currentVersesShuffle;
  Future<Verse> currentVerse;

  Future<List<Verse>> getCurrentVersesShuffle(Future<List<Verse>> currentVerses) {
    //get from shared preferences
    //otherwise: currentVerses.then((List<Verse> currentVerses) {currentVerses.shuffle(); return currentVerses;});
  }

  Future<Verse> getCurrentVerse() async {
    return await currentVersesShuffle.then((list) => list.last);
  }

  //call when Verse specific updates have been done and Verse hasn't reached LearnStatus.learned
  void continueCurrentVerse() async {
    //todo: put at beginning of CVS and thereby call setState
  }

  //call when the current Verse was correct
  Future<bool> currentVerseLearned() async {
    Verse verse = await currentVersesShuffle.then((list) => list.last);
    //todo: update database with new information about verse
    //todo: get from database whether this verse has reached maxCorrect
    bool maxCorrect = true;
    return maxCorrect;
  }

  //call when the current Verse has reached LearnStatus.learned
  void finishCurrentVerse() async {
    //todo: change [newMaxCorrect] to [defaultMaxCorrect] in Database and set LearnStatus to learned
    //todo: remove from CVS and thereby call setState
  }

  //call when current Verse was wrong
  void currentVerseWrong() async {
    Verse verse = await currentVersesShuffle.then((list) => list.last);
    //todo: update database with new information about verse
    await this.continueCurrentVerse();
  }

  @override
  void initState() {
    super.initState();
    selectedVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.selected);
    currentVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.current);
    learnedVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.learned);
    currentVersesShuffle = getCurrentVersesShuffle(currentVerses);
    currentVerse = getCurrentVerse();
  }

  Future<List<List<Verse>>> _verseLists() async {
    List<List<Verse>> verses = [];
    selectedVerses.then((list) => verses.add(list));
    currentVerses.then((list) => verses.add(list));
    learnedVerses.then((list) => verses.add(list));
    currentVersesShuffle.then((list) => verses.add(list));//current verse is last verse in [currentVersesShuffle]
    return verses;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _verseLists(),
      builder: (context, AsyncSnapshot<List<List<Verse>>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          List<Verse> mySelectedVerses = snapshot.data[0];
          List<Verse> myCurrentVerses = snapshot.data[1];
          List<Verse> myLearnedVerses = snapshot.data[2];
          List<Verse> myCurrentVersesShuffle = snapshot.data[3];

          return Scaffold(
            appBar: AppBar(
              title: Text("Lernen"),
            ),
            body: Container(
              padding: EdgeInsets.all(20),
              child: Container(

              ),
            ),
          );
        } else if (snapshot.hasError) {
          result = Text('${snapshot.error}');
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Lernen"),
            ),
            body: Center(
              child: Text("Awaiting result..."),
            ),
          );
        }
        return result;
      },
    );
  }
}
