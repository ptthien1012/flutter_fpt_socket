import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_fpt_socket_method_channel.dart';

abstract class FlutterFptSocketPlatform extends PlatformInterface {
  /// Constructs a FlutterFptSocketPlatform.
  FlutterFptSocketPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFptSocketPlatform _instance = MethodChannelFlutterFptSocket();

  /// The default instance of [FlutterFptSocketPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFptSocket].
  static FlutterFptSocketPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFptSocketPlatform] when
  /// they register themselves.
  static set instance(FlutterFptSocketPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<dynamic> connectChatbot(String token, String botCode, String senderId,
      String senderName, String chatBotAttributes, bool reconnect) {
    throw UnimplementedError('connectChatbot has not been implemented.');
  }

  void sendMessageChatbot(String jsonString) {
    throw UnimplementedError('sendMessageChatbot has not been implemented.');
  }

  void disConnectChatbot() {
    throw UnimplementedError('disConnectChatbot has not been implemented.');
  }

  MethodChannel getReceivedMessageChannel() {
    throw UnimplementedError('sendMessageChatbot has not been implemented.');
  }
}
