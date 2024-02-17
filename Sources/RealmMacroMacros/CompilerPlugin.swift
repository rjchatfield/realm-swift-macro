import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RealmMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CompileTimeSchemaMacro.self,
    ]
}
