// swift-tools-version: 6.0
import PackageDescription

// Dependency rule (enforced by the graph below): arrows only point "inward".
//
//   App ──▶ Feature* ──▶ DesignSystem ──▶ Domain
//    │                                     ▲
//    └────▶ DataAccess ────────────────────┘
//
// - Domain knows nothing about UI, network or storage.
// - Features never import each other (except the shared AnimalDetail screen)
//   and never import DataAccess: they only see Domain protocols.
// - The App target is the composition root that wires concrete implementations.
let package = Package(
    name: "PawMatchKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "DataAccess", targets: ["DataAccess"]),
        .library(name: "Fixtures", targets: ["Fixtures"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "FeatureAnimalDetail", targets: ["FeatureAnimalDetail"]),
        .library(name: "FeatureDiscover", targets: ["FeatureDiscover"]),
        .library(name: "FeatureMatches", targets: ["FeatureMatches"]),
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "DataAccess", dependencies: ["Domain"]),
        .target(name: "Fixtures", dependencies: ["Domain"]),
        .target(
            name: "DesignSystem",
            dependencies: ["Domain"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "FeatureAnimalDetail",
            dependencies: ["Domain", "DesignSystem", "Fixtures"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "FeatureDiscover",
            dependencies: ["Domain", "DesignSystem", "FeatureAnimalDetail", "Fixtures"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "FeatureMatches",
            dependencies: ["Domain", "DesignSystem", "FeatureAnimalDetail"],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "DomainTests", dependencies: ["Domain", "Fixtures"]),
        .testTarget(name: "DataAccessTests", dependencies: ["DataAccess", "Fixtures"]),
        .testTarget(name: "FeatureDiscoverTests", dependencies: ["FeatureDiscover", "DataAccess", "Fixtures"]),
    ]
)
