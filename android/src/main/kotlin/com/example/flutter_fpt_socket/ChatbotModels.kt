package com.example.flutter_fpt_socket

class ChatBotConstant {
    companion object{
        const val authenticateEvent = "sender_request_authenticate"
        const val sendMessageEvent = "user_send_message"
        const val tokenKey = "clientToken"
        const val tokenKeyInServerResponse = "sender_token"
        const val socketTokenKey = "socketToken"
    }
}

class ChatBotAuthData (
    var botCode: String, var senderId: String, var senderName: String, var token: String, var reconnect: Boolean
) {}

class Button (var title: String, var payload: String?, var webview: String?, var url: String?) {}