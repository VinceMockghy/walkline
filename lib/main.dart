//import 'package:flutter/material.dart';
//
//import 'package:walkline/paint/MyCanvas.dart';
//import 'package:walkline/unlock/gesture_create_state.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Flutter Demo',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: ListWidget(),
//    );
//  }
//}
//
//class ListWidget extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return ListWidgetState();
//  }
//}
//
//class ListWidgetState extends State<ListWidget> {
//  final _textlist = <String>["画图控制", "解锁器控制"];
//
//  Widget _modelist() {
//    return ListView(
//      shrinkWrap: true,
//      padding: const EdgeInsets.all(20.0),
//      children: <Widget>[
//        ListTile(
//          title: Text(
//            _textlist[0],
//            style: TextStyle(fontSize: 18.0),
//          ),
//          onTap: (){
//            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Mycanvas()));
//          },
//        ),
//        ListTile(
//          title: Text(
//            _textlist[1],
//            style: TextStyle(fontSize: 18.0),
//          ),
//          onTap: (){
//            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> GestureCreat()));
//          },
//        )
//      ],
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("手势控制"),
//      ),
//      body: _modelist(),
//    );
//  }
//}

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bt_bluetooth/flutter_bt_bluetooth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BlueViewController controller;
  double viewHeight = 270;
  bool isConnected = false;
  String msg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Receive Plugin example'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: viewHeight,
              child: BlueView(
                onBlueViewCreated: (c) => setState(() {
                  if (c != null) {
                    controller = c;
                    controller.stateStream.listen((event) =>
                        setState(() => isConnected = event == STATE_CONNECTED));
                  }
                }),
              ),
            ),
            Visibility(
              visible: isConnected,
              child: Column(children: <Widget>[
                SizedBox(height: viewHeight),
                TextField(
                  decoration: new InputDecoration(hintText: 'Type something'),
                  onChanged: (value) => msg = value,
                ),
                SizedBox(height: 5),
                CupertinoButton(
                  color: Colors.blue,
                  padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                  child: Text("发送数据"),
                  onPressed: () => controller.sendMsg(msg),
                ),
                SizedBox(height: 5),
                CupertinoButton(
                  color: Colors.red,
                  padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                  child: Text("断开连接"),
                  onPressed: () => controller.disconnectBondedDevice(),
                )
              ]),
            ),
            controller == null
                ? Text("Please turn on bluetooth")
                : Container(
                child:
                isConnected ? null : DeviceList(controller: controller))
          ],
        ),
      ),
    );
  }
}

class DeviceList extends StatefulWidget {
  const DeviceList({@required this.controller}) : assert(controller != null);
  final BlueViewController controller;

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<dynamic, dynamic>>(
      stream: Stream.periodic(Duration(seconds: 2))
          .asyncMap((_) => widget.controller.bondedDevices),
      initialData: HashMap(),
      builder: (c, snapshot) {
        List<ListTile> list = List();
        if (snapshot.data != null)
          snapshot.data.forEach((key, value) {
            list.add(ListTile(
              title: Text(value),
              subtitle: Text(key),
              trailing: CupertinoButton(
                color: Colors.blue,
                padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Text("连接"),
                onPressed: () => widget.controller.connectBondedDevice(key),
              ),
            ));
          });
        return ListView(shrinkWrap: true, children: list);
      },
    );
  }
}
