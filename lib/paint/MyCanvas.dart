import 'package:flutter/material.dart';
import 'dart:math';

import 'package:walkline/paint/CircleInLine.dart';
import 'package:walkline/paint/MyPaint.dart';

class Mycanvas extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MycanvasState();
}

class _MycanvasState extends State<Mycanvas> {
  var _positions = <CircleInLine>[];
  var _lines = <List<CircleInLine>>[];
  Offset _oldPos; //记录上一点


  @override
  Widget build(BuildContext context){

    var body = CustomPaint(
      painter: MyPaint(lines: _lines),
    );

    var scaffold = Scaffold(
      body: body,
    );

    var result = GestureDetector(
      child: scaffold,
      onPanDown: _pandown,
      onPanEnd: _panend,
      onPanUpdate:_panupdate,
      onDoubleTap: (){
        _lines.clear();
        _render();
      },
    );

    return result;
  }





  void _pandown(DragDownDetails details) {
    print(details.toString());
    _lines.add(_positions);
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    _oldPos = Offset(x, y);
  }

  void _render(){
    setState(() {

    });
  }

  void _panupdate(DragUpdateDetails details){
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    var currentPos = Offset(x, y);
    if((currentPos-_oldPos).distance>3){
      var lenth = (currentPos-_oldPos).distance;
      var width = 40*pow(lenth,-1.2);
      var circle = CircleInLine(Colors.red,currentPos,radius: width);
      _positions.add(circle);
      _oldPos=currentPos;
      _render();
    }
  }


  void _panend(DragEndDetails details){
    var oldline = <CircleInLine>[];
    for(int i=0;i<_positions.length;i++){
      oldline.add(_positions[i]);
    }
    _lines.add(oldline);
    _positions.clear();
    print(_lines.toString());
  }
}
