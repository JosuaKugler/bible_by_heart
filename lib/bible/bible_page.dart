import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../myscrollable_positioned_list/lib/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/db_interaction.dart';
import 'settings_page.dart';
import 'add_verse_page.dart';
import '../learn/select_verse_page.dart';

class BiblePage extends StatefulWidget {
  @override
  _BiblePageState createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollController scrollController =
      ScrollController(keepScrollOffset: false);
  Future<Passage> displayPassage;
  ItemPosition firstItemPosition;
  double alignment = 0;
  double fontSize = 18.0;
  bool buttonsVisible = true;

  @override
  void initState() {
    super.initState();
    displayPassage = getInformation();
  }

  Future<Passage> getInformation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String book = preferences.getString("book") ?? "Gen";
    int chapter = preferences.getInt("chapter") ?? 1;
    int verse = preferences.getInt("verse") ?? 1;
    this.alignment = preferences.getDouble("alignment") ?? 0;
    this.fontSize = preferences.getDouble("fontSize") ?? 18;
    return Passage(book, chapter, verse);
  }

  void setButtonsVisible(bool value) {
    setState(() {
      buttonsVisible = value;
    });
  }

  void setSettings(double newFontSize) {
    setState(() {
      fontSize = newFontSize;
    });
  }

  void setNewChapter(Passage passage) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("book", passage.book);
    preferences.setInt("chapter", passage.chapter);
    preferences.setInt("verse", 1);
    setState(() {
      alignment = 0;
      displayPassage =
          displayPassage.then((_) => passage); // turn passage into a future xD
    });
    itemScrollController.jumpTo(index: 0);
  }

  void incrementChapter() async {
    Passage temp = await displayPassage
        .then((displayPassage) => helper.getNextChapterPassage(displayPassage));
    setNewChapter(temp);
  }

  void decrementChapter() async {
    Passage temp = await displayPassage.then(
        (displayPassage) => helper.getPreviousChapterPassage(displayPassage));
    setNewChapter(temp);
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

  List<Widget> versesToWidget(
      List<Verse> verseList, BuildContext scaffoldContext) {
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
            icon: Icon(Icons.arrow_upward),
            onPressed: () => itemScrollController.scrollTo(
                index: 0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInCubic)),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: this.incrementChapter,
        ),
      ],
    ));
    return list;
  }

  AppBar buildAppBar(Passage passage) {
    return AppBar(
      titleSpacing: 0.0,
      centerTitle: false,
      title: FlatButton(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "${short2long[passage.book]} ${passage.chapter}",
              style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20.0),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Color.fromRGBO(255, 255, 255, 1),
            )
          ],
        ),
        onPressed: () async {
          double localAlignment = firstItemPosition.itemLeadingEdge;
          Passage newVerse = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => SelectPassage()));
          if (newVerse != null) {
            setState(() {
              alignment = 0;
              displayPassage = displayPassage.then((_) => newVerse);
              itemScrollController.jumpTo(index: newVerse.verse - 1);
            });
          } else {
            setState(() {
              alignment = localAlignment;
            });
          }
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage(this.setSettings, this.fontSize)));
          },
        )
      ],
    );
  }

  void updatePositions(itemPositions) {
    this.firstItemPosition = itemPositions.toList()[0];
  }

  void buttonVisibilityListener() {
    bool forward = (scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
    if (buttonsVisible != forward) {
      this.setButtonsVisible(scrollController.position.userScrollDirection ==
          ScrollDirection.forward);
    }
  }

  Widget buildBody(List<Verse> verseList, int verse) {
    final ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();
    itemPositionsListener.itemPositions.addListener(
        () => updatePositions(itemPositionsListener.itemPositions.value));
    scrollController.addListener(this.buttonVisibilityListener);
    ScrollablePositionedList result = ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      scrollController: scrollController,
      itemCount: verseList.length + 1,
      itemBuilder: (context, index) {
        return versesToWidget(verseList, context)[index];
      },
      initialScrollIndex: verse - 1,
      initialAlignment: alignment,
    );
    return result;
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (this.buttonsVisible)
          Row(
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
        if (this.buttonsVisible)
          FloatingActionButton(
            onPressed: this.incrementChapter,
            child: Icon(Icons.arrow_forward_ios),
            heroTag: null,
          )
      ],
    );
  }

  Future<List<dynamic>> passageAndVerseList() async {
    Passage passage = await displayPassage.then((passage) => passage);
    List<Verse> verseList = await helper.getChapterFromPassage(passage);
    List<dynamic> retList = [passage, verseList];
    return retList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: passageAndVerseList(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          Passage localPassage = snapshot.data[0];
          List<Verse> verseList = snapshot.data[1];
          result = Scaffold(
            appBar: buildAppBar(localPassage),
            body: buildBody(verseList, localPassage.verse),
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
    preferences.setString(
        "book", await displayPassage.then((passage) => passage.book));
    preferences.setInt(
        "chapter", await displayPassage.then((passage) => passage.chapter));
    preferences.setInt("verse", firstItemPosition.index + 1);
    preferences.setDouble("alignment", firstItemPosition.itemLeadingEdge);
    preferences.setDouble("fontSize", fontSize);
  }
}
