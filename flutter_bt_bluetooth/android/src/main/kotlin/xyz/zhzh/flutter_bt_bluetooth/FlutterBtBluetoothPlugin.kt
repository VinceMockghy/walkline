package xyz.zhzh.flutter_bt_bluetooth

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.view.View
import android.widget.ImageView
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.PermissionChecker.PERMISSION_GRANTED
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformView
import xyz.zhzh.flutter_bt_bluetooth.BluetoothState.STATE_CONNECTED

/** FlutterBtBluetoothPlugin */
class FlutterBtBluetoothPlugin(r: Registrar, id: Int) : PlatformView, MethodCallHandler {

    private val activity: Activity = r.activity()
    private val methodChannel: MethodChannel = MethodChannel(r.messenger(), "${NAMESPACE}/${id}")
    private var eventChannel: EventChannel = EventChannel(r.messenger(), "${NAMESPACE}/${id}/output")
    private var stateChannel: EventChannel = EventChannel(r.messenger(), "${NAMESPACE}/${id}/state")

    private val mBluetoothUtil: BluetoothUtil = BluetoothUtil(r.context())
    private val imageView: ImageView = ImageView(r.context())

    // Pending result for getBondedDevices, in the case where permissions are needed
    private var pendingResult: Result? = null

    init {
        r.addRequestPermissionsResultListener(LocationRequestPermissionsListener())

        if (!mBluetoothUtil.isServiceAvailable) {
            mBluetoothUtil.setupService()
            mBluetoothUtil.startService(BluetoothState.DEVICE_ANDROID)
        }

        this.methodChannel.setMethodCallHandler(this)
        this.eventChannel.setStreamHandler(this.bluetoothOutputStreamHandler())
        this.stateChannel.setStreamHandler(this.bluetoothConnectionStreamHandler())
    }

    companion object {
        private const val NAMESPACE = "plugins.zhzh.xyz/flutter_bt_bluetooth"
        private const val REQUEST_COARSE_LOCATION_PERMISSIONS = 1452

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = BtVideoViewFactory(registrar)
            registrar.platformViewRegistry().registerViewFactory("${NAMESPACE}/blueview", instance)
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "getBondedDevices" -> {
                if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_COARSE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
                    pendingResult = result
                    ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION), REQUEST_COARSE_LOCATION_PERMISSIONS)
                } else getBondedDevices(result)
            }
            "connectBondedDevices" -> {
                val deviceId: String = call.arguments as String
                if (mBluetoothUtil.serviceState == STATE_CONNECTED)
                    result.error(
                            "A device is connected",
                            "Please disconnect devices",
                            null)
                else {
                    mBluetoothUtil.connect(deviceId)
                    if (!mBluetoothUtil.isDataReceivedListenerEnabled) setOnDataReceivedListener(null)
                    if (!mBluetoothUtil.isBluetoothConnectionListenerEnabled) setBluetoothConnectionListener(null)
                    result.success(null)
                }
            }
            "disconnectBondedDevices" -> {
                mBluetoothUtil.stopService()
                mBluetoothUtil.setOnDataReceivedListener(null)
                result.success(null)
            }
            "sendMsg" -> {
                if (mBluetoothUtil.isServiceAvailable) {
                    val input: String = call.arguments as String
                    mBluetoothUtil.send(input.toByteArray(), "text")
                    result.success(null)
                } else result.error("no_connected_device", "can not send msg", null)
            }
            "isBluetoothEnabled" -> {
                result.success(mBluetoothUtil.isBluetoothEnabled)
            }
            "serviceState" -> {
                result.success(mBluetoothUtil.serviceState)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private inner class LocationRequestPermissionsListener : PluginRegistry.RequestPermissionsResultListener {
        override fun onRequestPermissionsResult(id: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
            if (id == REQUEST_COARSE_LOCATION_PERMISSIONS) {
                if (grantResults[0] == PERMISSION_GRANTED) {
                    getBondedDevices(pendingResult!!)
                } else {
                    pendingResult!!.error(
                            "no_permissions", "flutter_blue plugin requires location permissions for scanning", null)
                    pendingResult = null
                    Toast.makeText(activity, "请授权定位权限", Toast.LENGTH_LONG).show()
                }
                return true
            }
            return false
        }
    }

    private fun getBondedDevices(result: Result) {
        try {
            result.success(mBluetoothUtil.pairedDevices)
        } catch (e: Exception) {
            result.error("getBondedDevicesFair", e.message, e)
        }
    }

    private fun setOnDataReceivedListener(sink: EventSink?) {
        mBluetoothUtil.setOnDataReceivedListener(object : BluetoothUtil.OnDataReceivedListener {
            override fun onDataReceived(data: ByteArray?, message: String?) {
                if (data != null) {
//                    Log.e("Plugin", "$data")
                    when (message) {
                        "text" -> {
                        }
                        "photo" -> {
                            imageView.setImageBitmap(BitmapFactory.decodeByteArray(data, 0, data.size))
                        }
                        "video" -> {
                            imageView.setImageBitmap(BitmapFactory.decodeByteArray(data, 0, data.size))
                        }
                        else -> {
                        }
                    }
                    sink?.success(data)
                }
            }
        })
    }

    private fun setBluetoothConnectionListener(sink: EventSink?) {
        mBluetoothUtil.setBluetoothConnectionListener(object : BluetoothUtil.BluetoothConnectionListener {
            override fun onDeviceConnected(name: String?, address: String?) {
                Toast.makeText(activity, "蓝牙已连接", Toast.LENGTH_SHORT).show()
                sink?.success(mBluetoothUtil.serviceState)
            }

            override fun onDeviceDisconnected() {
                Toast.makeText(activity, "蓝牙已断开", Toast.LENGTH_SHORT).show()
                sink?.success(mBluetoothUtil.serviceState)
            }

            override fun onDeviceConnectionFailed() {
                Toast.makeText(activity, "蓝牙连接失败, 请检查蓝牙设置", Toast.LENGTH_SHORT).show()
                sink?.success(mBluetoothUtil.serviceState)
            }
        })
    }

    private fun bluetoothConnectionStreamHandler(): EventChannel.StreamHandler {
        return object : EventChannel.StreamHandler {
            private var eventSink: EventSink? = null

            override fun onListen(arguments: Any?, events: EventSink) {
                eventSink = events
                setBluetoothConnectionListener(events)
            }

            override fun onCancel(arguments: Any?) {
                mBluetoothUtil.setBluetoothConnectionListener(null)
                eventSink = null
            }

        }
    }

    private fun bluetoothOutputStreamHandler(): EventChannel.StreamHandler {
        return object : EventChannel.StreamHandler {
            private var eventSink: EventSink? = null

            override fun onListen(arguments: Any?, events: EventSink) {
                eventSink = events
                setOnDataReceivedListener(events)
            }

            override fun onCancel(arguments: Any?) {
                mBluetoothUtil.setOnDataReceivedListener(null)
                eventSink = null
            }
        }
    }

    override fun getView(): View {
        return imageView
    }

    override fun dispose() {
    }
}
