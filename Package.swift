// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Loafer",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Loafer",
            targets: ["Loafer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", exact: "10.7.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.6.1"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.5.0"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", exact: "7.1.1"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", exact: "1.8.3"),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: "4.0.8"),
        .package(url: "https://github.com/freshOS/Stevia.git", exact: "5.1.2"),
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.49.2"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", exact: "8.1.2"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.19"),
        .package(url: "https://github.com/huri000/SwiftEntryKit.git", exact: "2.0.0"),
        .package(url: "https://github.com/pujiaxin33/JXSegmentedView.git", exact: "1.4.1"),
        .package(url: "https://github.com/wxxsw/GSMessages.git", exact: "1.7.5"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
        .package(url: "https://github.com/FSPagerView/FSPagerView.git", exact: "0.8.3")
    ],
    targets: [
        .target(
            name: "Loafer",
            dependencies: [
                "Alamofire",
                .product(name: "Lottie", package: "lottie-ios"),
                "IQKeyboardManager",
                "CryptoSwift",
                "Starscream",
                .product(name: "Stevia", package: "Stevia"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "PromiseKit", package: "PromiseKit"),
                "Nuke",
                "ZIPFoundation",
                "SwiftEntryKit",
                "JXSegmentedView",
                "GSMessages",
                "KeychainAccess",
                "FSPagerView"
            ]),
        .testTarget(
            name: "LoaferTests",
            dependencies: ["Loafer"]),
    ]
) 