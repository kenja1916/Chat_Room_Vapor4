//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/14.
//  
//


import Vapor
import Fluent

extension FieldKey {
    static var account: Self { "account" }
    static var password: Self { "password" }
    static var name: Self { "name" }
    static var gender: Self { "gender" }
}

final class Member: Model, Content {

    static let schema: String = "members"

    @ID(custom: .account, generatedBy: .user)
    var id: String?

    @Field(key: .password)
    var password: String

    @Field(key: .name)
    var name: String

    @Field(key: .gender)
    var gender: Int

    init(){}

    init(id: String, password: String, name: String = "", gender: Int = 2) {
        self.id = id
        self.password = password
        self.name = name
        self.gender = gender
    }
}

struct MemberInfo: Content {
    var account: String
    var name: String
    var gender: Int
}

struct MemberLoginData: Content {
    var account: String
    var password: String
}
