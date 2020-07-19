//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/14.
//  
//

import Fluent
struct CreateMember: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Member.schema)
            .field(.account, .string, .identifier(auto: false))
            .field(.password, .string, .required)
            .field(.name, .string, .required)
            .field(.gender, .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Member.schema).delete()
    }
}
