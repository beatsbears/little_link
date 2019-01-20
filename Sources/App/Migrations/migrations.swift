//
//  migrations.swift
//  little_link
//
//  Created by Andrew Scott on 1/19/19.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct AddFriendlyIndex: Migration {
    typealias Database = PostgreSQLDatabase
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return conn.create(index: "friendly_idx").on(\Link.friendlyUrl).unique().run()
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return Future.map(on: conn) {}
    }
}

