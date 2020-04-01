import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DisplayToday extends StatelessWidget {
  final List<int> data;
  DisplayToday(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.teal[400],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("${data[3]}", style: TextStyle(fontSize: "${data[3]}".length == 1 ? 65 : "${data[3]}".length < 3 ? 40 : 20),),
              Text("${data[3] == 1 ? "Vers" : "Verse"}",style: TextStyle(fontSize: 20),),
            ],
          ),
          Text("hat die Bibel insgesamt", textAlign: TextAlign.left, style: TextStyle(fontSize: 16),)
        ],
      ),
    );
  }
}