import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:flutter/cupertino.dart';

import 'package:walkline/unlock/lock_pattern.dart';
import 'package:flutter_bt_bluetooth/flutter_bt_bluetooth.dart';

class GestureCreat extends StatefulWidget {
  @override
  GestureCreatState createState() {
    // TODO: implement createState
    return GestureCreatState();
  }
}

class GestureCreatState extends State<GestureCreat> {
  LockPattern _lockPattern;
  BlueViewController controller;
  double viewHeight = 270;
  bool isConnected = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.disconnectBondedDevice();
  }

  @override
  Widget build(BuildContext context) {
    if (_lockPattern == null) {
      _lockPattern = LockPattern(
        controller: controller,
        padding: 20,
        onCompleted: _gestureComplete,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("解锁器控制"),
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
                        controller.stateStream.listen((event) => setState(
                            () => isConnected = event == STATE_CONNECTED));
                      }
                    }),
              ),
            ),
            Visibility(
              visible: isConnected,
              child: Column(children: <Widget>[
                SizedBox(height: viewHeight),
                Center(
                    child: SizedBox(
                  width: 300,
                  height: 300,
                  child: _lockPattern,
                ))
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



  _gestureComplete(List<int> selected) {
    setState(() {
      _lockPattern.updateStatus();
    });
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

//enum GestureCreateStatus {
//  Create,
//  Create_Failed,
//  Verify,
//  Verify_Failed,
//  Verify_Failed_Count_Overflow
//}
