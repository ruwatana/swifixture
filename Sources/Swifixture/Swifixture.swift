import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

struct Swifixture: ParsableCommand {

    @Option(
        name: .shortAndLong,
        help: "Specify source file or directory path to search recursively for Swift files."
    )
    private var source: String = "./"

    @Option(
        name: .shortAndLong,
        help: "Output file for the generated fixture methods."
    )
    private var output: String = "./Generated/Fixtures.swift"
    
    @Option(
        name: .customLong("additional-imports"),
        parsing: .upToNextOption,
        help: "Additional module names to import. By default, Foundation is imported."
    )
    private var additionalImports: [String] = []
    
    @Option(
        name: .customLong("testable-import"),
        help: "Module name to testable import. By default, not imported."
    )
    private var testableImport: String?

    func run() throws {
        let sourceURL = URL(fileURLWithPath: source)
        let outputURL = URL(fileURLWithPath: output)

        let fixtureString = retrieveSwiftFileURLs(in: sourceURL)
            .compactMap(readSourceCode)
            .map(Parser.parse)
            .flatMap(retrieveFixturableStructs)
            .map(buildFixtureExtensionSourceCode)
            .sorted()
            .joined(separator: "\n\n")
        
        let body = buildBody(fixtureString: fixtureString)

        try writeToOutput(body: body, to: outputURL)
    }

    private func retrieveSwiftFileURLs(in sourceURL: URL) -> [URL] {
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            print("⚠️ File not found at \(sourceURL.path)")
            return []
        }

        if sourceURL.pathExtension == "swift" {
            return [sourceURL]
        }

        guard sourceURL.hasDirectoryPath else {
            print("⚠️ Invalid directory path: \(sourceURL.path)")
            return []
        }

        var swiftFiles: [URL] = []
        let enumerator = FileManager.default.enumerator(
            at: sourceURL,
            includingPropertiesForKeys: nil
        )
        while let file = enumerator?.nextObject() as? URL {
            if file.pathExtension == "swift" {
                swiftFiles.append(file)
            }
        }

