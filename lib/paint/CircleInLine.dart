import 'package:flutter/material.dart';

class Drawable {
  Color color; //颜色
  Offset pos; //位置
  Drawable(this.color, this.pos);
}

class CircleInLine extends Drawable {
  double radius;

  CircleInLine(Color color, Offset pos, {this.radius = 1}) : super(color, pos);
}
