import 'package:bible_by_heart/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';


class BiblePage extends StatefulWidget {
  final helper;
  BiblePage(this.helper);
  @override
  _BiblePageState createState() => _BiblePageState(this.helper);

}

class _BiblePageState extends State<BiblePage> {
  final DataBaseHelper helper;
  _BiblePageState(this.helper);

  var displayPassage = Passage("Gen", 1, 1);//state

  void incrementChapter() async {
    Verse temp = await this.helper.getNextChapterVerse(displayPassage);
    setState(() {
      displayPassage = temp.toPassage();
    });
  }

  void decrementChapter() async {
    Verse temp = await this.helper.getPreviousChapterVerse(displayPassage);
    setState(() {
      displayPassage = temp.toPassage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DataBaseHelper helper = context.findAncestorWidgetOfExactType<MyApp>().helper;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text(displayPassage.book),
            Text(" ${displayPassage.chapter}"),
          ],
        ),
      ),
      body: MyChapterView(this, helper, displayPassage),
    );
  }
}

class MyChapterView extends StatefulWidget {
  final _BiblePageState parent;
  final displayPassage;
  final DataBaseHelper helper;
  MyChapterView(this.parent, this.helper, this.displayPassage);

  @override
  _MyChapterViewState createState() => _MyChapterViewState(this.parent, this.helper, this.displayPassage);
}

class _MyChapterViewState extends State<MyChapterView> {
  Passage currentPassage; //state
  final _BiblePageState parent;
  final DataBaseHelper helper;
  Future<List<Verse>> _verseList;
  _MyChapterViewState(this.parent, this.helper, displayPassage): _verseList = helper.getChapterFromPassage(displayPassage);


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
            onPressed: this.parent.decrementChapter,
          ),
          IconButton(
            icon: Icon(Icons.arrow_right),
            onPressed: this.parent.incrementChapter,
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
          result = ListView(
            children: versesToWidget(snapshot.data),
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
}