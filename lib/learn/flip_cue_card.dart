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
  FlipCueCard(this.verse, this.currentVerseLearned, this.setMaxReachedState,
      this.continueCurrentVerse, this.currentVerseWrong);
  @override
  _FlipCueCardState createState() => _FlipCueCardState();
}

class _FlipCueCardState extends State<FlipCueCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween(end: 1.0, begin: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 27, 28, 30),
      child: Center(
        child: Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(pi * _animation.value),
          child: GestureDetector(
            onTap: () {
              if (_animationStatus == AnimationStatus.dismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
            child: _animation.value <= 0.5
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      color: Colors.lightGreenAccent,
                      child: Center(
                        child: Text(
                            '${short2long[widget.verse.book]} ${widget.verse.chapter}, ${widget.verse.verse}'),
                      ),
                    ),
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(pi),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Dismissible(
                        key: UniqueKey(),
                        onDismissed: (DismissDirection direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            bool localMaxReached =
                                await widget.currentVerseLearned();
                            if (localMaxReached) {
                              widget.setMaxReachedState(true);
                            } else {
                              await widget.continueCurrentVerse();
                              setState(() {
                                _animationStatus = AnimationStatus.completed;
                              });
                            }
                          } else {
                            await widget.currentVerseWrong();
                            setState(() {
                              _animationStatus = AnimationStatus.completed;
                            });
                          }
                        },
                        direction: DismissDirection.horizontal,
                        child: Container(
                          color: Colors.teal,
                          child: Center(child: Text('${widget.verse.text}')),
                        ),
                        background: Container(
                          color: Colors.green,
                          child: Text("Richtig"),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          child: Text("Falsch"),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
