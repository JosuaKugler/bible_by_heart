import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';
import '../learn/select_verse_page.dart';

class DisplayCurrent extends StatelessWidget {
  final List<int> data;
  DisplayCurrent(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.teal[200],
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "${data[1]}",
                style: TextStyle(
                    fontSize: "${data[1]}".length == 1
                        ? 65
                        : "${data[3]}".length < 3 ? 40 : 20),
              ),
              Text(
                "${data[1] == 1 ? "Vers" : "Verse"}",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            "aktuell am Lernen",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}

class CurrentList extends StatefulWidget {
  @override
  _CurrentListState createState() => _CurrentListState();
}

class _CurrentListState extends State<CurrentList> {
  Future<List<Verse>> currentVerses;

  @override
  void initState() {
    super.initState();
    currentVerses = helper.getVersesOnLearnStatus(LearnStatus.current);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: currentVerses,
      builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
              appBar: AppBar(
                title: Text("Lernverse"),
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
                  helper.setLearnStatus(newVerseId, LearnStatus.current);
                  setState(() {
                    currentVerses = helper
                        .getVersesOnLearnStatus(LearnStatus.current);
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
                                  snapshot.data[index].id,
                                  LearnStatus.selected);
                            }
                          },
                          key: UniqueKey(),
                          secondaryBackground: Container(
                            child: Text(
                              'Nicht lernen',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.red,
                            alignment: Alignment(0.8, 0.0),
                          ),
                          background: Container(
                            child: Text(
                              'Vormerken',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green,
                            alignment: Alignment(-0.8, 0.0),
                          ),
                          child: ListTile(
                            title: Text(
                                '${snapshot.data[index].book} ${snapshot.data[index].chapter}, ${snapshot.data[index].verse}'),
                            subtitle: Text(
                                '${snapshot.data[index].text}, ${snapshot.data[index].correct} out of ${snapshot.data[index].maxCorrect}'),
                          ),
                        );
                      })
                  : Center(
                      child: Text('Noch keine Verse'),
                    ));
        } else if (snapshot.hasError) {
          result = Text('$snapshot.error');
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Lernverse"),
            ),
            body: Text("Laden..."),
          );
        }
        return result;
      },
    );
  }
}
