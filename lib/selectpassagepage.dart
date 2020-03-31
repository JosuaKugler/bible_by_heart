import 'package:bible_by_heart/biblepage.dart';
import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectPassage extends StatefulWidget {
  final DataBaseHelper helper;
  final Passage displayPassage;
  final Function setNewChapter;
  SelectPassage(this.helper, this.setNewChapter, this.displayPassage);
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
  _SelectPassageState(this.helper, this.setNewChapter, this.displayPassage)
      : book = displayPassage.book;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Buch'),
    Tab(text: 'Kapitel'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

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

  List<ListTile> generateBookList() {
    List<String> bookList = [];
    short2long.forEach((key, value) {
      bookList.add(key);
    });
    return bookList.map((String book) {
      return ListTile(
        title: Text(short2long[book]),
        onTap: () {
          this.book = book;
          print(book);
          _tabController.animateTo(1);
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
        ChapterSelection(getBook, this.helper, this.setNewChapter),
      ]),
    );
  }
}

class ChapterSelection extends StatelessWidget {
  final Function getBook;
  final DataBaseHelper helper;
  final Future<int> _chapterNumber;
  final Function setNewChapter;
  ChapterSelection(this.getBook, this.helper, this.setNewChapter)
      : _chapterNumber = helper.getNumberOfChapters(getBook());

  List<ListTile> generateChapterList(int chapterNumber, BuildContext context) {
    List<int> chapterList = [];
    for (int i = 1; i < chapterNumber + 1; i++) {
      chapterList.add(i);
    }
    return chapterList.map((int chapter) {
      return ListTile(
        title: Text('$chapter'),
        onTap: () {
          this.setNewChapter(Passage(this.getBook(), chapter, 1)); //doesn't work because it is built right at the beginning
          Navigator.pop(context);
        },
      );
    }).toList();
    //add the functionality to click on a chapter and then submit the new passage and pop
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _chapterNumber,
      builder: (context, AsyncSnapshot<int> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = ListView(
            children: generateChapterList(snapshot.data, context),
          );
        } else if (snapshot.hasError) {
          result = Text(snapshot.error);
        } else {
          result = Center(child: Text('Awaiting result...'));
        }
        return result;
      },
    );
  }
}
