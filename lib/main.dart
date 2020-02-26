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
      home: GestureCreat(),
    );
  }
}

class ListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListWidgetState();
  }
}

class ListWidgetState extends State<ListWidget> {
  final _textlist = <String>["画图控制", "解锁器控制"];

  Widget _modelist() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20.0),
      children: <Widget>[
        ListTile(
          title: Text(
            _textlist[0],
            style: TextStyle(fontSize: 18.0),
          ),
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Mycanvas()));
          },
        ),
        ListTile(
          title: Text(
            _textlist[1],
            style: TextStyle(fontSize: 18.0),
          ),
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> GestureCreat()));
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("手势控制"),
      ),
      body: _modelist(),
    );
  }
}
