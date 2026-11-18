// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FalconSDK",
    platforms: [
        .iOS(.v15)
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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.4.0/FalconSDK.xcframework.zip",
            checksum: "84ce0492e8979b581fbc6aa299be97ca5ecd81e34ea29561a201785f825e6bed"
        )
    ]
)
