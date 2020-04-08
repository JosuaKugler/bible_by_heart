import 'package:flutter/material.dart';
import '../backend/db_interaction.dart';

class SearchResults extends StatelessWidget {
  final String searchTerm;
  final Function setNewChapter;
  SearchResults(this.searchTerm, this.setNewChapter);

  @override
  Widget build(BuildContext context) {
    return (searchTerm.length < 3)
        ? Center(
            child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Text('Nicht genug Text, gib mindestens drei Buchstaben ein'),
          ))
        : FutureBuilder(
            future: helper.getAllVersesMatching(searchTerm),
            builder: (context, AsyncSnapshot<List<Verse>> snapshot) {
              Widget result;
              if (snapshot.hasData) {
                result = ListView.builder(
                    itemCount: snapshot.data.length + 1,
                    itemBuilder: (context, index) {
                      return (index == 0)
                          ? ListTile(
                              title: (snapshot.data.length == 1)
                                  ? Text('1 Suchergebnis')
                                  : Text(
                                      '${snapshot.data.length} Suchergebnisse'),
                            )
                          : ListTile(
                              title: Text(
                                  snapshot.data[index - 1].passageString()),
                              subtitle: Text(snapshot.data[index - 1].text),
                              onTap: () {
                                setNewChapter(
                                    snapshot.data[index - 1].toPassage());
                                Navigator.pop(context);
                              },
                            );
                    });
                //Scaffold.of(context).showSnackBar(SnackBar(content: Text('${snapshot.data.length} Ergebnisse'),));
              } else if (snapshot.hasError) {
                result = Center(
                  child: Text('${snapshot.error}'),
                );
              } else {
                result = Center(
                  child: Text('Laden...'),
                );
              }
              return result;
            },
          );
  }
}
