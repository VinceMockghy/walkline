import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:walkline/action.dart';

typedef GestureTapCallback = void Function();

class LockPattern extends StatefulWidget {
  //<editor-fold desc="属性">

  ///解锁类型（实心、空心）
  final LockPatternType type;

  ///与父布局的间距
  final double padding;

  ///圆之间的间距
  final double roundSpace;

  ///圆之间的间距比例(以圆半径作为基准)，[roundSpace]设置时无效
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
  final Function(List<int>, LockPatternStatus) onCompleted;

  //</editor-fold>

  final _LockPatternState _state = _LockPatternState();

  LockPattern(
      {this.type = LockPatternType.Solid,
      this.padding = 10,
      this.roundSpace,
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

  ///当前手势状态
  LockPatternStatus _status = LockPatternStatus.Default;

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

  ///可删？
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(1);
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

//  ///可删？
//  @override
//  void didUpdateWidget(StatefulWidget oldWidget) {
//    super.didUpdateWidget(oldWidget);
//    print(000);
//    WidgetsBinding.instance.addPostFrameCallback(_init_custom);
//  }

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
        painter: LockPatternPainter(
            widget.type,
            _status,
            _rounds,
            _selected,
            _lastTouchPoint,
            _radius,
            _solidRadius,
            widget.lineWidth,
            widget.defaultColor));
    var enableTouch = _status == LockPatternStatus.Default;

    return GestureDetector(
        child: custom,
        onPanStart: enableTouch ? _onPanStart : null,
        onPanEnd: enableTouch ? _onPanEnd : null,
        onPanUpdate: enableTouch ? _onPanUpdate : null);
  }

  void updateStatus() {
    if (_selected.length != 0) {
      print(1);
      _timer = Timer(Duration(milliseconds: widget.delayTime), () {
//      print(2);

        print(4);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(" "),
                  content: Text("是否发送"),
                  contentTextStyle:
                      TextStyle(color: Colors.green, fontSize: 20.0),
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
                          clear();
                        },
                        child: Text('确认')),
                    // 点击减少显示的值
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

  void sendpath() {
    print(_selected);
    print(_selected.length);

    for (int i = 1; i < _selected.length; i++) {
      var k = (_rounds[_selected[i - 1]].y - _rounds[_selected[i]].y) *
          1.0 /
          (_rounds[_selected[i]].x - _rounds[_selected[i - 1]].x);
      k = atan(k) * 180 / pi;
      if (_rounds[_selected[i]].x >= _rounds[_selected[i - 1]].x) {
        if (k < 0) k = 360 + k;
      } else {
        k = 180 + k;
      }
//      print(k);
      Action item = new Action(0, 20, k.toInt(), 0, 0, 0);
      print(item);
    }
  }

  void clear() {
    for (Round round in _rounds) {
      round.status = LockPatternStatus.Default;
    }
    _selected.clear();
    setState(() {});
  }

  _init(_) {
    _box = context.findRenderObject() as RenderBox;
    var size = context.size;
    if (size.width > size.height) {
      throw Exception("LockPattern width must <= height");
    }

    var width = size.width;
    var roundSpace = widget.roundSpace;
    if (roundSpace != null) {
      _radius = (width - widget.padding * 2 - roundSpace * 2) / 3 / 2;
    } else {
      _radius =
          (width - widget.padding * 2) / (3 + widget.roundSpaceRatio * 2) / 2;
      roundSpace = _radius * 2 * widget.roundSpaceRatio;
    }

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
    var roundSpace = widget.roundSpace;
    if (roundSpace != null) {
      _radius = (width - widget.padding * 2 - roundSpace * 2) / 3 / 2;
    } else {
      _radius =
          (width - widget.padding * 2) / (3 + widget.roundSpaceRatio * 2) / 2;
      roundSpace = _radius * 2 * widget.roundSpaceRatio;
    }
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

  //<editor-fold desc="触摸手势调用">
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
      widget.onCompleted(_selected, _status);
    }
  }
//</editor-fold>
}

class LockPatternPainter extends CustomPainter {
  LockPatternType _type;
  LockPatternStatus _status;
  List<Round> _rounds;
  List<int> _selected;
  Offset _lastTouchPoint;
  double _radius;
  double _solidRadius;
  double _lineWidth;
  Color _defaultColor;


  LockPatternPainter(
      this._type,
      this._status,
      this._rounds,
      this._selected,
      this._lastTouchPoint,
      this._radius,
      this._solidRadius,
      this._lineWidth,
      this._defaultColor

      );

  @override
  void paint(Canvas canvas, Size size) {
    if (_radius == null) return;
    var paint = Paint();

    if (_type == LockPatternType.Solid) {
      ///画圆
      _paintRound(canvas, paint);

      ///画线
      _paintLine(canvas, paint);
    } else {
      _paintRoundWithHollow(canvas, paint);
      _paintLineWithHollow(canvas, paint);
    }
  }

  _paintRoundWithHollow(Canvas canvas, Paint paint) {
    paint.strokeWidth = _lineWidth;
    for (Round round in _rounds) {
      switch (round.status) {
        case LockPatternStatus.Default:
          {
            paint.color = _defaultColor;
            paint.style = PaintingStyle.stroke;
            canvas.drawCircle(round.toOffset(), _radius, paint);
            break;
          }
        case LockPatternStatus.Success:
          {
            paint.style = PaintingStyle.fill;
            paint.color = _defaultColor;
            canvas.drawCircle(round.toOffset(), _solidRadius, paint);
            paint.style = PaintingStyle.stroke;
            canvas.drawCircle(round.toOffset(), _radius, paint);
            break;
          }
      }
    }
  }

  _paintLineWithHollow(Canvas canvas, Paint paint) {
    if (_selected.isNotEmpty) {
      paint.color = _defaultColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = _lineWidth;
      var path = Path();

      ///画圆到圆的线
      for (int i = 1; i < _selected.length; i++) {
        var from = _rounds[_selected[i - 1]].toOffset();
        var to = _rounds[_selected[i]].toOffset();
        _addPath(path, from, to, _radius, true);
      }

      ///画最后一个圆到触摸点的线
      var lastSelected = _rounds[_selected.last];
      if (_lastTouchPoint != null &&
          !lastSelected.contains(_lastTouchPoint, _radius)) {
        _addPath(
            path, lastSelected.toOffset(), _lastTouchPoint, _radius, false);
        path.lineTo(_lastTouchPoint.dx, _lastTouchPoint.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  _addPath(Path path, Offset from, Offset to, double radius, bool isLineTo) {
    var distance = sqrt(pow(to.dx - from.dx, 2) + pow(to.dy - from.dy, 2));
    var scale = radius / distance;
    var translateX = (to.dx - from.dx) * scale;
    var translateY = (to.dy - from.dy) * scale;
    var fromPoint = from.translate(translateX, translateY);
    var toPoint = to.translate(-translateX, -translateY);
    path.moveTo(fromPoint.dx, fromPoint.dy);
    if (isLineTo) {
      path.lineTo(toPoint.dx, toPoint.dy);
    }
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

enum LockPatternType { Solid, Hollow }

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
