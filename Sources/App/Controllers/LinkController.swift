//
//  LinkController.swift
//  little_link
//
//  Created by Andrew Scott on 1/19/19.
//
import Vapor
import Fluent
import Foundation
import Logging

final class LinkController {
    // Returns all Links
    // This handler would obviously be turned off in production since it lists all saved links
    func index(_ req: Request) throws -> Future<[Link]> {
        return Link.query(on: req).all()
    }
    
    // Creates a new Link
    func create(_ req: Request, _ id: Future<Int>) throws -> Future<Link> {
        let logger = try req.make(Logger.self)
        return try req.content.decode(Link.self).flatMap { link in
            return id.flatMap { id in
                link.id = id
                link.shortUrl = "." + encode(integer: UInt64(id))
                if link.friendlyUrl == nil {
                    link.friendlyUrl = link.shortUrl
                } else {
                    if link.friendlyUrl!.starts(with: ".") {
                        throw Abort(.badRequest)
                    }
                }
                link.createdAt = Date()
                link.expiresAt = Calendar.current.date(byAdding: .day, value: 10, to: Date())
                logger.info("Saving - \(String(link.id!)) = \(link.originalUrl)")
                do {
                    _ = try self.setCache(req, link)
                    return link.create(on: req)
                } catch {
                    throw Abort(.badRequest)
                }
            }
        }
    }
    
    // Deletes a Link
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Link.self).flatMap { link in
            return link.delete(on: req)
            }.transform(to: .ok)
    }
    
    // Lookup a link based on a defined friendly URL or the URL's id value
    func lookup(_ req: Request) throws -> Future<Link> {
        let logger = try req.make(Logger.self)
        let route: String = String(req.http.url.absoluteString.dropFirst())
        if !route.starts(with: ".") {
            logger.debug("Friendly route lookup - raw=\(route)")
            return Link.query(on: req).filter(\.friendlyUrl == route).first().unwrap(or: Abort(.notFound))
        } else {
            let id = Int(decode(string: route))
            logger.debug("Route lookup - raw=\(route), id=\(id)")
            return Link.find(id, on: req).unwrap(or: Abort(.notFound))
        }
    }
    
    // Redirects to a saved Link
    func redirect(_ req: Request) throws -> Future<HTTPResponse> {
        do {
            let logger = try req.make(Logger.self)
            let route: String = String(req.http.url.absoluteString.dropFirst())
            return try self.checkCache(req).flatMap { cached -> Future<HTTPResponse> in
                if let cached = cached {
                    logger.debug("cache hit - \(link)")
                    var headers = HTTPHeaders()
                    headers.add(name: .location, value: cached)
                    return req.future(HTTPResponse(status: HTTPResponseStatus.init(statusCode: 307),
                                                   version: HTTPVersion.init(major: 1, minor: 1),
                                                   headers: headers))
                }
                logger.debug("cache miss - checking Postgres")
                return try self.lookup(req).flatMap { link -> Future<HTTPResponse> in
                    var headers = HTTPHeaders()
                    headers.add(name: .location, value: link.originalUrl)
                    return req.future(HTTPResponse(status: HTTPResponseStatus.init(statusCode: 307),
                                                   version: HTTPVersion.init(major: 1, minor: 1),
                                                   headers: headers))
                }
            }
        } catch {
            throw Abort(.notFound)
        }
    }
    
    /// Set URL in redis cache
    func setCache(_ req: Request, _ link: Link) throws -> Future<Void> {
        let cache = try req.keyedCache(for: .redis)
        return cache.set(link.friendlyUrl!, to: link.originalUrl)
    }
    
    /// Check if URL exists in redis cache
    func checkCache(_ req: Request) throws -> Future<String?> {
        let route: String = String(req.http.url.absoluteString.dropFirst())
        let cache = try req.keyedCache(for: .redis)
        return cache.get(route, as: String.self)
    }
}
