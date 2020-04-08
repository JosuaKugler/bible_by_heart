import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';
import '../bible/search_results_page.dart';

class SelectPassage extends StatefulWidget {
  @override
  _SelectPassageState createState() => _SelectPassageState();
}

class _SelectPassageState extends State<SelectPassage>
    with SingleTickerProviderStateMixin {
  String book;
  int chapter;
  String searchTerm;
  bool search = false;

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
    search = false;
    searchTerm = '';
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

  void setBook(String book) {
    setState(() {
      this.book = book;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (search) ? buildSearchPage(context) : buildNotSearchPage(context);
  }

  FutureBuilder<List<InkWell>> buildNotSearchPage(BuildContext context) {
    return FutureBuilder(
    future: generateVerseList(book, chapter, context),
    builder: (BuildContext context, AsyncSnapshot<List<InkWell>> snapshot) {
      Widget result;
      if (snapshot.hasData) {
        result = Scaffold(
          appBar: AppBar(
            title: Text("Bibelstelle wählen"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    search = true;
                  });
                },
              )
            ],
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

  Scaffold buildSearchPage(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                setState(() {
                  search = false;
                  searchTerm = "";
                }),
          ),
          title: TextField(
            onChanged: (text) {
              setState(() {
                searchTerm = text;
              });
            },
            autofocus: true,
            decoration: InputDecoration(hintText: "Suche nach Begriffen"),
          ),
        ),
        body: SearchResults(searchTerm));
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
    List<ListTile> retList = bookList.map((String book) {
      return ListTile(
        title: Text(book),
        onTap: () {
          widget.setBook(long2Short(book));
          widget._tabController
              .animateTo(1, duration: Duration(milliseconds: 150));
          FocusScope.of(context).unfocus();
        },
      );
    }).toList();
    retList.insert(
        0,
        ListTile(
            title: TextField(
              onChanged: setBookList,
              decoration: InputDecoration(hintText: 'Suche ein Buch'),
            )));
    return retList;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => FocusScope.of(context).unfocus(),
      onVerticalDragStart: (_) => FocusScope.of(context).unfocus(),
      onHorizontalDragStart: (_) => FocusScope.of(context).unfocus(),
      child: ListView(
        children: generateBookList(),
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String searchTerm;
  SearchResults(this.searchTerm);

  @override
  Widget build(BuildContext context) {
    return (searchTerm.length < 3)
        ? Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text('Nicht genug Text, gib mindestens drei Buchstaben ein'),
        ))
        : FutureBuilder(
      future: helper.getAllVersesMatching(searchTerm),
      builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = ListView.builder(
              itemCount: snapshot.data.length + 1,
              itemBuilder: (context, index) {
                return (index == 0)
                    ? ListTile(
                  title: (snapshot.data.length == 1)
                      ? Text('1 Suchergebnis')
                      : Text(
                      '${snapshot.data.length} Suchergebnisse'),
                )
                    : ListTile(
                  title: Text(
                      snapshot.data[index - 1].passageString()),
                  subtitle: Text(snapshot.data[index - 1].text),
                  onTap: () {
                    Navigator.pop(context, snapshot.data[index].toPassage());
                  },
                );
              });
          //Scaffold.of(context).showSnackBar(SnackBar(content: Text('${snapshot.data.length} Ergebnisse'),));
        } else if (snapshot.hasError) {
          result = Center(
            child: Text('${snapshot.error}'),
          );
        } else {
          result = Center(
            child: Text('Laden...'),
          );
        }
        return result;
      },
    );
  }
}
