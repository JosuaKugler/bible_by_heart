import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../backend/db_interaction.dart';

class FlipCueCard extends StatefulWidget {
  final Verse verse;
  final Function currentVerseLearned;
  final Function setMaxReachedState;
  final Function continueCurrentVerse;
  final Function currentVerseWrong;
  final Function buildFloatingActionButton;
  FlipCueCard(
      this.verse,
      this.currentVerseLearned,
      this.setMaxReachedState,
      this.continueCurrentVerse,
      this.currentVerseWrong,
      this.buildFloatingActionButton);
  @override
  _FlipCueCardState createState() => _FlipCueCardState();
}

class _FlipCueCardState extends State<FlipCueCard>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation _animation;
  AnimationStatus animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animation = Tween(end: 1.0, begin: 0.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        animationStatus = status;
      });
  }

  void superOnDismissed(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      bool localMaxReached = await widget.currentVerseLearned();
      if (localMaxReached) {
        widget.setMaxReachedState(true);
      } else {
        await widget.continueCurrentVerse();
        setState(() {
          animationController.reset();
        });
      }
    } else {
      await widget.currentVerseWrong();
      setState(() {
        animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            Text("Lernen"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Opacity(
                  opacity: animationController.value,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.done),
                        color: Color.fromARGB(255, 0, 255, 0),
                        iconSize: 40,
                        onPressed: (animationController.value == 1) ? () {
                          superOnDismissed(DismissDirection.startToEnd); //correct
                        } : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 40,
                        color: Colors.red,
                        onPressed: (animationController.value == 1) ? () {
                          superOnDismissed(DismissDirection.endToStart); //wrong
                        } : null,
                      ),
                    ],
                  ),
                ),
                (animationStatus != AnimationStatus.dismissed)
                    ? IconButton(
                        icon: Icon(Icons.sync),
                        iconSize: 40,
                        onPressed: () {
                          animationController.reverse();
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.sync),
                        iconSize: 40,
                        onPressed: () {
                          animationController.forward();
                        },
                      )
              ],
            ),
          ])),
      body: Container(
        color: Color.fromARGB(255, 27, 28, 30),
        child: Center(
          child: Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(pi * _animation.value),
            child: GestureDetector(
              onTap: () {
                if (animationStatus == AnimationStatus.dismissed) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              child: _animation.value <= 0.5
                  ? Container(
                      padding: EdgeInsets.all(0),
                      child: FrontSide(widget.verse),
                    )
                  : Container(
                      padding: EdgeInsets.all(0),
                      child: BackSide(widget.verse, this.superOnDismissed),
                    ),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.buildFloatingActionButton(context),
    );
  }
}

class FrontSide extends StatelessWidget {
  final Verse verse;
  FrontSide(this.verse);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Center(
          child: Image.asset(
            'assets/karteikarte.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(verse.passageString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.black)),
          ),
        ),
      ],
    );
  }
}

class BackSide extends StatelessWidget {
  final Verse verse;
  final Function superOnDismissed;
  BackSide(this.verse, this.superOnDismissed);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationX(pi),
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: superOnDismissed,
        direction: DismissDirection.horizontal,
        child: Stack(
          children: <Widget>[
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(pi),
              child: Center(
                child: Image.asset(
                  'assets/karteikarte.png',
                  width: size.width,
                  height: size.height,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('${verse.text}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black)),
              ),
            ),
          ],
        ),
        background: Container(
          alignment: Alignment(-0.9, 0),
          child: Icon(Icons.done, color: Colors.green, size: 80),
        ),
        secondaryBackground: Container(
          alignment: Alignment(0.9, 0),
          child: Icon(Icons.clear, color: Colors.red, size: 80),
        ),
      ),
    );
  }
}
