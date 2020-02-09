import 'package:flutter/material.dart';
import 'package:walkline/unlock/lock_pattern.dart';

class GestureCreat extends StatefulWidget {
  @override
  GestureCreatState createState() {
    // TODO: implement createState
    return GestureCreatState();
  }
}

class GestureCreatState extends State<GestureCreat> {
  var _status = GestureCreateStatus.Verify;

  LockPattern _lockPattern;

  @override
  Widget build(BuildContext context) {
    if (_lockPattern == null) {
      _lockPattern = LockPattern(
        padding: 20,
        onCompleted: _gestureComplete,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("控制"),
      ),
      body: (
          Center(
            child: SizedBox(
              width: 500,
              height: 500,
              child: _lockPattern,
            ),
          )
      ),
    );
  }


  _gestureComplete(List<int> selected, LockPatternStatus status) {
    setState(() {
      _lockPattern.updateStatus();
//      print(_status);
//      _lockPattern.updateStatus(LockPatternStatus.Success);
    });
  }
}

enum GestureCreateStatus{
  Create,
  Create_Failed,
  Verify,
  Verify_Failed,
  Verify_Failed_Count_Overflow
}
