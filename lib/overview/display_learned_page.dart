import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';

class DisplayLearned extends StatelessWidget {
  final List<int> data;
  DisplayLearned(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.teal[300],
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "${data[2]}",
                style: TextStyle(
                    fontSize: "${data[2]}".length == 1
                        ? 65
                        : "${data[3]}".length < 3 ? 40 : 20),
              ),
              Text(
                "${data[2] == 1 ? "Vers" : "Verse"}",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            "bereits gelernt",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}

class LearnedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: helper.getVersesOnLearnStatus(LearnStatus.learned),
      builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Gelernte Verse"),
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
                            'Lernstatus zurücksetzen',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.red,
                          alignment: Alignment(0.8, 0.0),
                        ),
                        background: Container(
                          child: Text(
                            'Nochmal Lernen',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.green,
                          alignment: Alignment(-0.8, 0.0),
                        ),
                        child: ListTile(
                          title: Text(snapshot.data[index].passageString()),
                          subtitle: Text('${snapshot.data[index].text}'),
                        ),
                      );
                    })
                : Center(
                    child: Text('Noch keine Verse'),
                  ),
          );
        } else if (snapshot.hasError) {
          result = Text('$snapshot.error');
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text("Gelernte Verse"),
            ),
            body: Text("Laden..."),
          );
        }
        return result;
      },
    );
  }
}
