import Foundation
import PackagePlugin

@main
struct FormatPlugin {
  func format(
    executableURL: URL,
    arguments: [String],
    sourceFiles: [String],
    configurationFilePath: String?
  ) throws {
    guard !sourceFiles.isEmpty else {
      print("Not found any swift files to format.")
      return
    }

    var arguments =
      arguments + [
        "--parallel", "--in-place",
      ]

    if let configurationFilePath = configurationFilePath {
      arguments.append(contentsOf: ["--configuration", configurationFilePath])
    }

    arguments.append(contentsOf: sourceFiles)

    let process = try Process.run(executableURL, arguments: arguments)
    process.waitUntilExit()

    if process.terminationReason == .exit && process.terminationStatus == 0 {
      print("Formatted the source code.")
    } else {
      let problem = "\(process.terminationReason):\(process.terminationStatus)"
      Diagnostics.error("swift-format invocation failed: \(problem)")
    }
  }
}

extension FormatPlugin: CommandPlugin {
  func performCommand(
    context: PluginContext,
    arguments: [String]
  ) async throws {
    var argExtractor = ArgumentExtractor(arguments)
    let targetNames = argExtractor.extractOption(named: "target")
    let targetsToFormat =
      targetNames.isEmpty
      ? context.package.targets : try context.package.targets(named: targetNames)
    let sourceCodeTargets = targetsToFormat.compactMap { $0 as? SourceModuleTarget }

    let configurationFilePath = argExtractor.extractOption(
      named: "swift-format-configuration"
    ).first

    let inputFiles = argExtractor.extractOption(named: "input-files")
    let exclusiveInputFiles = argExtractor.extractFlag(named: "input-files-only") > 0

    try format(
      executableURL: context.tool(named: "swift").url,
      arguments: ["format"],
      sourceFiles: exclusiveInputFiles
        ? inputFiles : inputFiles + sourceCodeTargets.flatMap(\.sourceFiles.swiftSourceFiles),
      configurationFilePath: configurationFilePath
    )
  }
}

#if canImport(XcodeProjectPlugin)
  import XcodeProjectPlugin

  extension FormatPlugin: XcodeCommandPlugin {
    func performCommand(
      context: XcodeProjectPlugin.XcodePluginContext,
      arguments: [String]
    ) throws {
      var argExtractor = ArgumentExtractor(arguments)
      let configurationFilePath = argExtractor.extractOption(
        named: "swift-format-configuration"
      ).first

      try format(
        executableURL: context.tool(named: "swift").url,
        arguments: ["format"],
        sourceFiles: context.xcodeProject.targets.flatMap(\.inputFiles.swiftSourceFiles),
        configurationFilePath: configurationFilePath
      )
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
