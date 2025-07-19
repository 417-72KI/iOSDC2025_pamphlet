// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MyLibrary",
    products: [
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary"]
        ),
    ],
    targets: [
        .target(name: "MyLibrary"),
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]
        ),
    ]
)

// MARK: - Upcoming feature flags for Swift 6
package.targets.forEach {
    $0.swiftSettings = [
        // .forwardTrailingClosures,
        .existentialAny,
        .bareSlashRegexLiterals,
        .conciseMagicFile,
        .importObjcForwardDeclarations,
        .disableOutwardActorInference,
        .deprecateApplicationMain,
        .isolatedDefaultValues,
        .globalConcurrency,
    ]
}

// ref: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
private extension SwiftSetting {
    static let forwardTrailingClosures: Self = .enableUpcomingFeature("ForwardTrailingClosures")              // SE-0286, Swift 5.3,  SwiftPM 5.8+
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let bareSlashRegexLiterals: Self = .enableUpcomingFeature("BareSlashRegexLiterals")                // SE-0354, Swift 5.7,  SwiftPM 5.8+
    static let conciseMagicFile: Self = .enableUpcomingFeature("ConciseMagicFile")                            // SE-0274, Swift 5.8,  SwiftPM 5.8+
    static let importObjcForwardDeclarations: Self = .enableUpcomingFeature("ImportObjcForwardDeclarations")  // SE-0384, Swift 5.9,  SwiftPM 5.9+
    static let disableOutwardActorInference: Self = .enableUpcomingFeature("DisableOutwardActorInference")    // SE-0401, Swift 5.9,  SwiftPM 5.9+
    static let deprecateApplicationMain: Self = .enableUpcomingFeature("DeprecateApplicationMain")            // SE-0383, Swift 5.10, SwiftPM 5.10+
    static let isolatedDefaultValues: Self = .enableUpcomingFeature("IsolatedDefaultValues")                  // SE-0411, Swift 5.10, SwiftPM 5.10+
    static let globalConcurrency: Self = .enableUpcomingFeature("GlobalConcurrency")                          // SE-0412, Swift 5.10, SwiftPM 5.10+
}

// MARK: - Enabling Complete Concurrency Checking for Swift 6
// ref: https://www.swift.org/documentation/concurrency/
package.targets.forEach {
    var settings = $0.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency"))
    $0.swiftSettings = settings
}
