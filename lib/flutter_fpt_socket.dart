import 'package:flutter/services.dart';

import 'flutter_fpt_socket_platform_interface.dart';

class FlutterFptSocket {
  Future<String?> getPlatformVersion() {
    return FlutterFptSocketPlatform.instance.getPlatformVersion();
  }

  Future<dynamic> connectChatbot(String token, String botCode, String senderId, String senderName, String chatBotAttributes, bool reconnect) {
    return FlutterFptSocketPlatform.instance.connectChatbot(token, botCode, senderId, senderName, chatBotAttributes, reconnect);
  }

   void disConnectChatbot() {
   FlutterFptSocketPlatform.instance.disConnectChatbot();
 }

  void sendMessageChatbot(String jsonString) {
    FlutterFptSocketPlatform.instance.sendMessageChatbot(jsonString);
  }

  MethodChannel getReceivedMessageChannel() {
    return FlutterFptSocketPlatform.instance.getReceivedMessageChannel();
  }
}
