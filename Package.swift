// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIComponents",
    platforms: [
        .iOS("16"),
        .macOS("14"),
        .tvOS("16"),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftUIComponents",
            targets: ["SwiftUIComponents"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SwiftUtilities", url: "https://github.com/moyoteg/SwiftUtilities", .branch("master")),
        
        // 3rd party
        .package(name: "DeviceKit", url: "https://github.com/devicekit/DeviceKit.git", .upToNextMajor(from: "4.2.1")),
        .package(name: "SwiftUICharts", url: "https://github.com/AppPear/ChartView", .upToNextMajor(from: "1.5.5")),
        .package(name: "PermissionsKit", url: "https://github.com/moyoteg/PermissionsKit", .branch("main")),
        .package(name: "CloudyLogs", url: "https://github.com/moyoteg/CloudyLogs", .branch("master")),
        .package(name: "SwiftyUserDefaults", url: "https://github.com/sunshinejr/SwiftyUserDefaults", from: "5.0.0"),
//        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect.git", .branch("master")),
        .package(name: "Introspect", url: "https://github.com/moyoteg/SwiftUI-Introspect", .branch("master")),
//        .package(name: "FlowGrid", url: "https://github.com/moyoteg/FlowGrid", .branch("master")),
        .package(name: "SwiftUI-Flow", url: "https://github.com/moyoteg/SwiftUI-Flow", .branch("main")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftUIComponents",
            dependencies: [
                .product(name: "SwiftUtilities", package: "SwiftUtilities"),
                // 3rd Party
                .product(name: "DeviceKit", package: "DeviceKit", condition: .when(platforms: [.iOS, .watchOS, .macCatalyst])),
                .product(name: "SwiftUICharts", package: "SwiftUICharts", condition: .when(platforms: [.iOS, .macOS, .watchOS])),
                
                // PermissionsKit
                .product(name: "CameraPermission", package: "PermissionsKit"),
                .product(name: "PhotoLibraryPermission", package: "PermissionsKit"),
                .product(name: "NotificationPermission", package: "PermissionsKit"),
                .product(name: "MicrophonePermission", package: "PermissionsKit"),
                .product(name: "CalendarPermission", package: "PermissionsKit"),
                .product(name: "ContactsPermission", package: "PermissionsKit"),
                .product(name: "RemindersPermission", package: "PermissionsKit"),
                .product(name: "SpeechRecognizerPermission", package: "PermissionsKit"),
                .product(name: "LocationWhenInUsePermission", package: "PermissionsKit"),
                .product(name: "LocationAlwaysPermission", package: "PermissionsKit"),
                .product(name: "MotionPermission", package: "PermissionsKit"),
                .product(name: "MediaLibraryPermission", package: "PermissionsKit"),
                .product(name: "BluetoothPermission", package: "PermissionsKit"),
                .product(name: "TrackingPermission", package: "PermissionsKit"),
                .product(name: "FaceIDPermission", package: "PermissionsKit"),
                .product(name: "SiriPermission", package: "PermissionsKit"),
                .product(name: "HealthPermission", package: "PermissionsKit"),
                
                "CloudyLogs",
                "SwiftyUserDefaults",
                "Introspect",
//                "FlowGrid",
                .product(name: "Flow", package: "SwiftUI-Flow"),
            ]
        ),
        
            .testTarget(
                name: "SwiftUIComponentsTests",
                dependencies: ["SwiftUIComponents"]
            ),
    ]
)
