//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/15.
//  
//


import Foundation
import Vapor

class WebSocketClients {
    var eventLoop: EventLoop
    var storage: [String: WebSocketClient]

    var active: [WebSocketClient] {
        self.storage.values.filter { !$0.socket.isClosed }
    }

    init(eventLoop: EventLoop, clients: [String: WebSocketClient] = [:]) {
        self.eventLoop = eventLoop
        self.storage = clients
    }

    func add(_ client: WebSocketClient) {
        self.storage[client.memberInfo.account] = client
    }

    func remove(_ client: WebSocketClient) {
        self.storage[client.memberInfo.account] = nil
    }

    func find(_ uuid: String) -> WebSocketClient? {
        self.storage[uuid]
    }

    deinit {
        let futures = self.storage.values.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}

class ChatRoom: Equatable {
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }

    var id: UUID
    var name: String

    var clients: WebSocketClients

    init(eventLoop: EventLoop, id: UUID = UUID(), name: String = "聊天室") {
        self.clients = WebSocketClients(eventLoop: eventLoop)
        self.id = id
        self.name = name
    }

    func connect(_ ws: WebSocket) {

        ws.onBinary { [weak self] (ws, buffer) in
            if var msg = buffer.decodeWebsocketMessage() {
                let wsClient = WebSocketClient(memberInfo: msg.sender, socket: ws)
                self?.clients.add(wsClient)

                let encoder = JSONEncoder()
                msg.id = UUID().uuidString
                msg.sentDate = Date()

                print("message receive: \(msg)")

                guard let data = try? encoder.encode(msg) else { return }
                self?.clients.active.forEach({ (wsClient) in
                    wsClient.socket.send([UInt8](data))
                })
                return
            }
        }
    }
}

struct ChatRoomData: Content {
    var id: UUID?
    var name: String
}

class ChatRoomManager {
    static let shared = ChatRoomManager()
    private init() {}

    private(set) var chatRooms: [UUID: ChatRoom] = [:]

    func remove(_ chatRoom: ChatRoom) {
        chatRooms[chatRoom.id] = nil
    }

    func add(_ chatRoom: ChatRoom) {
        guard !chatRooms.keys.contains(chatRoom.id) else { return }
        chatRooms[chatRoom.id] = chatRoom
    }

    
}
