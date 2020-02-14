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
