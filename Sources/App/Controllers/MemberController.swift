//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/15.
//  
//

import Foundation
import Vapor
import Fluent

enum MemberError: Error {
    case userNotExist
    case wrongAccountOrPassword
    case wrongPassword

    var description: String {
        switch self {
        case .userNotExist:
            return "無此使用者"
        case .wrongAccountOrPassword:
            return "帳號或密碼錯誤"
        case .wrongPassword:
            return "密碼錯誤"
        }
    }
}

struct MemberController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let members = routes.grouped("Members")

        members.post("CreateMember", use: createMember)
        members.post("Login", use: login)

        members.post("EditPassword", use: editPassword)
        members.post("EditMemberInfo", use: editMemberInfo)

    }

    func createMember(request: Request) throws -> EventLoopFuture<TransferModel<Bool>> {
        let memberLoginData = try request.content.decode(MemberLoginData.self)
        print("createMember - account: \(memberLoginData.account), password: \( memberLoginData.password)")
        let member = Member(id: memberLoginData.account, password: memberLoginData.password)
        return member.create(on: request.db).map { TransferModel(data: true) }
    }

    func login(request: Request) throws -> EventLoopFuture<TransferModel<MemberInfo>> {
        let memberLoginData = try request.content.decode(MemberLoginData.self)
        return Member.find(memberLoginData.account, on: request.db)
            .unwrap(or: MemberError.userNotExist)
            .flatMapThrowing { memberInDb -> TransferModel<MemberInfo> in
                guard let id = memberInDb.id else { throw Abort(.notFound) }

                if memberInDb.password == memberLoginData.password {
                    return TransferModel(data: MemberInfo(account: id, name: memberInDb.name, gender: memberInDb.gender))
                } else {
                    return TransferModel(data: nil, error: .init(error: true, reason: "密碼錯誤"))
                }
        }
    }

    func editPassword(request: Request) throws -> EventLoopFuture<TransferModel<EmptyData>> {
        let memberLoginData = try request.content.decode(MemberLoginData.self)
        return Member.find(memberLoginData.account, on: request.db)
            .unwrap(or: MemberError.userNotExist)
            .flatMap { memberInDb in
                memberInDb.password = memberLoginData.password
                return memberInDb.update(on: request.db).map {
                        TransferModel(data: EmptyData())
                }
            }
    }

    func editMemberInfo(request: Request) throws -> EventLoopFuture<TransferModel<MemberInfo>> {
        let memberInfo = try request.content.decode(MemberInfo.self)
        return Member.query(on: request.db)
            .filter(\.$id == memberInfo.account )
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { member -> EventLoopFuture<TransferModel<MemberInfo>> in
                member.gender = memberInfo.gender
                member.name = memberInfo.name
                return member.update(on: request.db).map {
                    TransferModel(data: memberInfo)
                }
        }
    }
}
