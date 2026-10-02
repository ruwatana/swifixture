import SwiftSyntax

final class FixturableStructVisitor: SyntaxVisitor {
    
    /// Regular expression to match `@fixturable` or `@fixtureable` comments.
    /// Ex: `/// @fixturable`
    private let fixturableRegex = try! Regex(#"^///\s?(?:@fixturable|@fixtureable)\s?(\(.*?\))?$"#)
    
    /// Regular expression to match `@fixturable` or `@fixtureable` comments with override settings.
    /// Ex: `/// @fixturable (override: key = value, key = value)`
    private let overrideRegex = try! Regex(#"\(override:\s*((?:\w+\s*=\s*[\.\w\(\)\s]+(?:,\s*)?)*)\)"#)
    private let overridePairRegex = try! Regex(#"\s*(\w+)\s*=\s*([\(\)\.\w\s]+)\s*[\),]"#)
    
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
            var overrideSettings: [String: String] = [:]
            for match in docComment.matches(of: overrideRegex) {
                match.0.matches(of: overridePairRegex).forEach { pair in
                    if pair.count >= 3, let key = pair[1].value, let value = pair[2].value {
                        overrideSettings["\(key)"] = "\(value)"
                    }
                }
            }

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
