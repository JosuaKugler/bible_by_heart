import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'backend/db_interaction.dart';
import 'overview/overview_page.dart';
import 'learn/learn_page.dart';
import 'bible/bible_page.dart';

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
  final helper;
  @override
  Home(this.helper);
  _HomeState createState() => _HomeState(this.helper);
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  final helper;
  _HomeState(this.helper);

  void _onItemTapped(int index) {
    setState(() {
      this._selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _pages = <Widget>[
      OverviewPage(this.helper, this._onItemTapped),
      LearnPage(this.helper, this._onItemTapped),
      BiblePage(this.helper, this._onItemTapped),
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