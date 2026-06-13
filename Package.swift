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
            url: "https://github.com/falcon-protocol/falcon-ios-sdk/releases/download/1.1.1/FalconSDK.xcframework.zip",
            checksum: "991eba8c8045fa772b5912e38ae005fb07655b91ac8c00fb06d690d5dd90e49f"
        )
    ]
)
