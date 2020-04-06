// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swiftVulkan",
    products: [
        .library(name: "swiftVulkan",
                 type: .dynamic,
                 targets: [
            "swiftVulkan",
        ]),
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

