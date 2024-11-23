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
            
            fixturableStructs.append(.init(syntax: node, overrideSettings: overrideSettings))
        }
        
        return .skipChildren
    }
}