        return swiftFiles
    }
    
    private func readSourceCode(from fileURL: URL) -> String? {
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("⚠️ Failed to read file at \(fileURL.path): \(error)")
            return nil
        }
    }
    
    private func retrieveFixturableStructs(from sourceFile: SourceFileSyntax) -> [FixturableStruct] {
        let visitor = FixturableStructVisitor(viewMode: .all)
        visitor.walk(sourceFile)
        return visitor.fixturableStructs
    }
    
    private func buildFixtureExtensionSourceCode(for fixturableStruct: FixturableStruct) -> String {
        let structName = fixturableStruct.syntax.name.text
        let properties: [(name: String, type: TypeSyntax)] = fixturableStruct.syntax.memberBlock
            .members
            .compactMap { member in
                guard
                    let variable = member.decl.as(VariableDeclSyntax.self),
                    let firstBinding = variable.bindings.first,
                    let name = firstBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                    let type = firstBinding.typeAnnotation?.type,
                    firstBinding.initializer == nil
                else {
                    return nil
                }
                return (name, type)
            }
        
        var sourceCode = "extension \(structName) {\n"
        sourceCode += "    static func fixture("
        
        let parameters = properties
            .map { (name, type) in
                let typeDescription = typeDescription(for: type)
                if let overrideValue = fixturableStruct.overrideSettings["\(name)"] {
                    return "        \(name): \(typeDescription) = \(overrideValue)"
                }
                return "        \(name): \(typeDescription) = \(defaultValue(for: type, name: name))"
            }
            .joined(separator: ",\n")
        if !parameters.isEmpty {
            sourceCode += "\n"
            sourceCode += parameters
            sourceCode += "\n    "
        }
        
        sourceCode += ") -> Self {\n"
        sourceCode += "        .init("
        
        let assignments = properties
            .map { "            \($0.name): \($0.name)" }
            .joined(separator: ",\n")
        if !assignments.isEmpty {
            sourceCode += "\n"
            sourceCode += assignments
            sourceCode += "\n        "
        }
        
        sourceCode += ")\n"
        sourceCode += "    }\n"
        sourceCode += "}\n"
        
        return sourceCode
    }
    
    private func typeDescription(for type: TypeSyntax) -> String {
        if let functionType = type.as(FunctionTypeSyntax.self) {
            return attachEscapingAttribute(for: functionType)
        }
        
        if let attributedType = type.as(AttributedTypeSyntax.self),
           let baseType = attributedType.baseType.as(FunctionTypeSyntax.self),
           !attributedType.attributes.contains(where: { $0.description == "@escaping" }) {
            let attributes = attributedType.attributes
                .map { $0.trimmedDescription }
                .joined(separator: " ")
            return "\(attributes) \(attachEscapingAttribute(for: baseType))"
        }
        
        return type.description
    }
    
    private func attachEscapingAttribute(for type: FunctionTypeSyntax) -> String {
        "@escaping \(type.description)"
    }
    
    private func defaultValue(for type: TypeSyntax, name: String) -> String {
        if type.is(OptionalTypeSyntax.self) {
            return "nil"
        } else if let iuoType = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return defaultValue(for: iuoType.wrappedType, name: name)
        } else if type.is(ArrayTypeSyntax.self) {
            return "[]"
        } else if type.is(DictionaryTypeSyntax.self) {
            return "[:]"
        } else if let tupleType = type.as(TupleTypeSyntax.self) {
            let tuple = tupleType.elements
                .enumerated()
                .map { (index, element) in
                    if let label = element.firstName {
                        return "\(label): \(defaultValue(for: element.type, name: label.text))"
                    }
                    return defaultValue(for: element.type, name: "\(index)")
                }
                .joined(separator: ", ")
            return "(\(tuple))"
        } else if let functionType = type.as(FunctionTypeSyntax.self) {
            var value = "{"
            
            let parameters = functionType.parameters.map { _ in "_" }.joined(separator: ", ")
            if !parameters.isEmpty {
                value += " \(parameters) in"
            }
            
            if ["Void", "()"].contains(functionType.returnClause.type.description) {
                value += " }"
            } else {
                let returnValue = defaultValue(for: functionType.returnClause.type, name: "")
                value += " \(returnValue) }"
            }
            
            return value
        } else if let attributedType = type.as(AttributedTypeSyntax.self) {
            return defaultValue(for: attributedType.baseType, name: name)
        } else if let identifierType = type.as(IdentifierTypeSyntax.self),
                  let defaultValue = defaultValue(for: identifierType, name: name) {
            return defaultValue
        }
        
        return ".fixture()"
    }
    
    private func defaultValue(for identifierType: IdentifierTypeSyntax, name: String) -> String? {
        switch identifierType.name.text {
        case String(describing: Any.self):
            return "0"
        case String(describing: AnyObject.self):
            return "0 as AnyObject"
        case String(describing: Bool.self):
            return "false"
        case String(describing: Character.self):
            return "\"\(name.first ?? "a")\""
        case String(describing: Data.self):
            return ".init()"
        case String(describing: Date.self):
            return ".init()"
        case String(describing: Double.self):
            return "0.0"
        case String(describing: Error.self):
            return "NSError(domain: \"\(name)\", code: 0, userInfo: [:])"
        case String(describing: Float.self):
            return "0.0"
        case String(describing: Int.self):
            return "0"
        case String(describing: Int8.self):
            return "0"
        case String(describing: Int16.self):
            return "0"
        case String(describing: Int32.self):
            return "0"
        case String(describing: Int64.self):
            return "0"
        case String(describing: Set<AnyHashable>.self).components(separatedBy: "<").first!:  // "Set"
            return "[]"
        case String(describing: String.self):
            return "\"\(name)\""
        case "TimeInterval": // String(describing: TimeInterval.self) returns an entity of typealias
            return "0.0"
        case String(describing: UInt.self):
            return "0"
        case String(describing: UInt8.self):
            return "0"
        case String(describing: UInt16.self):
            return "0"
        case String(describing: UInt32.self):
            return "0"
        case String(describing: UInt64.self):
            return "0"
        case String(describing: URL.self):
            return ".init(string: \"http://localhost\")!"
        case String(describing: UUID.self):
            return ".init()"
        default:
            return nil
        }
    }
    
    private func buildBody(fixtureString: String) -> String {
        var body = """
        ///
        ///  @Generated by Swifixture
        ///
        
        import Foundation
        
        """
        
        additionalImports.forEach { body += "import \($0)\n" }
        
        if let testableImport {
            body += "\n@testable import \(testableImport)\n"
        }
        
        body += "\n\n\(fixtureString)"
        
        return body
    }
    
    private func writeToOutput(body: String, to outputURL: URL) throws {
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        try body.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}
