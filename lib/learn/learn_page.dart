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

  @override
  void initState() {
    super.initState();
    selectedVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.selected);
    currentVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.current);
    learnedVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.learned);
  }

  Future<List<List<Verse>>> _verseLists () async {
    List<List<Verse>> verses = [];
    selectedVerses.then((list) => verses.add(list));
    currentVerses.then((list) => verses.add(list));
    learnedVerses.then((list) => verses.add(list));
    return verses;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _verseLists(),
      builder: (context, AsyncSnapshot<List<List<Verse>>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
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
    )

  }
}