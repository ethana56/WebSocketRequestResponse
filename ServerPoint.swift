import Foundation
import SwiftWebSocket
public class ServerPoint {
    private var responseListeners = Dictionary<UUID, (Message) -> ()>()
    private var listeners = [String : Dictionary<UUID, (Message) -> ()>]()
    private var socket: WebSocket
    private var listenerKeys = Set<UUID>()
    
    
    init(address: String, additionalHTTPHeaders: Dictionary<String, String>) {
        var request = URLRequest(url: URL(string: address)!)
        for key in additionalHTTPHeaders.keys {
            request.addValue(additionalHTTPHeaders[key]!, forHTTPHeaderField: key)
        }
        self.socket = WebSocket(request: request)
        socket.event.message = {msg in
            let msgDataString = msg as! String
            let msgData = try! JSONSerialization.jsonObject(with: msgDataString.data(using: .utf8)!, options: []) as! [String : Any]
            let data = Message(dict: msgData)
            print(data)
            if data.command == nil {
                let listener = self.responseListeners[UUID(uuidString: data.key!)!]!
                listener(data)
                self.responseListeners.removeValue(forKey: UUID(uuidString: data.key!)!)
                self.listenerKeys.remove(UUID(uuidString: data.key!)!)
            } else {
                if self.listeners[data.command!] != nil {
                    for listener in (self.listeners[(data.command)!]?.values)! {
                        listener(data)
                    }
                }
                
            }
        }
    }
    
    func sendMessage(command: String, data: [String : String]?, callback: ((Dictionary<String, Any>?, String?) -> ())?) {
        var key = UUID()
        let message = Message(command: command, key: key.uuidString, data: data, error: nil)
        if callback != nil {
            func callackWrapper(msg: Message) {
                callback!(msg.data, msg.error)
            }
            self.listenerKeys.insert(key)
            self.responseListeners[key] = callackWrapper(msg:)
        }
        let messageAsDictionary = message.asDictionary()
        let messageToSend = try! JSONSerialization.data(withJSONObject: messageAsDictionary, options: [])
        socket.send(messageToSend)
    }
    
    func addListener(for command: String, callback: @escaping(Dictionary<String, Any>?) -> ()) -> ListenerKey {
        var key = UUID()
        func callbackWrapper(msg: Message) {
            callback(msg.data)
        }
        self.listenerKeys.insert(key)
        if self.listeners[command] == nil {
            self.listeners[command] = Dictionary<UUID, (Message) -> ()>()
        }
        self.listeners[command]![key] = callbackWrapper(msg:)
        return ListenerKey(command: command, key: key)
    }
    
    func removeObserver(listenerKey: ListenerKey) {
        listeners[listenerKey.command]!.removeValue(forKey: listenerKey.key)
    }
}

extension Message {
    init(dict: Dictionary<String, Any>) {
        self.command = dict["command"] as? String
        self.key = dict["key"] as? String
        self.data = dict["data"] as? Dictionary<String, Any>
        self.error = dict["error"] as? String
    }
    
    func asDictionary() -> Dictionary<String, Any> {
        return [
            "command" : self.command,
            "key" : self.key,
            "data" : self.data,
            "error" : self.error
        ]
    }
}




