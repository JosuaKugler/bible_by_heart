import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';

class SelectPassage extends StatefulWidget {
  @override
  _SelectPassageState createState() => _SelectPassageState();
}

class _SelectPassageState extends State<SelectPassage>
    with SingleTickerProviderStateMixin {
  String book;
  int chapter;

  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Buch'),
    Tab(text: 'Kapitel'),
    Tab(text: 'Vers',),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    book = "Gen";
    chapter = 1;
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

  List<InkWell> generateChapterList(String book, BuildContext context) {
    int chapterNumber = chapterNumbers[book];
    List<int> chapterList = [for(var i=1; i < chapterNumber + 1; i++) i];
    return chapterList.map((int chapter) {
      return InkWell(
        child: Center(child: Text('$chapter', style: TextStyle(fontSize: 20),)),
        onTap: () {
          setState(() {
            this.chapter = chapter;
          });
          _tabController.animateTo(2, duration: Duration(milliseconds: 150));
        },
      );
    }).toList();
  }

  Future<List<InkWell>> generateVerseList(String book, int chapter, BuildContext context) async {
    int verseNumber = await helper.getNumberOfVerses(book, chapter);
    List<int> verseList = [for(var i=1; i < verseNumber + 1; i++) i];
    return verseList.map((int verse) {
      return InkWell(
        child: Center(child: Text('$verse', style: TextStyle(fontSize: 20),)),
        onTap: () {
          Navigator.pop(context, Passage(this.book, this.chapter, verse));
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
    return FutureBuilder(
      future: generateVerseList(book, chapter, context),
      builder: (BuildContext context, AsyncSnapshot<List<InkWell>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
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
              GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                children: this.generateChapterList(this.book, context),
              ),
              GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                children: snapshot.data,
              ),
            ]),
          );
        } else if (snapshot.hasError) {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Bibelstelle wählen"),
              bottom: TabBar(
                controller: _tabController,
                tabs: myTabs,
              ),
            ),
            body: Center(
              child: Text('${snapshot.error}'),
            ),
          );
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Bibelstelle wählen"),
              bottom: TabBar(
                controller: _tabController,
                tabs: myTabs,
              ),
            ),
            body: Center(
              child: Text('Laden...'),
            ),
          );
        }
        return result;
      },
    );
  }
}