//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/17.
//  
//


import Foundation
import Vapor

struct ChatRoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chat = routes.grouped("Chat")

        chat.get("GetPublicChatRooms", use: getPublicChatRooms)
        chat.post("CreateChatRoom", use: createChatRoom)
    }

    func getPublicChatRooms(request: Request) throws -> EventLoopFuture<TransferModel<[ChatRoomData]>> {
        return request.eventLoop
            .makeSucceededFuture(
                TransferModel(data: ChatRoomManager.shared.chatRooms.map {
                    return ChatRoomData(id: $0.value.id, name: $0.value.name)
        }))
    }

    func createChatRoom(request: Request) throws -> EventLoopFuture<TransferModel<Bool>> {
        var newChatRoom = try request.content.decode(ChatRoomData.self)
        newChatRoom.id = UUID()
        ChatRoomManager.shared.add(ChatRoom(eventLoop: request.eventLoop, id: newChatRoom.id!, name: newChatRoom.name))
        return request.eventLoop.makeSucceededFuture(TransferModel(data: true))
    }


}
