import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/db_interaction.dart';
import 'select_passage_page.dart';
import 'settings_page.dart';
import 'add_verse_page.dart';

class BiblePage extends StatefulWidget {
  final Function _onItemTapped;
  BiblePage(this._onItemTapped);

  @override
  _BiblePageState createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  _BiblePageState();
  ScrollController scrollController;
  Passage displayPassage = Passage("Gen", 1, 1);
  double offset = 0;
  Future<List<Verse>> _verseList;
  double fontSize = 18.0;
  bool buttonsVisible = true;

  @override
  void initState() {
    super.initState();
    Future<Passage> futureDisplayPassage = getInformation();
    _verseList = futureDisplayPassage.then(helper.getChapterFromPassage);
    scrollController = ScrollController(initialScrollOffset: 0)
        ..addListener(() {
      setButtonsVisible(scrollController.position.userScrollDirection == ScrollDirection.forward);
    });
  }

  void setButtonsVisible(bool value) {
    setState(() {
      buttonsVisible = value;
    });
  }

  Future<Passage> getInformation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String book = preferences.getString("book") ?? "Gen";
    int chapter = preferences.getInt("chapter") ?? 1;
    offset = preferences.getDouble("offset") ?? 0;
    fontSize = preferences.getDouble("fontSize") ?? 18;
    scrollController = ScrollController(initialScrollOffset: offset)
    ..addListener(() {
      setButtonsVisible(scrollController.position.userScrollDirection ==
          ScrollDirection.forward);
    });
    //scrollController.jumpTo(offset);
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
    Verse temp = await helper.getNextChapterVerse(displayPassage);
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
    Verse temp = await helper.getPreviousChapterVerse(displayPassage);
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

  List<Widget> versesToWidget(List<Verse> verseList, BuildContext scaffoldContext) {
    List<Widget> list = List.generate(verseList.length, (i) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            builder: (context) => AddVersePage(verseList[i], scaffoldContext),
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

  AppBar buildAppBar(snapshot) {
    return AppBar(
      titleSpacing: 0.0,
      centerTitle: false,
      title: FlatButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                        this.setNewChapter,
                        this.displayPassage,
                      )));
            },
          ),
          actions: [IconButton(
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
    );
  }

  Widget buildBody(snapshot) {
    return NotificationListener(
      child: ListView.builder(
        controller: scrollController,
        itemCount: snapshot.data.length + 1,
        itemBuilder: (context, index) {
          return versesToWidget(snapshot.data, context)[index];
        },
      ),
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          offset = notification.metrics.pixels;
          return true;
        }
        return false;
      },
    );
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (this.buttonsVisible) Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 30,
              height: 0,
            ),
            FloatingActionButton(
              onPressed: this.decrementChapter,
              child: Icon(Icons.arrow_back_ios),
              heroTag: null,
            ),
          ],
        ),
        if (this.buttonsVisible) FloatingActionButton(
          onPressed: this.incrementChapter,
          child: Icon(Icons.arrow_forward_ios),
          heroTag: null,
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Verse>>(
      future: this._verseList, // a previously-obtained Future or null
      builder: (BuildContext context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
            appBar: buildAppBar(snapshot),
            body: buildBody(snapshot),
            floatingActionButton: buildButtons(),
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
