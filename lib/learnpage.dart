import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    selectedVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.selected);
    currentVerses = widget.helper.getVersesOnLearnStatus(LearnStatus.current);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lernen"),
      ),
    );
  }
}