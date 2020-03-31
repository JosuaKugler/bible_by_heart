import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'selectpassagepage.dart';
import 'settingspage.dart';

class BiblePage extends StatefulWidget {
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
    scrollController.jumpTo(offset);
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
      return Text(
          '${getVerseNumber(verseList[i].verse)}${verseList[i].text}',
        style: TextStyle(fontSize: fontSize),
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
                          "${widget.short2long[displayPassage.book]} ${displayPassage.chapter}",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20.0
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Color.fromRGBO(255, 255, 255, 1),)
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectPassage(
                                  this.helper, this.setNewChapter, this.displayPassage, widget.short2long
                              )
                          )
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Color.fromRGBO(255, 255, 255, 1),),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage(this.setSettings, this.fontSize))
                      );
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
            body: Center(child: Text(snapshot.error)),
          );
        } else {
          result = Scaffold(
            body: Center(child: Text('Awaiting result...')),
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
