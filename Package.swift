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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.3.0/FalconSDK.xcframework.zip",
            checksum: "90457985b9b3ddd61e3479f72e7a5f6eb642a6dfa632141bc3ca3101899ec196"
        )
    ]
)
