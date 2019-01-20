//
//  routes.swift
//  little_link
//
//  Created by Andrew Scott on 1/19/19.
//
import Vapor
import Redis

public func routes(_ router: Router) throws {
    
    // Controllers
    let linkController = LinkController()
    
    // Get a list of all links
    // This route doesn't really fit into our use case and could get dangerously large at
    // a certain point so we will comment it out for now. It might be useful as an admin
    // feature in the future.
    // router.get("links", use: linkController.index)
    
    // Deletes a link
    // This route also does not fit into our use case. It might be useful as an admin
    // feature in the future.
    // router.delete("links", Link.parameter, use: linkController.delete)
    
    // Creates a new link
    router.post("links") { req -> Future<Link> in
        let futureId = RedisClient.connect(hostname: "redis", on: req) { (error) in
            }.flatMap { (redis) in
                return redis.increment("id")
        }
        return try linkController.create(req, futureId)
    }
    
    // Catchall for routing
    router.get(all, use: linkController.redirect)
}
