import 'package:bible_by_heart/backend/db_interaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../learn/select_verse_page.dart';
import 'detail_page.dart';

class Display extends StatelessWidget {
  final List<int> data;
  final List<String> displayText;
  final int index;
  Display(this.data, this.displayText, this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.teal[100 * (index + 1)],
      constraints: BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "${data[index]}",
                style: TextStyle(
                    fontSize: "${data[index]}".length == 1
                        ? 65
                        : "${data[index]}".length < 3 ? 40 : 20),
              ),
              Text(
                "${data[index] == 1 ? "Vers" : "Verse"}",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            displayText[index],
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  final Function rebuild;
  final String appBarTitle;
  final LearnStatus learnStatus;
  final List<String> dismissMessage;
  final List<LearnStatus> dismissStatus;
  final String noVerses;
  
  CategoryList(this.rebuild, this.appBarTitle, this.learnStatus, this.dismissMessage, this.dismissStatus, this.noVerses);
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  Future<List<Verse>> categoryVerses;

  @override
  void initState() {
    super.initState();
    categoryVerses = helper.getVersesOnLearnStatus(widget.learnStatus);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: helper.getVersesOnLearnStatus(widget.learnStatus),
      builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
        Widget result;
        if (snapshot.hasData) {
          result = Scaffold(
              appBar: AppBar(
                title: Text(widget.appBarTitle),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () async {
                  Passage newVerse = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SelectPassage()));
                  if (newVerse != null) {
                    int newVerseId = await helper.getIdFromPassage(newVerse);
                    helper.setLearnStatus(newVerseId, widget.learnStatus);
                    setState(() {
                      categoryVerses =
                          helper.getVersesOnLearnStatus(widget.learnStatus);
                    });
                    widget.rebuild();
                  }
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
                                  snapshot.data[index].id, widget.dismissStatus[1]);
                            } else {
                              await helper.setLearnStatus(
                                  snapshot.data[index].id, widget.dismissStatus[0]);
                            }
                            widget.rebuild();
                          },
                          key: UniqueKey(),
                          secondaryBackground: Container(
                            child: Text(
                              widget.dismissMessage[1],
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.red,
                            alignment: Alignment(0.8, 0.0),
                          ),
                          background: Container(
                            child: Text(
                              widget.dismissMessage[0],
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.green,
                            alignment: Alignment(-0.8, 0.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => DetailPage(widget.rebuild, snapshot.data[index], widget.learnStatus)
                              ));
                            },
                            child: ListTile(
                              title: Text(snapshot.data[index].passageString()),
                              subtitle: Text('${snapshot.data[index].text}'),
                            ),
                          ),
                        );
                      })
                  : Center(
                      child: Text(widget.noVerses),
                    ));
        } else if (snapshot.hasError) {
          result = Text('$snapshot.error');
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text(widget.appBarTitle),
            ),
            body: Text("Laden..."),
          );
        }
        return result;
      },
    );
  }
}
