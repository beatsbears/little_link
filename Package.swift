// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "little_link",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Redis","Logging"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
