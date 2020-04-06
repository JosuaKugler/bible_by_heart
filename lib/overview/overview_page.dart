import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../backend/db_interaction.dart';
import 'display_page.dart';

class OverviewPage extends StatefulWidget {
  final Function _onItemTapped;
  OverviewPage(this._onItemTapped);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  Future<List<int>> data;

  @override
  initState() {
    super.initState();
    data = getData();
  }

  Future<List<int>> getData() async {
    final selected = await helper.getVersesOnLearnStatus(LearnStatus.selected);
    final current = await helper.getVersesOnLearnStatus(LearnStatus.current);
    final learned = await helper.getVersesOnLearnStatus(LearnStatus.learned);
    return [
      selected.length,
      current.length,
      learned.length,
      31172
    ]; //data for selected, current etc.
  }

  final List<String> appBarTitle = [
    "Vorgemerkte Verse",
    "Lernverse",
    "Gelernte Verse"
  ];
  final List<LearnStatus> learnStatus = [
    LearnStatus.selected,
    LearnStatus.current,
    LearnStatus.learned
  ];
  final List<List<String>> dismissMessage = [
    ["Lernen", "Status löschen"],
    ["Kann ich schon", "Status löschen"],
    ["Nochmal Lernen", "Status löschen"]
  ];
  final List<List<LearnStatus>> dismissStatus = [
    [LearnStatus.current, LearnStatus.none],
    [LearnStatus.learned, LearnStatus.none],
    [LearnStatus.current, LearnStatus.none]
  ];
  final List<String> noVerses = [
    "keine Verse vorgemerkt",
    "aktuell keine Lernverse",
    "keine Verse gelernt"
  ];
  final List<String> displayText = [
    "zum Lernen vorgemerkt",
    "aktuell am Lernen",
    "bereits gelernt",
    "hat die Bibel insgesamt",
  ];

  void rebuild() {
    print("rebuild is called");
    setState(() {
      data = getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: data,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
              appBar: AppBar(
                title: Text("Übersicht"),
              ),
              body: GridView.builder(
                itemCount: 4,
                primary: false,
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 40),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryList(
                            this.rebuild,
                            this.appBarTitle[index],
                            this.learnStatus[index],
                            this.dismissMessage[index],
                            this.dismissStatus[index],
                            this.noVerses[index],
                          ),
                        ));
                  }, //show selected Verses in dismissible listView
                  child: Display(snapshot.data, displayText, index),
                ),
              ));
        } else if (snapshot.hasError) {
          result = Text("${snapshot.error}");
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text('Übersicht'),
            ),
            body: Center(
              child: Text("Laden..."),
            ),
          );
        }
        return result;
      },
    );
  }
}
