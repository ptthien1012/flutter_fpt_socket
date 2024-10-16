package com.example.flutter_fpt_socket

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** FlutterFptSocketPlugin */
class FlutterFptSocketPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var connectChatbotChannel : MethodChannel
  private lateinit var sendMessageChatbotChannel : MethodChannel
  private lateinit var disConnectChatbotChannel : MethodChannel

  private lateinit var chatBotMethodHandller: ChatBotMethodHandler
  private lateinit var chatBotUtility: ChatBotUtility

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    chatBotMethodHandller = ChatBotMethodHandler()
    chatBotUtility = ChatBotUtility()

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_fpt_socket")
    channel.setMethodCallHandler(this)

    connectChatbotChannel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "connectChatbotChannel")
    connectChatbotChannel.setMethodCallHandler(this)

    sendMessageChatbotChannel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "sendMessageChatbotChannel")
    sendMessageChatbotChannel.setMethodCallHandler(this)

    chatBotUtility.nativeToFlutterChatbotChannel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "nativeToFlutterChatbotChannel")
    chatBotUtility.nativeToFlutterChatbotChannel.setMethodCallHandler(this)

    chatBotUtility.reconnectChatbotChannel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "reconnectChatbotChannel")
    chatBotUtility.reconnectChatbotChannel.setMethodCallHandler(this)

    disConnectChatbotChannel =
      MethodChannel(flutterPluginBinding.binaryMessenger, "disConnectChatbotChannel")
    disConnectChatbotChannel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    println("method called: " + call.method);
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "connectChatbot" -> {
        chatBotMethodHandller.handleOnConnectChatbot(chatBotUtility, call)
      }
      "sendMessageChatbot" -> {
        chatBotMethodHandller.handleOnSendMessageChatbot(chatBotUtility, call)
      }
      "disConnectChatbot" -> {
        chatBotMethodHandller.handleOnDisConnectChatbot(chatBotUtility)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
