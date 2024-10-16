import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_fpt_socket_platform_interface.dart';

/// An implementation of [FlutterFptSocketPlatform] that uses method channels.
class MethodChannelFlutterFptSocket extends FlutterFptSocketPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_fpt_socket');
  final _platformConnectChatbot = const MethodChannel('connectChatbotChannel');
  final _platformDisConnectChatbot =
      const MethodChannel('disConnectChatbotChannel');
  final _platformSendMessageChatbot =
      const MethodChannel('sendMessageChatbotChannel');
  final _eventRecievedMessageChatbot =
      const MethodChannel('nativeToFlutterChatbotChannel');
  final _eventReConnectChatbot = const MethodChannel('reconnectChatbotChannel');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<dynamic> connectChatbot(String token, String botCode, String senderId,
      String senderName, String chatBotAttributes, bool reconnect) async {
    _platformConnectChatbot.invokeMethod('connectChatbot', {
      'reconnect': reconnect,
      'token': token,
      'botCode': botCode,
      'senderId': senderId,
      'senderName': senderName,
      'chatBotAttributes': chatBotAttributes
    });

    // _eventRecievedMessageChatbot.setMethodCallHandler((call) async {
    // final dataNew = call.arguments;
    // print(dataNew);
    // });
    _eventReConnectChatbot.setMethodCallHandler((call) async {
      print(call.method);
      _platformConnectChatbot.invokeMethod('connectChatbot', {
        'reconnect': true,
        'token': token,
        'botCode': botCode,
        'senderId': senderId,
        'senderName': senderName,
        'chatBotAttributes': chatBotAttributes
      });
    });
  }

  @override
  void disConnectChatbot() {
    _platformDisConnectChatbot.invokeMethod('disConnectChatbot');
  }

  @override
  MethodChannel getReceivedMessageChannel() {
    return _eventRecievedMessageChatbot;
  }

  @override
  void sendMessageChatbot(String jsonString) async {
    String isJson = jsonString
        .replaceAllMapped(RegExp(r'(?<=\{| )\w(.*?)(?=\: |, |})'), (match) {
      return '"${match.group(0)!}"';
    });
    _platformSendMessageChatbot.invokeMethod('sendMessageChatbot', {
      'button': isJson,
    });
  }
}
