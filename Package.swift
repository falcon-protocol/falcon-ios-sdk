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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.2.0/FalconSDK.xcframework.zip",
            checksum: "fa93699a8ee364baeeca76e72a3fab83378025860d305cab74db85671fa7411a"
        )
    ]
)
