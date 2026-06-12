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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.0.1/FalconSDK.xcframework.zip",
            checksum: "0de8c48e9e53e8f4d79c3875c86987be56128d5b7c56a35e3c020451bf0e2595"
        )
    ]
)
