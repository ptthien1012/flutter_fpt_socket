import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fpt_socket/flutter_fpt_socket.dart';
import 'package:flutter_fpt_socket/flutter_fpt_socket_platform_interface.dart';
import 'package:flutter_fpt_socket/flutter_fpt_socket_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterFptSocketPlatform
    with MockPlatformInterfaceMixin
    implements FlutterFptSocketPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  @override
  Future<dynamic> connectChatbot(String token, String botCode, String senderId, String senderName, String chatBotAttributes, bool reconnect) {
    throw UnimplementedError('connectChatbot has not been implemented.');
  }

  @override
  void sendMessageChatbot(String jsonString) {
    throw UnimplementedError('sendMessageChatbot has not been implemented.');
  }
  @override
  MethodChannel getReceivedMessageChannel() {
       throw UnimplementedError('sendMessageChatbot has not been implemented.');
 }
 
  @override
  void disConnectChatbot() {
       throw UnimplementedError('disConnectChatbot has not been implemented.');
  }
}

void main() {
  final FlutterFptSocketPlatform initialPlatform =
      FlutterFptSocketPlatform.instance;

  test('$MethodChannelFlutterFptSocket is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterFptSocket>());
  });

  test('getPlatformVersion', () async {
    FlutterFptSocket flutterFptSocketPlugin = FlutterFptSocket();
    MockFlutterFptSocketPlatform fakePlatform = MockFlutterFptSocketPlatform();
    FlutterFptSocketPlatform.instance = fakePlatform;

    expect(await flutterFptSocketPlugin.getPlatformVersion(), '42');
  });
}
