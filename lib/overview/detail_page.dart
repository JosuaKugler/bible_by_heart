import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';
import '../bible/add_verse_page.dart';

class DetailPage extends StatefulWidget {
  final Function rebuild;
  final Verse verse;
  final LearnStatus learnStatus;
  DetailPage(this.rebuild, this.verse, this.learnStatus);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.verse.passageString()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
              ],
            )
          ),
          AddVersePage(widget.verse, false)
        ],
      ),
    );
  }
}
