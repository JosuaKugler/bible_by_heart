import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';
import 'display_selected_page.dart';
import 'display_current_page.dart';
import 'display_learned_page.dart';
import 'display_today_page.dart';

class OverviewPage extends StatelessWidget {
  final Function _onItemTapped;
  OverviewPage(this._onItemTapped);

  Future<List<int>> getData() async {
    final selected = await helper.getVersesOnLearnStatus(LearnStatus.selected);
    final current = await helper.getVersesOnLearnStatus(LearnStatus.current);
    final learned = await helper.getVersesOnLearnStatus(LearnStatus.learned);
    return [selected.length,current.length,learned.length,31172];//data for selected, current etc.
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Übersicht"),
            ),
            body: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 40,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => SelectedList(),
                      ));
                    },//show selected Verses in dismissible listView
                    child: DisplaySelected(snapshot.data),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => CurrentList(),
                        ));
                  }, //show current Verses in dismissible listView (with stats for each verse?)
                  child: DisplayCurrent(snapshot.data),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => LearnedList(),
                        ));
                  }, //show learned Verses in listView (with stats for each verse?)
                  child: DisplayLearned(snapshot.data),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: DisplayToday(snapshot.data),
                ),
              ],
            ),
          );
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