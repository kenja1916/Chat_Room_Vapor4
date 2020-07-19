import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: MemberController())
    try app.register(collection: ChatRoomController())

    app.webSocket("ChatRoom", ":chatRoomId",
                  maxFrameSize: WebSocketMaxFrameSize(integerLiteral: Int(UInt32.max))) { (request, ws) in
        guard let chatRoomId = request.parameters.get("chatRoomId", as: UUID.self) else { return }
        ChatRoomManager.shared.chatRooms[chatRoomId]?.connect(ws)
    }

}
