//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/15.
//  
//

import Vapor
import Foundation

class WebSocketClient {

    var memberInfo: MemberInfo
    var socket: WebSocket

    init(memberInfo: MemberInfo, socket: WebSocket) {
        self.memberInfo = memberInfo
        self.socket = socket
    }
}

//class UserClient: WebSocketClient {
//    enum Status {
//        case online
//        case offline
//    }
//
//    var status: Status
//
//    init(account: String, socket: WebSocket, status: Status) {
//        self.status = status
//        super.init(account: account, socket: socket)
//    }
//}
