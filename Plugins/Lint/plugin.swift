import Foundation
import PackagePlugin

@main
struct FormatPlugin {
  func createSwiftFormatCommand(
    executableURL: URL,
    arguments: [String],
    sourceFiles: [String],
    configurationFilePath: String?,
    workingDirectoryURL: URL
  ) throws -> Command {
    var arguments = arguments

    arguments += [
      "lint",
      "--parallel",
    ]

    if let configurationFilePath = configurationFilePath {
      arguments += ["--configuration", configurationFilePath]
    }

    arguments += sourceFiles

    return .prebuildCommand(
      displayName: "Run swift format lint",
      executable: executableURL,
      arguments: arguments,
      environment: [:],
      outputFilesDirectory: workingDirectoryURL
    )
  }
}

extension FormatPlugin: BuildToolPlugin {
  func createBuildCommands(
    context: PluginContext,
    target: any Target
  ) async throws -> [Command] {
    guard let sourceFiles = target.sourceModule?.sourceFiles.swiftSourceFiles,
      !sourceFiles.isEmpty
    else { return [] }

    var configurationFilePath: String? = context.package
      .directoryURL
      .appending(component: ".swift-format")
      .path(percentEncoded: false)

    if configurationFilePath.map(FileManager.default.fileExists(atPath:)) == false {
      configurationFilePath = nil
    }

    return [
      try createSwiftFormatCommand(
        executableURL: context.tool(named: "swift").url,
        arguments: ["format"],
        sourceFiles: sourceFiles,
        configurationFilePath: configurationFilePath,
        workingDirectoryURL: context.pluginWorkDirectoryURL
      )
    ]
  }
}

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension FormatPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(
      context: XcodePluginContext,
      target: XcodeTarget
    ) throws -> [Command] {
      guard case let sourceFiles = target.inputFiles.swiftSourceFiles,
        !sourceFiles.isEmpty
      else { return [] }

      var configurationFilePath: String? = context.xcodeProject
        .directoryURL
        .appending(component: ".swift-format")
        .path(percentEncoded: false)

      if configurationFilePath.map(FileManager.default.fileExists(atPath:)) == false {
        configurationFilePath = nil
      }

      return [
        try createSwiftFormatCommand(
          executableURL: context.tool(named: "swift").url,
          arguments: ["format"],
          sourceFiles: sourceFiles,
          configurationFilePath: configurationFilePath,
          workingDirectoryURL: context.pluginWorkDirectoryURL
        )
      ]
    }
  }
#endif

private extension FileList {
  var swiftSourceFiles: [String] {
    return compactMap { file in
      let isTarget = file.type == .source && file.url.pathExtension == "swift"
      return isTarget ? file.url.path(percentEncoded: false) : nil
    }
  }
}
