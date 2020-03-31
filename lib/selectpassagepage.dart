import 'package:bible_by_heart/biblepage.dart';
import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectPassage extends StatefulWidget {
  final DataBaseHelper helper;
  final Passage displayPassage;
  final Function setNewChapter;
  final Map<String, String> short2long;
  SelectPassage(this.helper, this.setNewChapter, this.displayPassage, this.short2long);
  @override
  _SelectPassageState createState() =>
      _SelectPassageState(this.helper, this.setNewChapter, this.displayPassage);
}

class _SelectPassageState extends State<SelectPassage>
    with SingleTickerProviderStateMixin {
  final DataBaseHelper helper;
  final Function setNewChapter;
  final Passage displayPassage;
  var book;
  _SelectPassageState(this.helper, this.setNewChapter, this.displayPassage);

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

  /*
  final Map<String, String> short2long = {
    "Gen": "Genesis",
    "Exo": "Exodus",
    "Lev": "Levitikus",
    "Num": "Numeri",
    "Deu": "Deuteronomium",
    "Jos": "Josua",
    "Jdg": "Richter",
    "Rut": "Ruth",
    "1Sa": "1. Samuel",
    "2Sa": "2. Samuel",
    "1Ki": "1. Könige",
    "2Ki": "2. Könige",
    "1Ch": "1. Chronik",
    "2Ch": "2. Chronik",
    "Ezr": "Esra",
    "Neh": "Nehemia",
    "Est": "Esther",
    "Job": "Hiob",
    "Psa": "Psalmen",
    "Pro": "Sprüche",
    "Ecc": "Prediger",
    "Sol": "Hoheslied",
    "Isa": "Jesaja",
    "Jer": "Jeremia",
    "Lam": "Klagelieder",
    "Eze": "Hesekiel",
    "Dan": "Daniel",
    "Hos": "Hosea",
    "Joe": "Joel",
    "Amo": "Amos",
    "Abd": "Obadja",
    "Jon": "Jona",
    "Mic": "Micha",
    "Nah": "Nahum",
    "Hab": "Habakuk",
    "Zep": "Zefanja",
    "Hag": "Haggai",
    "Zec": "Sacharja",
    "Mal": "Maleachi",
    "Mat": "Matthäus",
    "Mar": "Markus",
    "Luk": "Lukas",
    "Joh": "Johannes",
    "Act": "Apostelgeschichte",
    "Rom": "Römer",
    "1Co": "1. Korinther",
    "2Co": "2. Korinther",
    "Gal": "Galater",
    "Eph": "Epheser",
    "Phi": "Philipper",
    "Col": "Kolosser",
    "1Th": "1. Thessalonicher",
    "2Th": "2. Thessalonicher",
    "1Ti": "1. Timotheus",
    "2Ti": "2. Timotheus",
    "Tit": "Titus",
    "Phm": "Philemon",
    "Heb": "Hebräer",
    "Jam": "Jakobus",
    "1Pe": "1. Petrus",
    "2Pe": "2. Petrus",
    "1Jo": "1. Johannes",
    "2Jo": "2. Johannes",
    "3Jo": "3. Johannes",
    "Jud": "Judas",
    "Rev": "Offenbarung",
  };
   */

  final Map<String, int> chapterNumbers = {
    'Gen': 50,
    'Exo': 40,
    'Lev': 27,
    'Num': 36,
    'Deu': 34,
    'Jos': 24,
    'Jdg': 21,
    'Rut': 4,
    '1Sa': 31,
    '2Sa': 24,
    '1Ki': 22,
    '2Ki': 25,
    '1Ch': 29,
    '2Ch': 36,
    'Ezr': 10,
    'Neh': 13,
    'Est': 10,
    'Job': 42,
    'Psa': 150,
    'Pro': 31,
    'Ecc': 12,
    'Sol': 8,
    'Isa': 66,
    'Jer': 52,
    'Lam': 5,
    'Eze': 48,
    'Dan': 12,
    'Hos': 14,
    'Joe': 4,
    'Amo': 9,
    'Abd': 1,
    'Jon': 4,
    'Mic': 7,
    'Nah': 3,
    'Hab': 3,
    'Zep': 3,
    'Hag': 2,
    'Zec': 14,
    'Mal': 3,
    'Mat': 28,
    'Mar': 16,
    'Luk': 24,
    'Joh': 21,
    'Act': 28,
    'Rom': 16,
    '1Co': 16,
    '2Co': 13,
    'Gal': 6,
    'Eph': 6,
    'Phi': 4,
    'Col': 4,
    '1Th': 5,
    '2Th': 3,
    '1Ti': 6,
    '2Ti': 4,
    'Tit': 3,
    'Phm': 1,
    'Heb': 13,
    'Jam': 5,
    '1Pe': 5,
    '2Pe': 3,
    '1Jo': 5,
    '2Jo': 1,
    '3Jo': 1,
    'Jud': 1,
    'Rev': 22
  };

  List<ListTile> generateBookList() {
    List<String> bookList = [];
    widget.short2long.forEach((key, value) {
      bookList.add(key);
    });
    return bookList.map((String book) {
      return ListTile(
        title: Text(widget.short2long[book]),
        onTap: () {
          setState(() {
            this.book = book;
          });
          _tabController.animateTo(1);
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