import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';
import 'display_selected_page.dart';

class OverviewPage extends StatelessWidget {
  final DataBaseHelper helper;
  OverviewPage(this.helper);

  Future<List<int>> getData() async {
    return [1,2,3,4,5];
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
                    onTap: () {},//show selected Verses in dismissible listView
                    child: DisplaySelected(snapshot.data),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text('Heed not the rabble'),
                  color: Colors.teal[200],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text('Sound of screams but the'),
                  color: Colors.teal[300],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text('Who scream'),
                  color: Colors.teal[400],
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          result = Text("${snapshot.error}");
        } else {
          result = Text("Awaiting result");
        }
        return result;
      },
    );

  }
}