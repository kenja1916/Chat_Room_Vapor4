//
//  File.swift
//  
//
//  Created by Ken Lee on 2020/7/16.
//  
//


import Foundation
import Vapor

final class TransferModel<T: Codable>: Content {
    var data: T?
    var error: ErrorWrapper?

    init(data: T?, error: ErrorWrapper? = nil) {
        self.data = data
        self.error = error
    }
}

struct ErrorWrapper: Content {
    var error: Bool
    var reason: String
}

final class EmptyData: Content {
    init() {}
}

