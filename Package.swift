// swift-tools-version:5.2

import PackageDescription

let platforms: [SupportedPlatform] = [
    .iOS("13.2"),
    .macOS("10.15"),
    .tvOS("13.2")
]

let package = Package(
    name: "swiftVulkan",
    platforms: platforms,
    products: [
        .library(name: "swiftVulkan",
                 type: .dynamic,
                 targets: [
            "swiftVulkan",
        ]),
        .library(name: "vulkan",
                 targets: ["vulkan"]),
    ],
    dependencies: [
    ],
    targets: [
        .systemLibrary(name: "vulkan",
                       pkgConfig: "vulkan",
                       providers: [
            .apt([
                "libvulkan-dev",
            ]),
         ]),
        .target(name: "swiftVulkan",
                dependencies: [
            "vulkan",
        ]),
        .testTarget(name: "swiftVulkanTests",
                    dependencies: [ "swiftVulkan" ]),
    ]
)

