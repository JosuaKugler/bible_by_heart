import 'package:bible_by_heart/backend/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../learn/select_verse_page.dart';

class DisplaySelected extends StatelessWidget {
  final List<int> data;
  DisplaySelected(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.teal[100],
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "${data[0]}",
                style: TextStyle(
                    fontSize: "${data[0]}".length == 1
                        ? 65
                        : "${data[3]}".length < 3 ? 40 : 20),
              ),
              Text(
                "${data[0] == 1 ? "Vers" : "Verse"}",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            "zum Lernen vorgemerkt",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}

class SelectedList extends StatefulWidget {
  @override
  _SelectedListState createState() => _SelectedListState();
}

class _SelectedListState extends State<SelectedList> {
  Future<List<Verse>> selectedVerses;

  @override
  void initState() {
    super.initState();
    selectedVerses = helper.getVersesOnLearnStatus(LearnStatus.selected);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: helper.getVersesOnLearnStatus(LearnStatus.selected),
      builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
              appBar: AppBar(
                title: Text("Vorgemerkte Verse"),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () async {
                  Passage newVerse = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectPassage()));
                  int newVerseId =
                      await helper.getIdFromPassage(newVerse);
                  helper.setLearnStatus(newVerseId, LearnStatus.selected);
                  setState(() {
                    selectedVerses = helper
                        .getVersesOnLearnStatus(LearnStatus.selected);
                  });
                },
              ),
              body: (snapshot.data.length > 0)
                  ? ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          onDismissed: (DismissDirection direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await helper.setLearnStatus(
                                  snapshot.data[index].id, LearnStatus.none);
                            } else {
                              await helper.setLearnStatus(
                                  snapshot.data[index].id, LearnStatus.current);
                            }
                          },
                          key: UniqueKey(),
                          secondaryBackground: Container(
                            child: Text(
                              'Nicht vormerken',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.red,
                            alignment: Alignment(0.8, 0.0),
                          ),
                          background: Container(
                            child: Text(
                              'Lernen',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green,
                            alignment: Alignment(-0.8, 0.0),
                          ),
                          child: ListTile(
                            title: Text(
                                '${snapshot.data[index].book} ${snapshot.data[index].chapter}, ${snapshot.data[index].verse}'),
                            subtitle: Text('${snapshot.data[index].text}'),
                          ),
                        );
                      })
                  : Center(
                      child: Text('Noch keine Verse gelernt'),
                    ));
        } else if (snapshot.hasError) {
          result = Text('$snapshot.error');
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Vorgemerkte Verse"),
            ),
            body: Text("Laden..."),
          );
        }
        return result;
      },
    );
  }
}
