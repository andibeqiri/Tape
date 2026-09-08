import ProjectDescription

let project = Project(
    name: "Tape",
    targets: [
        .target(
            name: "Tape",
            destinations: .iOS,
            product: .app,
            bundleId: "com.andibeqiri.Tape",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:],
                ],
            ]),
            sources: ["Sources/**"],
            resources: []
        ),
        .target(
            name: "TapeUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.andibeqiri.TapeUITests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["Tests/TapeUITests/**"],
            dependencies: [.target(name: "Tape")]
        )
    ]
)
