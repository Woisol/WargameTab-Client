package com.woisol.wargametab

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var interconnectChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        interconnectChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )
        interconnectChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> result.success(
                    unavailableState("小米 Vela Android 互联 SDK 尚未接入，当前仅完成 Flutter/native 边界。"),
                )

                "stop" -> result.success(
                    mapOf(
                        "available" to false,
                        "diagnosing" to false,
                        "diagnosticMessage" to "Android 互联通道已停用",
                        "lastError" to null,
                    ),
                )

                "send" -> {
                    val raw = call.arguments as? String
                    if (raw.isNullOrBlank()) {
                        result.error("invalid_ack", "ACK payload must be a non-empty string", null)
                    } else {
                        result.error(
                            "interconnect_unavailable",
                            "小米 Vela Android 互联 SDK 尚未接入，暂不能发送 ACK。",
                            null,
                        )
                    }
                }

                "diagnosis" -> result.success(
                    unavailableState("等待接入官方 Android 设备通信 SDK。"),
                )

                else -> result.notImplemented()
            }
        }
    }

    @Suppress("unused")
    private fun emitWatchMessage(raw: String) {
        if (::interconnectChannel.isInitialized) {
            interconnectChannel.invokeMethod("onMessage", raw)
        }
    }

    private fun unavailableState(message: String): Map<String, Any?> = mapOf(
        "available" to false,
        "diagnosing" to false,
        "diagnosticMessage" to message,
        "lastError" to "interconnect_sdk_missing",
    )

    private companion object {
        const val CHANNEL = "com.woisol.wargametab/interconnect"
    }
}
