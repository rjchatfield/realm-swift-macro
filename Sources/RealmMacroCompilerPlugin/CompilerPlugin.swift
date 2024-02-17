import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import _RealmMacroCore

@main
struct RealmMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CompileTimeSchemaMacro.self,
    ]
}

// MARK: -

// Re-expose core implementation
struct CompileTimeSchemaMacro: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        try _RealmMacroCore.CompileTimeSchemaMacro.expansion(of: node, providingMembersOf: declaration, in: context)
    }
}
