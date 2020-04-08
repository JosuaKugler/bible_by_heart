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

  void setBook(String book) {
    setState(() {
      this.book = book;
    });
  }

  List<InkWell> generateChapterList(String book, BuildContext context) {
    int chapterNumber = chapterNumbers[book];
    List<int> chapterList = [for(var i=1; i < chapterNumber + 1; i++) i];
    return chapterList.map((int chapter) {
      return InkWell(
        child: Center(child: Text('$chapter', style: TextStyle(fontSize: 20),)),
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
        title: TextField(
          onChanged: (text) {print(text);},
          decoration: InputDecoration(
              hintText: 'Suche einen Vers'
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(controller: _tabController, children: <Widget>[
        BookSelection(this.setBook, this._tabController),
        GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          children: this.generateChapterList(this.book, context),
        )
      ]),
    );
  }
}


class BookSelection extends StatefulWidget {
  final Function setBook;
  final TabController _tabController;

  BookSelection(this.setBook, this._tabController);
  @override
  _BookSelectionState createState() => _BookSelectionState();
}

class _BookSelectionState extends State<BookSelection> {
  List<String> bookList;

  @override
  initState() {
    bookList = getAllBooksMatching('');
    super.initState();
  }

  void setBookList(String searchTerm) {
    setState(() {
      bookList = getAllBooksMatching(searchTerm);
    });
  }

  List<ListTile> generateBookList() {
    List<ListTile> retList =  bookList.map((String book) {
      return ListTile(
        title: Text(book),
        onTap: () {
          widget.setBook(long2Short(book));
          widget._tabController.animateTo(1, duration: Duration(milliseconds: 150));
          FocusScope.of(context).unfocus();
        },
      );
    }).toList();
    retList.insert(0, ListTile(title: TextField(
      onChanged: setBookList,
      decoration: InputDecoration(
          hintText: 'Suche ein Buch'
      ),
    ))
    );
    return retList;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => FocusScope.of(context).unfocus(),
      child: ListView(
        children: generateBookList(),
      ),
    );
  }
}


