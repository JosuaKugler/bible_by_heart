import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/db_interaction.dart';
import 'select_passage_page.dart';
import 'settings_page.dart';
import 'add_verse_page.dart';

class BiblePage extends StatefulWidget {
  final helper;
  final Function _onItemTapped;
  BiblePage(this.helper, this._onItemTapped);

  @override
  _BiblePageState createState() => _BiblePageState(this.helper);
}

class _BiblePageState extends State<BiblePage> {
  final DataBaseHelper helper;
  _BiblePageState(this.helper);
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  Passage displayPassage = Passage("Gen", 1, 1);
  double offset = 0;
  Future<List<Verse>> _verseList;
  double fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    Future<Passage> futureDisplayPassage = getInformation();
    _verseList = futureDisplayPassage.then(helper.getChapterFromPassage);
  }

  Future<Passage> getInformation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String book = preferences.getString("book") ?? "Gen";
    int chapter = preferences.getInt("chapter") ?? 1;
    offset = preferences.getDouble("offset") ?? 0;
    fontSize = preferences.getDouble("fontSize") ?? 18;
    scrollController = new ScrollController(initialScrollOffset: offset);
    displayPassage = Passage(book, chapter, 1);
    //print("I have just read $displayPassage from SharedPreferences");
    return displayPassage;
  }

  void setSettings(double newFontSize) {
    setState(() {
      fontSize = newFontSize;
    });
  }

  void setNewChapter(Passage passage) async {
    displayPassage = passage;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("book", displayPassage.book);
    preferences.setInt("chapter", displayPassage.chapter);
    setState(() {
      _verseList = helper.getChapterFromPassage(displayPassage);
      scrollController.jumpTo(0);
      offset = 0;
    });
  }

  void incrementChapter() async {
    Verse temp = await this.helper.getNextChapterVerse(displayPassage);
    displayPassage = temp.toPassage();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("book", displayPassage.book);
    preferences.setInt("chapter", displayPassage.chapter);
    //print("I have just saved $displayPassage to SharedPreferences");
    setState(() {
      _verseList = helper.getChapterFromPassage(displayPassage);
      scrollController.jumpTo(0);
      offset = 0;
    });
  }

  void decrementChapter() async {
    Verse temp = await this.helper.getPreviousChapterVerse(displayPassage);
    displayPassage = temp.toPassage();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("book", displayPassage.book);
    preferences.setInt("chapter", displayPassage.chapter);
    //print("I have just saved $displayPassage to SharedPreferences");
    setState(() {
      _verseList = helper.getChapterFromPassage(displayPassage);
      scrollController.jumpTo(0);
      offset = 0;
    });
  }

  static getVerseNumber(int verseNumber) {
    var unicodeMap = {
      '0': '\u2070',
      '1': '\u00B9',
      '2': '\u00B2',
      '3': '\u00B3',
      '4': '\u2074',
      '5': '\u2075',
      '6': '\u2076',
      '7': '\u2077',
      '8': '\u2078',
      '9': '\u2079',
    };
    String normalString = '$verseNumber';
    String superString = '';
    for (int i = 0; i < normalString.length; i++) {
      superString = superString + unicodeMap[normalString[i]];
    }
    return superString;
  }

  List<Widget> versesToWidget(List<Verse> verseList) {
    List<Widget> list = List.generate(verseList.length, (i) {
      return new GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            builder: (context) => AddVersePage(widget.helper, verseList[i], widget._onItemTapped),
          );
        },
        child: Text(
          '${getVerseNumber(verseList[i].verse)}${verseList[i].text}',
          style: TextStyle(fontSize: fontSize),
        ),
      );
    });
    list.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: this.decrementChapter,
        ),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: this.incrementChapter,
        ),
      ],
    ));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Verse>>(
      future: this._verseList, // a previously-obtained Future or null
      builder: (BuildContext context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;

        if (snapshot.hasData) {
          result = Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Row(
                      children: <Widget>[
                        Text(
                          "${short2long[displayPassage.book]} ${displayPassage.chapter}",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20.0),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        )
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectPassage(
                                  this.helper,
                                  this.setNewChapter,
                                  this.displayPassage,
                                  )));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                  this.setSettings, this.fontSize)));
                    },
                  )
                ],
              ),
            ),
            body: NotificationListener(
              child: ListView.builder(
                controller: scrollController,
                itemCount: snapshot.data.length + 1,
                itemBuilder: (context, index) {
                  return versesToWidget(snapshot.data)[index];
                },
              ),
              onNotification: (notification) {
                if (notification is ScrollNotification) {
                  offset = notification.metrics.pixels;
                  return true;
                }
                return false;
              },
            ),
          );
        } else if (snapshot.hasError) {
          result = Scaffold(
            body: Center(child: Text('${snapshot.error}')),
          );
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Bibel"),
            ),
            body: Center(child: Text('Laden...')),
          );
        }
        return result;
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("book", displayPassage.book);
    preferences.setInt("chapter", displayPassage.chapter);
    preferences.setDouble("offset", offset);
    preferences.setDouble("fontSize", fontSize);
  }
}
