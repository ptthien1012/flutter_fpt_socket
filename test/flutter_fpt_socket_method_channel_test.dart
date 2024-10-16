import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fpt_socket/flutter_fpt_socket_method_channel.dart';

void main() {
  MethodChannelFlutterFptSocket platform = MethodChannelFlutterFptSocket();
  const MethodChannel channel = MethodChannel('flutter_fpt_socket');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
