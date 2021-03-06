import 'package:flutter/material.dart';

import 'bible/bible_page.dart';
import 'learn/learn_page.dart';
import 'overview/overview_page.dart';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BibleByHeart',
      home: Home(),
    );
  }
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      this._selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _pages = <Widget>[
      OverviewPage(this._onItemTapped),
      LearnPage(),
      BiblePage(),
    ];
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Übersicht'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('Lernen'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            title: Text('Bibel'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}