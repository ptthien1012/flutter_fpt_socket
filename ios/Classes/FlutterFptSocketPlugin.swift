import Flutter
import UIKit
import ScClient
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
let chatbot = ChatBot()

public class FlutterFptSocketPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "connectChatbotChannel", binaryMessenger: registrar.messenger())
    let instance = FlutterFptSocketPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
      chatbot.toFlutterChannel = FlutterMethodChannel(name: "nativeToFlutterChatbotChannel", binaryMessenger: registrar.messenger())
      chatbot.reconnectChannel = FlutterMethodChannel(name: "reconnectChatbotChannel", binaryMessenger: registrar.messenger())
      chatbot.sendMessageChannel = FlutterMethodChannel(name: "sendMessageChatbotChannel", binaryMessenger: registrar.messenger())
      chatbot.disConnectChatbotChannel = FlutterMethodChannel(name: "disConnectChatbotChannel", binaryMessenger: registrar.messenger())
  }
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let arguments = call.arguments as! Dictionary<String, Any>
      let action = arguments["reconnect"] as! Bool
      chatbot.token = arguments["token"] as! String
      chatbot.senderId = arguments["senderId"] as! String
      chatbot.botCode = arguments["botCode"] as! String
      chatbot.senderName = arguments["senderName"] as! String
      self.getHelloChat(chatBot: chatbot, resultFlutter: result, reconnect: action)
      self.createChatbotChannel()
  }
     func createChatbotChannel(){
        chatbot.sendMessageChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "sendMessageChatbot" else {
          result(FlutterMethodNotImplemented)
          return
        }
          let arguments = call.arguments as! Dictionary<String, Any>
          let action = arguments["button"] as! String
          let button = self?.stringToButton(data: action)
          self?.startChat(chatBot: chatbot, button: button!)

      })
         chatbot.disConnectChatbotChannel.setMethodCallHandler({
             [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
               guard call.method == "disConnectChatbot" else {
                 result(FlutterMethodNotImplemented)
                 return
               }
             chatbot.isConnectedChanel = false
             })
    }
   
   func recievedMessage(chatBot: ChatBot) {
       chatBot.client.onChannel(channelName: chatBot.chanelBot, ack: {
           (channelName : String , data : AnyObject?) in
           let dataString = self.objectToString(data: data!)
               chatbot.toFlutterChannel.invokeMethod("nativeToFlutterChatbot", arguments: dataString)
       })

   }
   func startChat(chatBot: ChatBot, button: Button) {
       chatBot.startChat(clientNew: chatBot.client, button: button)
       self.recievedMessage(chatBot: chatBot)
       
       
   }
   
   func getHelloChat(chatBot: ChatBot, resultFlutter: @escaping FlutterResult, reconnect: Bool) {
       chatBot.connectChat(reconnect: reconnect) { result in
           let jsonString = self.objectToString(data: result!)
           let socketModel = self.stringToSocketModel(data: jsonString)
           if (socketModel?.source == 2) {
               resultFlutter(jsonString)
           }
           
       }
   }
   
   
   func objectToString(data: AnyObject) -> String {

       do {
           let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
           let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
           return jsonString
       } catch {}
      return ""
   }
   func stringToButton(data: String) -> Button {
       do {
           let jsonData = Data(data.utf8)
           // Decode
           let jsonDecoder = JSONDecoder()
           let secondDog = try jsonDecoder.decode(Button.self, from: jsonData)
           return secondDog
       } catch {
           print(error.localizedDescription)

       }
       return Button(title: "", payload: "", webview: "", url: "")
   }
   func stringToSocketModel(data:String) -> SocketModel? {
       do {
           let jsonData = Data(data.utf8)
           // Decode
           let jsonDecoder = JSONDecoder()
           let secondDog = try jsonDecoder.decode(SocketModel.self, from: jsonData)
           return secondDog
       } catch {
           print(error.localizedDescription)

       }
       return nil
   }
}
public class ChatBot {
    var client : ScClient
    var token : String
    var senderId : String
    var chanelBot : String
    var botCode : String
    var senderName : String
    var isConnectedChanel : Bool
    var toFlutterChannel: FlutterMethodChannel
    var reconnectChannel: FlutterMethodChannel
    var sendMessageChannel: FlutterMethodChannel
    var disConnectChatbotChannel: FlutterMethodChannel
    
