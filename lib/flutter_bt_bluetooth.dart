import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const NAMESPACE = 'plugins.zhzh.xyz/flutter_bt_bluetooth';

typedef void BlueViewCreatedCallback(BlueViewController controller);

class BlueView extends StatefulWidget {
  const BlueView({@required this.onBlueViewCreated})
      : assert(onBlueViewCreated != null);

  final BlueViewCreatedCallback onBlueViewCreated;

  @override
  State<StatefulWidget> createState() => _BlueViewState();
}

class _BlueViewState extends State<BlueView> {
  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: '$NAMESPACE/blueview',
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      default:
        throw UnsupportedError(
            "Trying to use the default webview implementation for $defaultTargetPlatform but there isn't a default one");
    }
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onBlueViewCreated == null) return;

    widget.onBlueViewCreated(BlueViewController._(id));
  }
}

class BlueViewController {
  final MethodChannel _channel;
  final EventChannel _blueOutputStreamChannel;
  final EventChannel _blueStateStreamChannel;

  BlueViewController._(int id)
      : _channel = MethodChannel("$NAMESPACE/$id"),
        _blueOutputStreamChannel = EventChannel("$NAMESPACE/$id/output"),
        _blueStateStreamChannel = EventChannel("$NAMESPACE/$id/state");

  Future<String> get platformVersion async =>
      await _channel.invokeMethod("getPlatformVersion");

  Future<bool> get isBluetoothEnabled async =>
      await _channel.invokeMethod("isBluetoothEnabled");

  Future<Map<dynamic, dynamic>> get bondedDevices async =>
      await _channel.invokeMethod("getBondedDevices");

  Future<void> connectBondedDevice(String address) async =>
      await _channel.invokeMethod("connectBondedDevices", address);

  Future<int> serviceState() async =>
      await _channel.invokeMethod("serviceState");

  Future<void> sendMsg(String msg) async =>
      await _channel.invokeMethod("sendMsg", msg);

  Future<void> disconnectBondedDevice() async =>
      await _channel.invokeMethod("disconnectBondedDevices");

  Stream<BluetoothOutput> get outputStream async* {
    yield* _blueOutputStreamChannel
        .receiveBroadcastStream()
        .map((buffer) => BluetoothOutput.fromProto(buffer));
  }

  Stream<int> get stateStream async* {
    yield* _blueStateStreamChannel
        .receiveBroadcastStream()
        .map((buffer) => buffer.toInt());
  }
}

class BluetoothOutput {
  final Uint8List data;

  BluetoothOutput({this.data});

  BluetoothOutput.fromProto(Uint8List p) : data = p;
}

// Constants that indicate the current connection state
const STATE_NONE = 0; // we're doing nothing
const STATE_LISTEN = 1; // now listening for incoming connections
const STATE_CONNECTING = 2; // now initiating an outgoing connection
const STATE_CONNECTED = 3; // now connected to a remote device
const STATE_NULL = -1; // now service is null
