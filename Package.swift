// swift-tools-version: 5.8
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "GetDone",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "GetDone",
            targets: ["AppModule"],
            bundleIdentifier: "com.getdone.app",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .calendar),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [.portrait, .landscapeRight, .landscapeLeft, .portraitUpsideDown(.when(deviceFamilies: [.pad]))]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: []
        )
    ]
)
