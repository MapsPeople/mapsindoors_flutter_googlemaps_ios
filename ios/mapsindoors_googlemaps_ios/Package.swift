// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let mapsindoorsVersion = Version("4.15.2")

let package = Package(
    name: "mapsindoors_googlemaps_ios",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "mapsindoors-googlemaps-ios",
            targets: ["mapsindoors_googlemaps_ios"])
    ],
    dependencies: [
        .package(url: "https://github.com/MapsPeople/mapsindoors-codable-ios.git", exact: mapsindoorsVersion),
        .package(url: "https://github.com/MapsPeople/mapsindoors-googlemaps-ios.git", exact: mapsindoorsVersion),
    ],
    targets: [
        .target(
            name: "mapsindoors_googlemaps_ios",
            dependencies: [
                .product(name: "MapsIndoorsCodable", package: "mapsindoors-codable-ios"),
                .product(name: "MapsIndoorsGoogleMaps", package: "mapsindoors-googlemaps-ios"),
            ]
        )
    ]
)
