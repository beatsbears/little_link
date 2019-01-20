//
//  Link.swift
//  little_link
//
//  Created by Andrew Scott on 1/19/19.
//
import FluentPostgreSQL
import Vapor

final class Link: PostgreSQLModel {
    static let idKey = "id"
    var id: Int?
    var friendlyUrl: String?
    var originalUrl: String
    var shortUrl: String?
    var createdAt: Date?
    var expiresAt: Date?
    
    init(id: Int? = nil,
         friendlyUrl: String? = nil,
         originalUrl: String,
         shortUrl: String?,
         createdAt: Date,
         expiresAt: Date) {
        self.id = id
        self.friendlyUrl = friendlyUrl
        self.originalUrl = originalUrl
        self.shortUrl = shortUrl
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}

extension Link: Migration { }
extension Link: Content { }
extension Link: Parameter { }
