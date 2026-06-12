// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FalconSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "FalconSDK",
            targets: ["FalconSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "FalconSDK",
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.0.0/FalconSDK.xcframework.zip",
            checksum: "52559dc952cb9a9412357188f80a52156e364600c5e5889b35310ff27b552c7c"
        )
    ]
)
