import 'package:flutter/material.dart';
import 'package:walkline/action.dart';
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
  var setlist = <Offset>[];
  Offset _oldPos; //记录上一点

  @override
  Widget build(BuildContext context) {
    var body = CustomPaint(
      size: Size(300, 300),
      painter: MyPaint(lines: _lines),


//  var body = Center(
//    child: Container(
//      padding: EdgeInsets.all(10.0),
//      color: Colors.amberAccent,
//      child: Container(
//        child: SizedBox(
//          height: 500,
//          width: 500,
//          child: CustomPaint(
//            size: Size(500,500),
//            painter: MyPaint(lines: _lines),
//          ),
//        ),
//      ),
//
//    ),


//      var body = Center(
//
//        child: SizedBox(
//
//          height: 500,
//          width: 500,
//        ),



//      child: RepaintBoundary(
//        child: new RaisedButton(
//          onPressed: () {
//            _lines.clear();
//            _render();
//          },
//          color: Colors.blue[400],
//          child: new Text(
//            "clean",
//            style: new TextStyle(color: Colors.white),
//          ),
//        ),
//      ),
    );

    var scaffold = Scaffold(
//      appBar: AppBar(
//        title: Text("画图控制"),
//      ),
      body: body,
    );

    var result = GestureDetector(
      child: scaffold,
      onPanDown: _pandown,
      onPanEnd: _panend,
      onPanUpdate: _panupdate,
//      onDoubleTap: () {
//        _lines.clear();
//        _render();
//      },
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

  void _render() {
    setState(() {});
  }

  void _panupdate(DragUpdateDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    var currentPos = Offset(x, y);
    if ((currentPos - _oldPos).distance > 3) {
//      var lenth = (currentPos - _oldPos).distance;
//      var width = 40 * pow(lenth, -1.2);
      var circle = CircleInLine(Colors.blue, currentPos, radius: 4);
      _positions.add(circle);
      _oldPos = currentPos;

      setlist.add(currentPos);
      _render();
    }
  }

  void _panend(DragEndDetails details) {
    var oldline = <CircleInLine>[];
    for (int i = 0; i < _positions.length; i++) {
      oldline.add(_positions[i]);
    }
    _lines.add(oldline);
    _positions.clear();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(" "),
              content: Text("是否发送"),
              contentTextStyle: TextStyle(color: Colors.green),
              backgroundColor: Colors.white,
              elevation: 8.0,
              semanticLabel: 'Label',
              // 这个用于无障碍下弹出 dialog 的提示
//              shape: Border.all(),
              // dialog 的操作按钮，actions 的个数尽量控制不要过多，否则会溢出 `Overflow`
              actions: <Widget>[
                // 点击增加显示的值
                FlatButton(
                    onPressed: () {
                      print("确认成功");
                      sendpath();
                      Navigator.pop(context);
                      _lines.clear();
                      setlist.clear();
                      _render();
                    },
                    child: Text('确认')),
                // 点击减少显示的值
                FlatButton(
                    onPressed: () {
                      print("取消成功");
                      Navigator.pop(context);
                      _lines.clear();
                      setlist.clear();
                      _render();
                    },
                    child: Text('取消')),
              ],
            ));
  }

  void sendpath() {
    int length=0;
    for (int i = 1; i < setlist.length; i++) {
      var k = (setlist[i - 1].dy - setlist[i].dy) *
          1.0 /
          (setlist[i].dx - setlist[i - 1].dx);
      k = atan(k) * 180 / pi;
      if (setlist[i].dx >= setlist[i - 1].dx) {
        if (k < 0) k = 360 + k;
      } else {
          k = 180 + k;
      }
      length = 20*sqrt(
          pow(setlist[i].dy -setlist[i - 1].dy, 2) +
              pow(setlist[i].dx - setlist[i - 1].dx, 2))
          .toInt();
//      print(k);
      Action item = new Action(0, 20, k.toInt(), 0, 0, 0,length);
      print(item);
    }
  }
}
