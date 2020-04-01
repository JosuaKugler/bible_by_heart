import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function setSettings;
  final double oldFontSize;
  SettingsPage(this.setSettings, this.oldFontSize);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double sliderValue;

  @override
  void initState() {
    super.initState();
    sliderValue = widget.oldFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen Bibel"),
      ),
      body: Column(
        children: <Widget>[
          Row(children: [Text("Schriftgröße:", style: TextStyle(fontSize: 20),),]),
          Slider(
            onChanged: (double value) {
              setState(() {
                sliderValue = value;
                widget.setSettings(sliderValue);
              });
            },
            value: sliderValue,
            min: 8.0,
            max: 30.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            //child: Text(_getSliderTips()),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Und Gott sprach: Es werde Licht! und es ward Licht.",
            style: TextStyle(fontSize: sliderValue),
          ),
        ],
      ),
    );
  }
}
