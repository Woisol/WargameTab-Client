package com.woisol.wargametab

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.Charset
import com.xiaomi.xms.wearable.Wearable
import com.xiaomi.xms.wearable.auth.AuthApi
import com.xiaomi.xms.wearable.auth.Permission
import com.xiaomi.xms.wearable.message.MessageApi
import com.xiaomi.xms.wearable.message.OnMessageReceivedListener
import com.xiaomi.xms.wearable.node.Node
import com.xiaomi.xms.wearable.node.NodeApi
import com.xiaomi.xms.wearable.service.ServiceApi
import com.xiaomi.xms.wearable.tasks.Task

class MainActivity : FlutterActivity() {
    private lateinit var interconnectChannel: MethodChannel
    private lateinit var authApi: AuthApi
    private lateinit var messageApi: MessageApi
    private lateinit var nodeApi: NodeApi
    private lateinit var serviceApi: ServiceApi
    private var messageListener: OnMessageReceivedListener? = null
    private var connectedNodeId: String? = null
    private var channelStarted = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        authApi = Wearable.getAuthApi(applicationContext)
        messageApi = Wearable.getMessageApi(applicationContext)
        nodeApi = Wearable.getNodeApi(applicationContext)
        serviceApi = Wearable.getServiceApi(applicationContext)
        interconnectChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )
        interconnectChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> startInterconnect(result)

                "stop" -> stopInterconnect(result)

                "send" -> {
                    val raw = call.arguments as? String
                    if (raw.isNullOrBlank()) {
                        result.error("invalid_ack", "ACK payload must be a non-empty string", null)
                    } else {
                        sendInterconnectMessage(raw, result)
                    }
                }

                "diagnosis" -> diagnoseInterconnect(result)

                else -> result.notImplemented()
            }
        }
    }

    private fun startInterconnect(result: MethodChannel.Result) {
        if (channelStarted) {
            result.success(readyState("Android 互联通道已启用，等待手表发送数据。"))
            return
        }

        nodeApi.getConnectedNodes().complete(
            onSuccess = { nodes ->
                val node = nodes.firstOrNull()
                if (node == null || node.id.isBlank()) {
                    result.success(
                        unavailableState(
                            message = "未发现已连接的小米穿戴设备。",
                            error = "interconnect_node_missing",
                        ),
                    )
                    return@complete
                }

                requestDeviceManagerPermission(node, result)
            },
            onFailure = { error ->
                result.error(
                    "interconnect_node_query_failed",
                    error.localizedMessage ?: error.javaClass.name,
                    null,
                )
            },
        )
    }

    private fun requestDeviceManagerPermission(node: Node, result: MethodChannel.Result) {
        authApi.requestPermission(node.id, Permission.DEVICE_MANAGER).complete(
            onSuccess = {
                registerMessageListener(node, result)
            },
            onFailure = { error ->
                result.error(
                    "interconnect_permission_failed",
                    error.localizedMessage ?: error.javaClass.name,
                    null,
                )
            },
        )
    }

    private fun registerMessageListener(node: Node, result: MethodChannel.Result) {
        val listener = OnMessageReceivedListener { _, payload ->
            val raw = String(payload, UTF8)
            runOnUiThread {
                interconnectChannel.invokeMethod("onMessage", raw)
            }
        }
        messageListener = listener
        connectedNodeId = node.id
        messageApi.addListener(node.id, listener).complete(
            onSuccess = {
                channelStarted = true
                val nodeLabel = node.name?.ifBlank { node.id } ?: node.id
                result.success(
                    readyState("Android 互联通道已启用：$nodeLabel"),
                )
            },
            onFailure = { error ->
                messageListener = null
                connectedNodeId = null
                channelStarted = false
                result.error(
                    "interconnect_start_failed",
                    error.localizedMessage ?: error.javaClass.name,
                    null,
                )
            },
        )
    }

    private fun stopInterconnect(result: MethodChannel.Result) {
        if (!channelStarted && messageListener == null) {
            result.success(stoppedState("Android 互联通道已停用"))
            return
        }

        val nodeId = connectedNodeId
        if (nodeId == null) {
            messageListener = null
            channelStarted = false
            result.success(stoppedState("Android 互联通道已停用"))
            return
        }

        messageApi.removeListener(nodeId).complete(
            onSuccess = {
                messageListener = null
                connectedNodeId = null
                channelStarted = false
                result.success(stoppedState("Android 互联通道已停用"))
            },
            onFailure = { error ->
                messageListener = null
                connectedNodeId = null
                channelStarted = false
                result.error(
                    "interconnect_stop_failed",
                    error.localizedMessage ?: error.javaClass.name,
                    null,
                )
            },
        )
    }

    private fun sendInterconnectMessage(raw: String, result: MethodChannel.Result) {
        val nodeId = connectedNodeId
        if (nodeId == null) {
            result.error("interconnect_not_started", "Android 互联通道尚未启用。", null)
            return
        }

        messageApi.sendMessage(nodeId, raw.toByteArray(UTF8)).complete(
            onSuccess = {
                result.success(null)
            },
            onFailure = { error ->
                result.error(
                    "interconnect_send_failed",
                    error.localizedMessage ?: error.javaClass.name,
                    null,
                )
            },
        )
    }

    private fun diagnoseInterconnect(result: MethodChannel.Result) {
        serviceApi.getServiceApiLevel().complete(
            onSuccess = { apiLevel ->
                result.success(
                    mapOf(
                        "available" to channelStarted,
                        "diagnosing" to false,
                        "diagnosticMessage" to "小米互联服务可用，API Level $apiLevel",
                        "lastError" to null,
                    ),
                )
            },
            onFailure = { error ->
                result.success(
                    mapOf(
                        "available" to false,
                        "diagnosing" to false,
                        "diagnosticMessage" to (error.localizedMessage ?: error.javaClass.name),
                        "lastError" to "interconnect_diagnosis_failed",
                    ),
                )
            },
        )
    }

    private fun <T> Task<T>.complete(
        onSuccess: (T) -> Unit,
        onFailure: (Throwable) -> Unit,
    ) {
        addOnSuccessListener { value ->
            runOnUiThread {
                onSuccess(value)
            }
        }
        addOnFailureListener { error ->
            runOnUiThread {
                onFailure(error)
            }
        }
    }

    override fun onDestroy() {
        if (::messageApi.isInitialized && messageListener != null) {
            connectedNodeId?.let { nodeId ->
                messageApi.removeListener(nodeId)
            }
        }
        messageListener = null
        connectedNodeId = null
        channelStarted = false
        super.onDestroy()
    }

    private fun readyState(message: String): Map<String, Any?> = mapOf(
        "available" to true,
        "diagnosing" to false,
        "diagnosticMessage" to message,
        "lastError" to null,
    )

    private fun stoppedState(message: String): Map<String, Any?> = mapOf(
        "available" to false,
        "diagnosing" to false,
        "diagnosticMessage" to message,
        "lastError" to null,
    )

    private fun unavailableState(message: String, error: String): Map<String, Any?> = mapOf(
        "available" to false,
        "diagnosing" to false,
        "diagnosticMessage" to message,
        "lastError" to error,
    )

    private companion object {
        const val CHANNEL = "com.woisol.wargametab/interconnect"
        val UTF8: Charset = Charsets.UTF_8
    }
}
