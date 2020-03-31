import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'main.dart';


class BiblePage extends StatefulWidget {
  final helper;
  BiblePage(this.helper);

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

  @override
  void initState() {
    super.initState();
    Future<Passage> futureDisplayPassage = getInformation();
    //futureDisplayPassage.then(print);
    _verseList = futureDisplayPassage.then(helper.getChapterFromPassage);
  }

  Future<Passage> getInformation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String book = preferences.getString("book") ?? "Gen";
    int chapter = preferences.getInt("chapter") ?? 1;
    offset = preferences.getDouble("offset") ?? 0;
    scrollController = new ScrollController(
        initialScrollOffset: offset
    );
    displayPassage = Passage(book, chapter, 1);
    //print("I have just read $displayPassage from SharedPreferences");
    return displayPassage;
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
    for (int i = 0; i<normalString.length; i++) {
      superString = superString + unicodeMap[normalString[i]];
    }
    return superString;
  }

  List<Widget> versesToWidget(List<Verse> verseList) {
    List<Widget> list = List.generate(verseList.length, (i) {
      return Text('${getVerseNumber(verseList[i].verse)}${verseList[i].text}');
    });
    list.add(
        Row(
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
        )
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Verse>>(
      future: this._verseList, // a previously-obtained Future or null
      builder: (BuildContext context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;

        if (snapshot.hasData) {
          result = new NotificationListener (
            child: ListView.builder(
              controller: scrollController,
              itemCount: snapshot.data.length + 1,
              itemBuilder: (context, index) {return versesToWidget(snapshot.data)[index];},
            ),
            onNotification: (notification) {
                if (notification is ScrollNotification) {
                  offset = notification.metrics.pixels;
                  return true;
                }
                return false;
              },
          );
        } else if (snapshot.hasError) {
          result = Scaffold(
            body: Center(
                child: Text(snapshot.error)
            ),
          );
        } else {
          result = Scaffold(
            body: Center(
                child: Text('Awaiting result...')
            ),
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
    //print("I have just saved $displayPassage to SharedPreferences because of disposal");
    preferences.setDouble("offset", offset);
  }
}