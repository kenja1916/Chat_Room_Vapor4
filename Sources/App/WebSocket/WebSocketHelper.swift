//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/15.
//  
//


import Foundation
import Vapor

enum MessageEnum: String, Codable {
    case join = "join"
    case text = "text"
    case image = "image"
}

struct Message: Codable {
    var type: MessageEnum
    var id: String? // set in server
    var sentDate: Date? // set in server
    var sender: MemberInfo
    var imageData: Data?
    var text: String?


    enum CodingKeys: CodingKey {
        case type, id, sentDate, sender, imageData ,text
    }
}

extension ByteBuffer {
    func decodeWebsocketMessage() -> Message? {
        var message: Message? = nil
        do {
            message = try JSONDecoder().decode(Message.self, from: self)
        } catch let error {
            print(error)
        }
        return message
    }
}