    init(client: ScClient = ScClient(url: "https://livechat.fpt.ai:443/ws/"), token: String = "", senderId: String = "", chanelBot: String = "", botCode: String = "", senderName: String = "", chatBotAttributes: String = "", isConnectedChanel: Bool = false) {
//        var request = URLRequest(url: URL(string: "https://livechat.fpt.ai:443/ws/")!)
//        request.setValue("true", forHTTPHeaderField: "autoReconnect")
        self.client = client
        self.token = token
        self.senderId = senderId
        self.chanelBot = chanelBot
        self.botCode = botCode
        self.senderName = senderName
        self.isConnectedChanel = isConnectedChanel
        self.toFlutterChannel = FlutterMethodChannel()
        self.reconnectChannel = FlutterMethodChannel()
        self.sendMessageChannel = FlutterMethodChannel()
        self.disConnectChatbotChannel = FlutterMethodChannel()
    }
//    let controllerToFlutter : FlutterViewController = (self.window?.rootViewController)! as FlutterViewController
//    let toFlutterChannel = FlutterMethodChannel(name: "nativeToFlutterChatbotChannel",
//                                   binaryMessenger: controllerToFlutter.binaryMessenger)

    
    public func connectChat(reconnect: Bool, completion: @escaping(AnyObject?) -> ()) {

        let onConnect = {
            (client :ScClient) in
            print("Connnected to server: ")
            print("da ket noi: ", client.isConnected())
        }

        let onDisconnect = {
            (client :ScClient, error : Error?) in
            print("Disconnected from server due to ", error?.localizedDescription ?? "")
            client.disconnect()
            if (self.isConnectedChanel) {
                self.reconnectChannel.invokeMethod("reconnectChatbot", arguments: "")
            }
        }

        let onAuthentication = {
            (client :ScClient, isAuthenticated : Bool?) in
            print("Authenticated is ", isAuthenticated!)
            let params:[String:Any] = ["bot_code": self.botCode ,"sender_id": self.senderId,"sender_name": self.senderName,"token":self.token]
            print("data: ", params)
            client.emitAck(eventName: "sender_request_authenticate", data: params as AnyObject, ack: {
                (eventName : String , error: AnyObject?, data : AnyObject?) in
                            print ("Got data when emit", eventName, " object data is ", data!)
            })
    //          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    //              self.startChat(clientNew: client)
    //          }
        }
        
        let onSetAuthentication = {
            (client : ScClient, token : String?) in
            print("Token is ", token!)
            
            let stringMD5 = self.senderId + "." + self.botCode
            let md5Data = self.MD5(string: stringMD5)

            let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
            print("md5Hex: \(md5Hex)")
            
            self.chanelBot = md5Hex + "@" + self.botCode + "/livechat"
            print("chanel: ", self.chanelBot)
            client.subscribeAck(channelName: self.chanelBot, ack : {
                    (channelName : String, error : AnyObject?, data : AnyObject?) in
                    if (error is NSNull) {
                        self.isConnectedChanel = true
                        print("Successfully subscribed to channel ", channelName)
                        if (!reconnect) {
                            self.startChat(clientNew: client, button: nil)
                        }
                    } else {
                        print("Got error while subscribing ", error!)
                    }
                    
                })
            client.onChannel(channelName: self.chanelBot, ack: {
                (channelName : String , data : AnyObject?) in
                print ("Got data global for channel", channelName, " object data is ", data!)
                let dataString = self.objectToString(data: data!)
                print("data moi ne:", dataString)
                let socketModel = self.stringToSocketModel(data: dataString)
                if (socketModel?.source == 2) {
                    self.toFlutterChannel.invokeMethod("nativeToFlutterChatbot", arguments: dataString)
                    completion(data)
                } else {
                    self.toFlutterChannel.invokeMethod("nativeToFlutterChatbot", arguments: dataString)
                }
            })
                
        }
        client.setBasicListener(onConnect: onConnect, onConnectError: nil, onDisconnect: onDisconnect)
        client.setAuthenticationListener(onSetAuthentication: onSetAuthentication, onAuthentication: onAuthentication)
        client.connect()
    }

    
    

            
    private func startCode(clientNew: ScClient) {
//         All emit, receive and publish events
        let params:[String:Any] = ["bot_code": botCode ,"sender_id": senderId,"sender_name": senderName,"token":token]
        print("data: ", params)
        clientNew.emitAck(eventName: "sender_request_authenticate", data: params as AnyObject, ack: {
            (eventName : String , error: AnyObject?, data : AnyObject?) in
                        print ("Got data when emit", eventName, " object data is ", data!)
        })
    }
     func startChat(clientNew: ScClient, button: Button?) {
         let params: [String:Any]
         if (button != nil) {
             if (button?.payload == "null") {
                 params = [
                    "channel": "livechat",
                    "sender_id": senderId,
                    "sender_name": senderName,
                    "bot_code": botCode,
                    "message": [
                        "type": "text",
                        "content": button?.title
                    ]
                 ]
             } else {
                 params = [
                    "channel": "livechat",
                    "sender_id": senderId,
                    "sender_name": senderName,
                    "bot_code": botCode,
                    "message": [
                        "type": "payload",
                        "content": (button?.payload ?? "") + "#" + (button?.title ?? "")
                    ]
                 ]
             }
         }
         else {
         params = [
            "channel": "livechat",
            "sender_id": senderId,
            "sender_name": senderName,
            "bot_code": botCode,
            "message": [
                "type": "payload",
                "content": "get_started"
            ]
         ]
         }
        print("data: ", params)
        clientNew.emit(eventName: "user_send_message", data:params  as AnyObject)

    }
    
