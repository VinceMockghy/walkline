import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:walkline/action.dart';
import 'package:flutter_bt_bluetooth/flutter_bt_bluetooth.dart';

typedef GestureTapCallback = void Function();

class LockPattern extends StatefulWidget {
  ///与父布局的间距
  final double padding;

  ///圆之间的间距比例(以圆半径作为基准)
  final double roundSpaceRatio;

  ///默认颜色
  final Color defaultColor;

  ///线长度
  final double lineWidth;

  ///实心圆半径比例(以圆半径作为基准)
  final double solidRadiusRatio;

  ///触摸有效区半径比较(以圆半径作为基准)
  final double touchRadiusRatio;

  ///延迟显示时间
  final int delayTime;

  ///回调
  final Function(List<int>) onCompleted;

  final BlueViewController controller;

  final _LockPatternState _state = _LockPatternState();

  LockPattern(
      {@required this.controller,
      this.padding = 10,
      this.roundSpaceRatio = 0.6,
      this.defaultColor = Colors.blue,
      this.lineWidth = 2,
      this.solidRadiusRatio = 0.4,
      this.touchRadiusRatio = 0.6,
      this.delayTime = 500,
      this.onCompleted});

  @override
  _LockPatternState createState() {
    return _state;
  }

  void updateStatus() {
    _state.updateStatus();
  }
}

class _LockPatternState extends State<LockPattern> {
  RenderBox _box;

  ///发送数据
  List<Action> _actions = [];

  ///九宫格圆
  List<Round> _rounds = List<Round>(9);

  ///选中圆位置
  List<int> _selected = [];

  ///最后触摸位置
  Offset _lastTouchPoint;
  double _radius;
  double _solidRadius;
  double _touchRadius;
  Timer _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_timer?.isActive == true) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var custom = CustomPaint(
        size: Size.infinite,
        painter: LockPatternPainter(_rounds, _selected, _lastTouchPoint,
            _radius, _solidRadius, widget.lineWidth, widget.defaultColor));

    return GestureDetector(
        child: custom,
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        onPanUpdate: _onPanUpdate);
  }

  void updateStatus() {
    if (_selected.length != 0) {
      print(1);
      _timer = Timer(Duration(milliseconds: widget.delayTime), () {
//      print(2);
        int time = 0;
        print(4);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Text(" "),
                  content: Text("是否发送"),
                  contentTextStyle:
                      TextStyle(color: Colors.green, fontSize: 20.0),
                  backgroundColor: Colors.white,
                  elevation: 8.0,
                  semanticLabel: 'Label',
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          print("确认成功");
                          getpath();
                          time = sendpath();
                          showDialog(
                            context: context,
                            barrierDismissible: false, //点击遮罩不关闭对话框
                            builder: (context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    CircularProgressIndicator(),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 26.0),
                                      child: Text("正在发送，请稍后..."),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                          Timer.periodic(Duration(milliseconds: time), (timer) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            clear();
                            timer.cancel();
                            timer = null;
                          });
                        },
                        child: Text('确认')),
                    FlatButton(
                        onPressed: () {
                          print("取消成功");
                          Navigator.pop(context);
                          clear();
                        },
                        child: Text('取消')),
                  ],
                ));
      });
      print(3);
    }
  }

  void getpath() {
    int length = 0;
    int base = 20;
    for (int i = 1; i < _selected.length; i++) {
      var k = (_rounds[_selected[i]].x - _rounds[_selected[i - 1]].x).abs() *
          1.0 /
          (_rounds[_selected[i]].y - _rounds[_selected[i - 1]].y).abs();
      k = atan(k) * 180 / pi;
      if (_rounds[_selected[i]].y > _rounds[_selected[i - 1]].y) {
        if (_rounds[_selected[i]].x > _rounds[_selected[i - 1]].x)
          k = k + 90;
        else if (_rounds[_selected[i]].x < _rounds[_selected[i - 1]].x)
          k = 360 - 90 - k;
        else
          k = 180;
      } else if (_rounds[_selected[i]].y < _rounds[_selected[i - 1]].y) {
        if (_rounds[_selected[i]].x < _rounds[_selected[i - 1]].x) k = 360 - k;
      } else if (_rounds[_selected[i]].x < _rounds[_selected[i - 1]].x) k = 270;
      print(k);

      length = base *
          sqrt(pow(_rounds[_selected[i]].y - _rounds[_selected[i - 1]].y, 2) +
                  pow(_rounds[_selected[i]].x - _rounds[_selected[i - 1]].x, 2))
              .toInt();

      Action item = new Action(0, 30, k.toInt(), 0, 0, 0, length);
      _actions.add(item);
    }
    _actions.add(new Action(0, 0, 0, 0, 0, 0, 0));
  }

  int sendpath() {
    int delaytimeforsend = 0;
    for (Action item in _actions) {
      Timer.periodic(Duration(milliseconds: delaytimeforsend), (timer) {
        print(item);
//        widget.controller.sendMsg(item.toString());
        timer.cancel();
        timer = null;
      });
      delaytimeforsend += item.len;
    }
    return delaytimeforsend;
  }

  void clear() {
    for (Round round in _rounds) {
      round.status = LockPatternStatus.Default;
    }
    _selected.clear();
    _actions.clear();
    setState(() {});
  }

  _init(_) {
    _box = context.findRenderObject() as RenderBox;
    var size = context.size;
    if (size.width > size.height) {
      throw Exception("LockPattern width must <= height");
    }
    var width = size.width;
    _radius =
        (width - widget.padding * 2) / (3 + widget.roundSpaceRatio * 2) / 2;
    var roundSpace = _radius * 2 * widget.roundSpaceRatio;
    _solidRadius = _radius * widget.solidRadiusRatio;
    _touchRadius = _radius * widget.touchRadiusRatio;
    for (int i = 0; i < _rounds.length; i++) {
      var row = i ~/ 3;
      var column = i % 3;
      var dx = widget.padding + column * (_radius * 2 + roundSpace) + _radius;
      var dy = widget.padding + row * (_radius * 2 + roundSpace) + _radius;
      _rounds[i] = Round(dx, dy, LockPatternStatus.Default);
    }
    setState(() {});
  }

  _init_custom(_) {
    _box = context.findRenderObject() as RenderBox;
    var size = context.size;
    if (size.width > size.height) {
      throw Exception("LockPattern width must <= height");
    }

    var width = size.width;

    _radius =
        (width - widget.padding * 2) / (3 + widget.roundSpaceRatio * 2) / 2;
//    var roundSpace = _radius * 2 * widget.roundSpaceRatio;

    _solidRadius = _radius * widget.solidRadiusRatio;
    _touchRadius = _radius * widget.touchRadiusRatio;

    {
      _rounds = List<Round>(4);
      _rounds[0] = Round(5, 5, LockPatternStatus.Default);
      _rounds[1] = Round(50, 50, LockPatternStatus.Default);
      _rounds[2] = Round(150, 150, LockPatternStatus.Default);
      _rounds[3] = Round(250, 250, LockPatternStatus.Default);
    }
    setState(() {});
  }

  _onPanStart(DragStartDetails detail) {
    setState(() {
      var position = _box.globalToLocal(detail.globalPosition);
      for (int i = 0; i < _rounds.length; i++) {
        var round = _rounds[i];
        if (round.status == LockPatternStatus.Default &&
            round.contains(position, _touchRadius)) {
          round.status = LockPatternStatus.Success;
          _selected.add(i);
          break;
        }
      }
    });
  }

  _onPanUpdate(DragUpdateDetails detail) {
    setState(() {
      var position = _box.globalToLocal(detail.globalPosition);
      for (int i = 0; i < _rounds.length; i++) {
        var round = _rounds[i];
        if (round.status == LockPatternStatus.Default &&
            round.contains(position, _touchRadius)) {
          round.status = LockPatternStatus.Success;
          _selected.add(i);
          break;
        }
      }

      ///判断触摸点是否超出widget大小
      double x = position.dx;
      double y = position.dy;
      if (x > context.size.width) {
        x = context.size.width;
      } else if (x < 0) {
        x = 0;
      }

      if (y > context.size.height) {
        y = context.size.height;
      } else if (y < 0) {
        y = 0;
      }

      _lastTouchPoint = Offset(x, y);
    });
  }

  _onPanEnd(DragEndDetails detail) {
    _lastTouchPoint = null;
    if (widget.onCompleted != null) {
      widget.onCompleted(_selected);
    }
  }
}

