import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_fpt_socket/flutter_fpt_socket.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterFptSocketPlugin = FlutterFptSocket();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    const token =
        'WvlfDp7CJHfF-92j-wfzxFztdgB2olYf0dVT-rgXkx3eiN3wnj3qVXqaXefQB33lx5TkLiYUpClNojjnS6r0yPblAvjuuG8HNiXe9fzn2oRwcLR0xOoKj9lxD4yJElI';
    const botcode = '78e2c21383e3b1f682e2b3868ca832d1';
    const senderid = 'user_10163_77343c55-b10e-4b94-8a24-fbbb25bc37c3';
    const sendername = 'Mai VÄn BiÃªn';
    const chatBotAttributes = '"login_user_token":"I2HJ2LShbRXnr3pRJ1hA7y24nBzibJHr6Nh9PLNFKnlhVWfyaOA2Ls0z/1XAU7r9ID7id7pnlsmQVgjS8dK9JyojDVWMwDUg4LAiv6w2QUAF183Jgj4T1j4boaCH7VbXc+qmBk0YZhwe27eEmJHe4odNeOjiH0CUcYwl7lSs/ghGVRWx8xfO1F+5j0amzd9D7uJ39WRfPx/AJsmPJ9RjpW6Y1QLs+EgVbr5DgRxOE2ePozsw2qxEsyYbXYR/tPiYp2BWPW+kyOlrIxRjh5h3TPTpAisaRMG1qosUCuguDxJQR+bwSP5PD9ixqqB+TEE04mjg51riaURy6TpEwuQzjgNrNwUdHxiBFzVlBZGxUhar3xT/FgIt0tEBkRpOeDhwfqwofMMHPd6sG6SBveta5JwlQqVzGn7/yuz/d/j6sH4=","mypt_user_id":"10163","mypt_user_email":"phuongnam.bienmv@fpt.net","empJobTitle":"CB Láº­p trÃ¬nh 1","empCode":"00258077","childDepart":"PDX","workingBranch":"PNC"';
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // final attributes = chatBotAttributes.replaceAll(RegExp(r'[^\w\s]+'),'');
      await _flutterFptSocketPlugin.connectChatbot(
          token, botcode, senderid, sendername, chatBotAttributes, false);
      MethodChannel channel =
          _flutterFptSocketPlugin.getReceivedMessageChannel();
      channel.setMethodCallHandler((call) async {
        final dataNew = call.arguments;
        final parseJson = json.decode(dataNew);
        print(parseJson);
      });
    } on PlatformException {
      throw 'Failed to get connect chatbot.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    // setState(() {
    // _platformVersion = platformVersion;
    // });
  }

  void sendMessage() {
    _flutterFptSocketPlugin.sendMessageChatbot(
        "{title: Xem thư viện, payload: Tổng quan#, url: null, phone_call: null, webview: null}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: GestureDetector(
              onTap: sendMessage, child: Text('Running on: \n')),
        ),
      ),
    );
  }
}