    func MD5(string: String) -> Data {
            let length = Int(CC_MD5_DIGEST_LENGTH)
            let messageData = string.data(using:.utf8)!
            var digestData = Data(count: length)

            _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                messageData.withUnsafeBytes { messageBytes -> UInt8 in
                    if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(messageData.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                    return 0
                }
            }
            return digestData
        }
    func objectToString(data: AnyObject) -> String {

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            return jsonString
        } catch {}
       return ""
    }
    func stringToButton(data: String) -> Button {
//        var tempdata = "{\"title\": \"Xem thư viện\", \"payload\": \"Tổng quan#\", \"webview\": null}"
        do {
            let jsonData = Data(data.utf8)
            // Decode
            let jsonDecoder = JSONDecoder()
            let secondDog = try jsonDecoder.decode(Button.self, from: jsonData)
            return secondDog
        } catch {
            print(error.localizedDescription)

        }
        return Button(title: "", payload: "", webview: "", url: "")
    }
    func stringToSocketModel(data:String) -> SocketModel? {
        do {
            let jsonData = Data(data.utf8)
            // Decode
            let jsonDecoder = JSONDecoder()
            let secondDog = try jsonDecoder.decode(SocketModel.self, from: jsonData)
            return secondDog
        } catch {
            print(error.localizedDescription)

        }
        return nil
    }
    
    func stringToAttributes(data:String) -> ChatBotAttributes? {
        do {
            let dataNew = "{" + data + "}"
            let jsonData = Data(dataNew.utf8)
            // Decode
            let jsonDecoder = JSONDecoder()
            let secondDog = try jsonDecoder.decode(ChatBotAttributes.self, from: jsonData)
            return secondDog
        } catch {
            print(error.localizedDescription)

        }
        return nil
    }
    
    func chatBotConfigToString(data:ChatBotConfig) -> String? {
        do {
            let jsonTicketsEncodeBack = try JSONEncoder().encode(data)
            let jsonTickets = String(data: jsonTicketsEncodeBack, encoding: .utf8) // true
            return jsonTickets
        } catch {
            print(error.localizedDescription)

        }
        return nil
    }
    
}
struct ChatBotConfig: Codable {
    let object_payload: ObjectPayload?

}

// MARK: - ObjectPayload
struct ObjectPayload: Codable {
    let set_attributes: ChatBotAttributes?

}
struct ChatBotAttributes: Codable {
    let login_user_token, mypt_user_id, mypt_user_email, empJobTitle: String?
    let empCode, childDepart, workingBranch: String?

}
struct SocketModel: Codable {
    let senderType,source: Int?
    let content: Content?
    let type, created_time: String?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case senderType = "sender_type"
        case id = "_id"
        case content, type
        case created_time = "created_time"
        case source
    }
}

// MARK: - Content
struct Content: Codable {
    let buttons: [Button]?
    let binaryContent: String?
    let url: String?
    let title: String?
    let text: String?
    
    enum CodingKeyss: String, CodingKey {
        case binaryContent = "binary_content"
    }
}

// MARK: - Button
struct Button: Codable {
    let title: String
    let payload: String?
    let webview: String?
    let url: String?
}
