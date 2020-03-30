import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'db_interaction.dart';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final DataBaseHelper helper;
  MyApp() : helper = DataBaseHelper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bibel lernen',
      home: Home(this.helper),
    );
  }
}


class Home extends StatefulWidget {
  final DataBaseHelper helper;
  Home(this.helper);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}




/*
class VerseScaffold extends StatefulWidget {
  final DataBaseHelper helper;
  final Passage initial;
  final String title;
  VerseScaffold(this.helper, this.initial, this.title);

  @override
  _VerseScaffoldState createState() => _VerseScaffoldState(this.helper, this.initial);
}

class _VerseScaffoldState extends State<VerseScaffold> {
  final DataBaseHelper helper;
  Future<Verse> _verse;
  _VerseScaffoldState(this.helper, Passage initial) : _verse = helper.getVerseFromPassage(initial);
  
  Future<void> nextVerse() async {
    this._verse.then(
            (verse) => setState(() {this._verse = this.helper.getRelativeVerse(verse.toPassage(), 1);})
    );
  }

  Future<void> prevVerse() async {
    this._verse.then(
            (verse) => setState(() {this._verse = this.helper.getRelativeVerse(verse.toPassage(), -1);})
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Verse>(
      future: this._verse, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<Verse> snapshot) {
        Widget result;

        if (snapshot.hasData) {
          result = Scaffold(
            appBar: AppBar(
              title: Text("${snapshot.data.book} ${snapshot.data.chapter}, ${snapshot.data.verse}"),
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(snapshot.data.text, style: TextStyle(fontSize: 30.0),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: prevVerse,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: nextVerse,
                      )
                    ],
                  )
                ],
            ),
          );
        } else if (snapshot.hasError) {
          result = Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: Center(
                child: Text(snapshot.error)
              ),
          );
        } else {
          result = Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
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

 */