class LockPatternPainter extends CustomPainter {
  List<Round> _rounds;
  List<int> _selected;
  Offset _lastTouchPoint;
  double _radius;
  double _solidRadius;
  double _lineWidth;
  Color _defaultColor;

  LockPatternPainter(this._rounds, this._selected, this._lastTouchPoint,
      this._radius, this._solidRadius, this._lineWidth, this._defaultColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (_radius == null) return;
    var paint = Paint();

    ///画圆
    _paintRound(canvas, paint);

    ///画线
    _paintLine(canvas, paint);
  }

  _paintRound(Canvas canvas, Paint paint) {
    for (Round round in _rounds) {
      switch (round.status) {
        case LockPatternStatus.Default:
          {
            paint.color = _defaultColor;
            paint.style = PaintingStyle.fill;
            canvas.drawCircle(round.toOffset(), _solidRadius, paint);
            break;
          }
        case LockPatternStatus.Success:
          {
            paint.color = _defaultColor;
            canvas.drawCircle(round.toOffset(), _solidRadius, paint);
            paint.color = _defaultColor.withAlpha(20);
            canvas.drawCircle(round.toOffset(), _radius, paint);
            break;
          }
      }
    }
  }

  _paintLine(Canvas canvas, Paint paint) {
    if (_selected.isNotEmpty) {
      paint.color = _defaultColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = _lineWidth;
      var path = Path();
      for (int i = 0; i < _selected.length; i++) {
        var index = _selected[i];
        if (i == 0) {
          path.moveTo(_rounds[index].x, _rounds[index].y);
        } else {
          path.lineTo(_rounds[index].x, _rounds[index].y);
        }
      }
      if (_lastTouchPoint != null) {
        path.lineTo(_lastTouchPoint.dx, _lastTouchPoint.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum LockPatternStatus { Default, Success }

class Round {
  double x;
  double y;
  LockPatternStatus status;

  Round(this.x, this.y, this.status);

  Offset toOffset() {
    return Offset(x, y);
  }

  bool contains(Offset offset, radius) {
    return sqrt(pow(offset.dx - x, 2) + pow(offset.dy - y, 2)) < radius;
  }

  @override
  String toString() {
    return "($x,$y)";
  }
}
