// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftFormatPlugin",
  products: [
    .plugin(
      name: "Format",
      targets: ["Format"]
    )
  ],
  targets: [
    .plugin(
      name: "Format",
      capability: .command(
        intent: .sourceCodeFormatting(),
        permissions: [
          .writeToPackageDirectory(reason: "This command formats the Swift source files")
        ]
      ),
    )
  ]
)
