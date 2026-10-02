import Foundation
import SwiftParser
import SwiftSyntax

final class FixturableStructVisitor: SyntaxVisitor {
    
    /// Regular expression to match `@fixturable` or `@fixtureable` comments.
    /// Ex: `/// @fixturable`
    private let fixturableRegex = try! Regex(#"^///\s?(?:@fixturable|@fixtureable)\s?(\(.*?\))?$"#)
    
    private(set) var fixturableStructs: [FixturableStruct] = []
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let docComment = node.leadingTrivia
            .pieces
            .compactMap { piece in
                if case .docLineComment(let comment) = piece {
                    return comment
                }
                return nil
            }
            .first { $0.contains(fixturableRegex) }

        if let docComment {
            let overrideSettings = parseOverrideSettings(from: docComment)

            var currentNode: Syntax? = node._syntaxNode
            var namespace: String? = nil
            while let parent = currentNode?.parent {
                if let parentName = typeName(of: parent) {
                    namespace = "\(parentName).\(namespace ?? "")"
                }
                currentNode = parent
            }

            fixturableStructs.append(.init(syntax: node, overrideSettings: overrideSettings, namespace: namespace))
        }

        return .visitChildren
    }

    /// Parses override settings from `@fixturable` or `@fixtureable` comments.
    /// Ex: `/// @fixturable(override: key = value, key = value)`
    ///
    /// The arguments are parsed as a Swift tuple expression such as `(override: key = value, key = value)`,
    /// so that any Swift expression (e.g. string literals, negative numbers or initializers) can be used as a value.
    private func parseOverrideSettings(from docComment: String) -> [String: String] {
        guard let argumentsStartIndex = docComment.firstIndex(of: "(") else {
            return [:]
        }

        let sourceFile = Parser.parse(source: String(docComment[argumentsStartIndex...]))
        guard
            let tuple = sourceFile.statements.first?.item.as(TupleExprSyntax.self),
            tuple.elements.first?.label?.text == "override"
        else {
            return [:]
        }

        var overrideSettings: [String: String] = [:]
        for element in tuple.elements {
            // `key = value` is parsed as a sequence expression of `key`, `=` and `value`
            guard
                let sequence = element.expression.as(SequenceExprSyntax.self),
                let key = sequence.elements.first?.as(DeclReferenceExprSyntax.self)?.baseName.text,
                sequence.elements.dropFirst().first?.is(AssignmentExprSyntax.self) == true
            else {
                continue
            }
            let value = sequence.elements
                .dropFirst(2)
                .map(\.description)
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty {
                overrideSettings[key] = value
            }
        }
        return overrideSettings
    }

    /// Returns the name of the type that can contain nested types.
    private func typeName(of node: Syntax) -> String? {
        if let structDecl = node.as(StructDeclSyntax.self) {
            return structDecl.name.text
        } else if let enumDecl = node.as(EnumDeclSyntax.self) {
            return enumDecl.name.text
        } else if let classDecl = node.as(ClassDeclSyntax.self) {
            return classDecl.name.text
        } else if let actorDecl = node.as(ActorDeclSyntax.self) {
            return actorDecl.name.text
        } else if let extensionDecl = node.as(ExtensionDeclSyntax.self) {
            return extensionDecl.extendedType.trimmedDescription
        }
        return nil
    }
}
