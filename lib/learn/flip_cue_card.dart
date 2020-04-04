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

  void superOnDismissed(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      bool localMaxReached = await widget.currentVerseLearned();
      if (localMaxReached) {
        widget.setMaxReachedState(true);
      } else {
        await widget.continueCurrentVerse();
        setState(() {
          _animationController.reset();
        });
      }
    } else {
      await widget.currentVerseWrong();
      setState(() {
        _animationController.reset();
      });
    }
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
                    child: FrontSide(widget.verse),
                  )
                : Container(
                    padding: EdgeInsets.all(20),
                    child: BackSide(widget.verse, this.superOnDismissed),
                  ),
          ),
        ),
      ),
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
          child: new Image.asset(
            'assets/karteikarte.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: Text(
              '${short2long[verse.book]} ${verse.chapter}, ${verse.verse}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                  color: Colors.black)),
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
            Center(
              child: new Image.asset(
                'assets/karteikarte.png',
                width: size.width,
                height: size.height,
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Text('${verse.text}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ],
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
    );
  }
}
