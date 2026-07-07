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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.3.1/FalconSDK.xcframework.zip",
            checksum: "afe402f7f4ca3264187eb6e33f6820e10854de053519087cd41b5a17e7e0390c"
        )
    ]
)
