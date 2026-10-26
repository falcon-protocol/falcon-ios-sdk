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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.3.2/FalconSDK.xcframework.zip",
            checksum: "15283e6e6882d68e27ecca2d322026f828e5ab21011b458e87b237313beace37"
        )
    ]
)
