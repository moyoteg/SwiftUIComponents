// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIComponents",
    platforms: [
        .iOS("16"),
        .macOS("14"),
        .tvOS("16"),
        .watchOS("8"),
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
//        .package(name: "Introspect_moyoteg", url: "https://github.com/moyoteg/SwiftUI-Introspect", .branch("master")),
//        .package(name: "FlowGrid", url: "https://github.com/moyoteg/FlowGrid", .branch("master")),
        .package(name: "SwiftUI-Flow", url: "https://github.com/moyoteg/SwiftUI-Flow", .branch("main")),
        .package(name: "CachedAsyncImage", url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", .branch("main")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.16.0"),
//        .package(name: "FirebaseUI-iOS", url: "https://github.com/firebase/FirebaseUI-iOS", from: "13.0.0"),
        .package(name: "GoogleSignIn", url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
        
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.5"),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: "3.6.8"),
        .package(name: "Moya", url: "https://github.com/Moya/Moya", .upToNextMajor(from: "15.0.0")),
        .package(name: "SwiftPackageManifest", url: "https://github.com/SwiftDocOrg/SwiftPackageManifest", .upToNextMajor(from: "0.1.0")),
        .package(name: "ExyteChat", url: "https://github.com/moyoteg/Chat.git", .branch("main")),
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.3.0")

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
//                "Introspect_moyoteg",
//                "FlowGrid",
                .product(name: "Flow", package: "SwiftUI-Flow"),
                "CachedAsyncImage",
                
                // Firebase
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalyticsWithoutAdIdSupport", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalyticsOnDeviceConversion", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalyticsSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppDistribution-Beta", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseAuthCombine-Community", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseFirestoreCombine-Community", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseFunctionsCombine-Community", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseStorageCombine-Community", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabaseSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseInAppMessagingSwift-Beta", package: "firebase-ios-sdk"),
                .product(name: "FirebaseInstallations", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMLModelDownloader", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
//                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfigSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                
                "SDWebImageSwiftUI",
                "PhoneNumberKit",
                //                "GoogleSignIn-iOS"
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn"),
                //                .product(name: "FirebaseAuthUI", package: "FirebaseUI-iOS"),
                "Moya",
                "SwiftPackageManifest",
                "ExyteChat",
                "SDWebImageWebPCoder",
            ]
        ),
        
            .testTarget(
                name: "SwiftUIComponentsTests",
                dependencies: ["SwiftUIComponents"]
            ),
    ]
)
