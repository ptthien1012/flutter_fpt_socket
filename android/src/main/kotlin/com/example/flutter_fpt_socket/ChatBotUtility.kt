package com.example.flutter_fpt_socket

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.github.sac.Ack
import io.github.sac.Socket
import org.json.JSONException
import org.json.JSONObject
import java.io.UnsupportedEncodingException
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class ChatBotUtility {
    lateinit var chatBotAuthData: ChatBotAuthData
    lateinit var reconnectChatbotChannel: MethodChannel
    lateinit var nativeToFlutterChatbotChannel: MethodChannel
    var isConnectedChanel: Boolean = false
    private val liveChat = "/livechat"
    private fun md5(input: String): String {
        try {
            val md = MessageDigest.getInstance("MD5")
            val array = md.digest(input.toByteArray())
            val sb = StringBuffer()
            for (i in array.indices) {
                sb.append(Integer.toHexString(array[i].toInt() and 0xFF or 0x100).substring(1, 3))
            }
            return sb.toString()
        } catch (_: NoSuchAlgorithmException) {
        } catch (_: UnsupportedEncodingException) {
        }
        return ""
    }
    private fun getFptBotChatChannelName(senderId: String, botCode: String): String {
        println("channelId: ${md5("$senderId.$botCode")}@$botCode$liveChat")
        return "${md5("$senderId.$botCode")}@$botCode$liveChat"
    }

    fun stringToButton(buttonString: String): Button {
        try {
            val buttonCharset = charset("UTF-8")
            val buttonJsonString = String(buttonString.toByteArray(buttonCharset), buttonCharset)
            val buttonJson = JSONObject(buttonJsonString)
            println("buttonString: " + buttonString + "buttonJson" + buttonJson)
            return Button(
                title = buttonJson.getString("title"),
                payload = buttonJson.getString("payload"),
                webview = buttonJson.getString("webview"),
                url = buttonJson.getString("url"),
            )
        } catch(ex: JSONException) {
            println("exMessage: "+ ex.message + ", exLocalizeMessage: " + ex.localizedMessage)
        }
        return Button(title = "", payload = "", webview = "", url = "")
    }

    fun authorizeToServer(socket: Socket?) {
        val data = JSONObject()
        data.put("reconnect", chatBotAuthData.reconnect)
        data.put("bot_code", chatBotAuthData.botCode)
        data.put("sender_id", chatBotAuthData.senderId)
        data.put("sender_name", chatBotAuthData.senderName)
        data.put("token", chatBotAuthData.token)

        Handler(Looper.getMainLooper()).post {
            socket?.emit(ChatBotConstant.authenticateEvent, data, object: Ack {
                override fun call(name: String?, error: Any?, data: Any?) {
                    println("data get after emit authorize: $data")
                    subscribeBotChannel(socket)
                }

            })
        }
    }

    private fun subscribeBotChannel(socket: Socket?) {
        val channel = socket?.getChannelByName(getFptBotChatChannelName(
            chatBotAuthData.senderId, chatBotAuthData.botCode)
        ) ?: socket?.createChannel(getFptBotChatChannelName(
            chatBotAuthData.senderId, chatBotAuthData.botCode)
        )
        channel?.subscribe(object: Ack {
            override fun call(name: String, error: Any?, data: Any?) {
                Log.i("Success", "subscribed data ${data.toString()}")
                if (error == null) {
                    Log.i("Success", "subscribed to channel $name, send start message now")
                    if (!chatBotAuthData.reconnect) {
                        sendMessage(socket, null)
                    }
                }
            }
        })
        channel?.onMessage { name, data ->
            println("name on message channel: $name, data on message channel: $data")
            Handler(Looper.getMainLooper()).post {
                nativeToFlutterChatbotChannel.invokeMethod(
                    "nativeToFlutterChatbot",
                    data.toString()
                )
            }
        }
    }

    fun sendMessage(socket: Socket?, button: Button?) {
//        val messageObject = JSONObject()
//        messageObject.put("channel", "livechat")
//        messageObject.put("sender_id", chatBotAuthData.senderId)
//        messageObject.put("sender_name", chatBotAuthData.senderName)
//        messageObject.put("bot_code", chatBotAuthData.botCode)
//        messageObject.put("message", JSONObject(message.toString()))
//        println("messageObject: $messageObject")
        println("origin button: $button")

        val messageObject = JSONObject()
        messageObject.put("channel", "livechat")
        messageObject.put("sender_id", chatBotAuthData.senderId)
        messageObject.put("sender_name", chatBotAuthData.senderName)
        messageObject.put("bot_code", chatBotAuthData.botCode)

        val message = JSONObject()
        if (button != null) {
            if (button.payload == "null") {
                message.put("type", "text")
                message.put("content", button.title)
            } else {
                message.put("type", "payload")
                message.put("content", (button.payload ?: "") + "#" + (button.title ?: ""))
            }
        }
        else {
            message.put("type", "payload")
            message.put("content", "get_started")
        }
        println("message object to be snt: $messageObject")
        messageObject.put("message", JSONObject(message.toString()))
        Handler(Looper.getMainLooper()).post {
            socket?.emit(ChatBotConstant.sendMessageEvent, messageObject)
        }
    }
}
