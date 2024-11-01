package com.example.flutter_fpt_socket

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.neovisionaries.ws.client.WebSocketException
import com.neovisionaries.ws.client.WebSocketFrame
import io.flutter.plugin.common.MethodCall
import io.github.sac.BasicListener
import io.github.sac.Socket

class ChatBotMethodHandler {
    private lateinit var socket: Socket
    fun handleOnConnectChatbot(chatBotUtility: ChatBotUtility, call: MethodCall) {
        chatBotUtility.isConnectedChanel = true
        socket = Socket("https://ftel-livechat.fpt.ai:443/ws/")

        socket.setListener(object : BasicListener {
            override fun onConnected(socket: Socket, headers: Map<String?, List<String?>?>?) {
                val authData = call.arguments as Map<*, *>;
                println("authData ${authData["senderId"]}")
                chatBotUtility.chatBotAuthData = ChatBotAuthData(
                    botCode = authData["botCode"] as String? ?: "",
                    senderId = authData["senderId"] as String? ?: "",
                    senderName = authData["senderName"] as String? ?: "",
                    token = authData["token"] as String? ?: "",
                    reconnect = authData["reconnect"] as Boolean? ?: false,
                )
                chatBotUtility.authorizeToServer(socket)
                Log.i("Success ", "Connected to endpoint")
            }

            override fun onDisconnected(
                socket: Socket?,
                serverCloseFrame: WebSocketFrame?,
                clientCloseFrame: WebSocketFrame?,
                closedByServer: Boolean
            ) {
                Log.i("Success ", "Disconnected from end-point")
                if (chatBotUtility.isConnectedChanel) {
                    Handler(Looper.getMainLooper()).post {
                        chatBotUtility.reconnectChatbotChannel.invokeMethod("reconnectChatbot", "")
                    }
                }
            }

            override fun onConnectError(socket: Socket?, exception: WebSocketException) {
                Log.i("Success ", "Got connect error $exception")
            }

            override fun onSetAuthToken(token: String?, socket: Socket) {
                println("newSocketToken: $token")
                socket.setAuthToken(token)
            }

            override fun onAuthentication(socket: Socket?, status: Boolean) {
                if (status) {
                    Log.i("Success ", "socket is authenticated")
                } else {
                    Log.i("Success ", "Authentication is required (optional)")
                }
            }
        })
        socket.connectAsync()
    }

    fun handleOnSendMessageChatbot(chatBotUtility: ChatBotUtility, call: MethodCall) {
        val buttonString = (call.arguments as Map<*, *>)["button"] as String
        chatBotUtility.sendMessage(socket, chatBotUtility.stringToButton(buttonString))
    }

    fun handleOnDisConnectChatbot(chatBotUtility: ChatBotUtility) {
        chatBotUtility.isConnectedChanel = false;
        socket.disconnect()
    }
}
