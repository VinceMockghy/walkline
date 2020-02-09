import 'package:flutter/material.dart';

import 'package:walkline/paint/MyCanvas.dart';
import 'package:walkline/unlock/gesture_create_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: Mycanvas(),
      home: GestureCreat(),
    );
  }
}




