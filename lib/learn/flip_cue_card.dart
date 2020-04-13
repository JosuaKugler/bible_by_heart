import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    double iconSize = 30;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).accentColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 56,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DefaultTextStyle(
                      style: Theme.of(context).primaryTextTheme.title,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      child: Semantics(
                        child: Text("Lernen"),
                        header: true,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 56,
                width: 220,
                child: Stack(children: [
                  Positioned(
                    height: 60,
                    bottom: 0,
                    width: 112,
                    right: animationController.value * 80 - 30,
                    child: Row(
                      children: <Widget>[
                        Center(
                          child: IconButton(
                              icon: Icon(
                                Icons.done,
                              ),
                              color: Color.fromARGB(255, 0, 255, 0),
                              iconSize: iconSize,
                              onPressed: (animationController.value == 1)
                                  ? () {
                                      superOnDismissed(DismissDirection
                                          .startToEnd); //correct
                                    }
                                  : () {}),
                        ),
                        IconButton(
                          icon: Icon(Icons.clear),
                          iconSize: iconSize,
                          color: Colors.red,
                          onPressed: (animationController.value == 1)
                              ? () {
                                  superOnDismissed(
                                      DismissDirection.endToStart); //wrong
                                }
                              : () {},
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      width: 70,
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Container(color: Theme.of(context).accentColor)),
                  Positioned(
                    right: 10,
                    bottom: 0,
                    height: 56,
                    child: Row(
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 2,
                            height: 56,
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: (animationStatus != AnimationStatus.dismissed)
                              ? IconButton(
                                  icon: Icon(Icons.sync),
                                  color: Colors.white,
                                  iconSize: iconSize,
                                  onPressed: () {
                                    animationController.reverse();
                                  },
                                )
                              : IconButton(
                                  icon: Icon(Icons.sync),
                                  iconSize: iconSize,
                                  color: Colors.white,
                                  onPressed: () {
                                    animationController.forward();
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('${verse.text}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black)),
                      Text(
                        '${verse.passageString()}',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      )
                    ],
                  ),
                ),
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
