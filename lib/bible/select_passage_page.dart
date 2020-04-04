import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';

class SelectPassage extends StatefulWidget {
  final Passage displayPassage;
  final Function setNewChapter;
  SelectPassage(this.setNewChapter, this.displayPassage);
  @override
  _SelectPassageState createState() =>
      _SelectPassageState(this.setNewChapter, this.displayPassage);
}

class _SelectPassageState extends State<SelectPassage>
    with SingleTickerProviderStateMixin {
  final Function setNewChapter;
  final Passage displayPassage;
  var book;
  _SelectPassageState(this.setNewChapter, this.displayPassage);

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Buch'),
    Tab(text: 'Kapitel'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    book = displayPassage.book;
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  List<ListTile> generateBookList() {
    List<String> bookList = [];
    short2long.forEach((key, value) {
      bookList.add(key);
    });
    return bookList.map((String book) {
      return ListTile(
        title: Text(short2long[book]),
        onTap: () {
          setState(() {
            this.book = book;
          });
          _tabController.animateTo(1, duration: Duration(milliseconds: 150));
        },
      );
    }).toList();
  }

  List<ListTile> generateChapterList(String book, BuildContext context) {
    int chapterNumber = chapterNumbers[book];
    List<int> chapterList = [for(var i=1; i < chapterNumber + 1; i++) i];
    return chapterList.map((int chapter) {
      return ListTile(
        title: Text('$chapter'),
        onTap: () {
          this.setNewChapter(Passage(book, chapter, 1));
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getBook() {
    return this.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bibelstelle wählen"),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(controller: _tabController, children: <Widget>[
        ListView(
          children: this.generateBookList(),
        ),
        ListView(
          children: this.generateChapterList(this.book, context),
        )
      ]),
    );
  }
}