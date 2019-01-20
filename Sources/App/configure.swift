//
//  configure.swift
//  little_link
//
//  Created by Andrew Scott on 1/19/19.
//
import FluentPostgreSQL
import Redis
import Vapor

public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(RedisProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    /// postgres connection config
    let db = Environment.get("POSTGRES_DB") ?? "test"
    let pgHost = Environment.get("POSTGRES_HOST") ?? "db"
    let pgUser = Environment.get("POSTGRES_USER") ?? "test"
    let pgPass = Environment.get("POSTGRES_PASSWORD") ?? "test"
    var pgPort = 5432
    if let pgPortParam = Environment.get("POSTGRES_PORT"), let newPort = Int(pgPortParam) {
        pgPort = newPort
    }
    let pgConfig = PostgreSQLDatabaseConfig(hostname: pgHost, port: pgPort, username: pgUser, database: db, password: pgPass)
    let pgsql = PostgreSQLDatabase(config: pgConfig)
    
    /// redis connection config
    var redisConfig = RedisClientConfig()
    redisConfig.hostname = Environment.get("REDIS_HOST") ?? "redis"
    redisConfig.port = 6379
    let redis = try RedisDatabase(config: redisConfig)
    
    /// register DBs
    var databases = DatabasesConfig()
    databases.add(database: pgsql, as: .psql)
    databases.add(database: redis, as: .redis)
    
    services.register(databases)
    
    // Use KeyedCache
    services.register(KeyedCache.self) { container in
        try container.keyedCache(for: .redis)
    }
    config.prefer(DatabaseKeyedCache<ConfiguredDatabase<RedisDatabase>>.self, for: KeyedCache.self)
    
    // Logging
    /// Enable logging on database for debugging
    databases.enableLogging(on: .psql)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Link.self, database: .psql)
    migrations.add(migration: AddFriendlyIndex.self, database: .psql)
    services.register(migrations)
}
