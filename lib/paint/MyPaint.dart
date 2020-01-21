import 'package:flutter/material.dart';
import 'package:walkline/paint/CircleInLine.dart';

class MyPaint extends CustomPainter {

  Paint _paint;
  final List<List<CircleInLine>> lines;


  MyPaint({
    @required this.lines,
  }) {
    _paint = Paint()
      ..color=Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    for (int i = 0; i < lines.length; i++) {
      drawLine(canvas, lines[i]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  void drawLine(Canvas canvas, List<CircleInLine> positions) {
    for (int i = 0; i < positions.length - 1; i++) {
      if (positions[i] != null && positions[i + 1] != null)
        canvas.drawLine(positions[i].pos, positions[i + 1].pos,
            _paint..strokeWidth = positions[i].radius);
    }
  }
}

