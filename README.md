# swift-format-plugin

A Swift Package Manager plugin that wraps [swift-format](https://github.com/swiftlang/swift-format) for seamless code formatting integration.

## Installation

Add this plugin to your `Package.swift`:

```swift
.package(url: "https://github.com/swiftty/swift-format-plugin.git", from: "1.0.0"),
```

Then configure your target to use the plugin:

```swift
.target(
    name: "YourTarget",
    plugins: [
        .plugin(name: "Lint", package: "swift-format-plugin")
    ]
)
```

## Usage

Run formatting on your package:

```bash
swift package plugin --allow-writing-to-package-directory format-source-code
```

### Options

- `--target`
  Specify one or more target names to format. Default: all package targets.

- `--input-files`
  Specify additional Swift files to format. These files will be included along with target source files.

- `--input-files-only`
  Format only the files specified with `--input-files`, excluding target source files.

- `--lint-only`
  Run swift-format in lint mode only (check formatting without modifying files). Default: false (formats in-place).

- `--swift-format-configuration`
  Path to a custom swift-format configuration file. Default: `.swift-format`


## License

MIT
