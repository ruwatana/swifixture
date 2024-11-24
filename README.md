# 🧪 Swifixture

[![build](https://github.com/ruwatana/swifixture/actions/workflows/build.yml/badge.svg)](https://github.com/ruwatana/swifixture/actions/workflows/build.yml) ![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg) ![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

Swifixture is a tool built as a Swift Package that automatically generates fixture methods for Swift.
This tool is inspired by [uber/mockolo](https://github.com/uber/mockolo).

## 📚 Table of Contents

- [📦 Installation](#-installation)
  - [💡 Basic](#-basic)
  - [🔧 Install in your Xcode Project](#-install-in-your-xcode-project)
- [🚀 Usage](#-usage)
  - [🔧 Options](#-options)
  - [💡 Example](#-example)
    - [Using fixturable](#using-fixturable)
    - [Override Settings for Custom Initial Values](#override-settings-for-custom-initial-values)
    - [Example of Generated Output](#example-of-generated-output)
    - [Additional Imports and Testable Import](#additional-imports-and-testable-import)
- [🚧 Work In Progress](#-work-in-progress)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## 📦 Installation

### 💡 Basic

```bash
git clone https://github.com/ruwatana/swifixture.git
cd swifixture
swift build
```

### 🔧 Install in your Xcode Project

We also recommend to run Swifixture on your Xcode build phases by `BuildTools` package.
(The approach using BuildTools is inspired by [nicklockwood/SwiftFormat](https://github.com/nicklockwood/SwiftFormat/blob/0.55.1/README.md#xcode-build-phase))

To set up Swifixture as an Xcode build phase, do the following:

1. Create a `BuildTools` folder (if not already exists)

`BuildTools` folder is a folder that contains the Swifixture executable.

Because it is a build tool, it is not included in the main package.

```bash
mkdir -p BuildTools
```

2. Create a Swift Package

```bash
cd BuildTools
swift package init
```

3. Add Swifixture as a dependency in `Package.swift`

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "BuildTools", targets: ["BuildTools"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/ruwatana/swifixture.git",
            exact: Version("0.0.1")
        )
    ],
    targets: [
        .target(
            name: "BuildTools",
            dependencies: [
                .product(name: "swifixture", package: "Swifixture")
            ]
        )
    ]
)
```

4. Add a build phase to your target

Open your project in Xcode, select your target, and go to the "Build Phases" tab. Click the "+" button and add a "Run Script" phase. In the script field, add the following command:

```bash
if [ ! -e "${SRCROOT}/BuildTools/.build/release/swifixture" ]; then
    xcrun --sdk macosx swift build -c release --package-path "${SRCROOT}/BuildTools"
fi

"${SRCROOT}/BuildTools/.build/release/swifixture"
```

[NOTE] In Xcode 15 and later, the `User Script Sandboxing` setting must be set to **NO** for this script to work properly.

<img width="451" alt="image" src="https://github.com/user-attachments/assets/d2e3e200-b870-4d0f-97e3-f582a80a0d08">

## 🚀 Usage

Swifixture can be executed from the command line as an executable target. The basic syntax is as follows:

```bash
swift run swifixture [options]
```

### 🔧 Options

| Option                                         | Shorthand | Description                                                                                         |
| ---------------------------------------------- | --------- | --------------------------------------------------------------------------------------------------- |
| `--help`                                       | `-h`      | Show help information.                                                                              |
| `--source <path>`                              | `-s`      | Specify the source file or directory path to search recursively for Swift files. Default is `./`.   |
| `--output <path>`                              | `-o`      | Specify the output file for the generated fixture methods. Default is `./Generated/Fixtures.swift`. |
| `--additional-imports <module1> <module2> ...` |           | Specify additional module names to import. By default, Foundation is imported.                      |
| `--testable-import <module>`                   |           | Specify a module name to testable import. By default, it is not imported.                           |

### 💡 Example

To generate fixture methods for a Swift file located at `./MyStruct.swift` and output the results to `./Generated/Fixtures.swift` by default.

you can run:

```bash
swift run swifixture --source ./MyStruct.swift
```

#### Using fixturable

You can annotate your `struct` with `/// @fixturable` to enable automatic generation of fixture methods.

For example:

```swift
// MyStruct.swift

/// @fixturable
struct User {
    let name: String
    let age: Int
}
```

This will generate fixture methods for the `User` struct on `./Generated/Fixtures.swift`, allowing you to easily create test instances.

```swift
// Generated/Fixtures.swift

///
///  @Generated by Swifixture
///

import Foundation

extension User {
    static func fixture(
        name: String = "name",
        age: Int = 0
    ) -> Self {
        .init(
            name: name,
            age: age
        )
    }
}
```

#### Override Settings for Custom Initial Values

You can also specify custom initial values for properties using the `/// @fixturable(override: key = value)` annotation. For instance, if you have a custom `enum` and want to set a specific value, you can do it like this:

```swift
// MyStruct.swift

enum UserRole {
    case admin
    case user
}

/// @fixturable(override: role = .admin)
struct User {
    let name: String
    let age: Int
    let role: UserRole
}
```

In this example, the `role` property will default to `.admin` when generating fixture methods, allowing for more control over the test data.

#### Example of Generated Output

When you run the Swifixture tool with the above `User` struct, it will generate a file similar to the following:

```swift
// Generated/Fixtures.swift

///
///  @Generated by Swifixture
///

import Foundation

extension User {
    static func fixture(
        name: String = "name",
        age: Int = 0,
        role: UserRole = .admin
    ) -> Self {
        .init(
            name: name,
            age: age,
            role: role
        )
    }
}
```

#### Additional Imports and Testable Import

If you want to include additional imports and a testable import, you can do so like this:

```bash
swift run swifixture \
    --source ./MyStruct.swift \
    --output ./Generated/Fixtures.swift \
    --additional-imports Combine SwiftUI \
    --testable-import MyModule
```

then:

```swift
// Generated/Fixtures.swift

///
///  @Generated by Swifixture
///

import Foundation
import Combine
import SwiftUI

@testable import MyModule

...
```

## 🚧 Work In Progress

Currently, Swifixture only supports auto-generating fixture methods for `struct`.

Additionally, it is limited to our defined primitive types such as `String`, `Int`, `Double`, etc.

If you want to use custom types, consider using override settings or contribute to Swifixture!

## 🤝 Contributing

We welcome contributions to improve Swifixture! Please feel free to submit a pull request or open an issue for any bugs or feature requests.

### Development

Open this project in Xcode and edit the code.

#### Test

We have prepared a xctestplan, so you can run the test in Xcode.

#### Build and Run

You can build and run Swifixture with `swift` command.

We have prepared a test source file in `./Tests/SwifixtureTests/Resources/Source.swift`.

```bash
swift build
swift run swifixture --source ./Tests/SwifixtureTests/Resources/Source.swift
```

## 📄 License

This project is licensed under the Apache License, Version 2.0 - see the [LICENSE](LICENSE) file for details.
