import RealmSwift

// MARK: - Macros

@attached(
    extension,
    conformances: RealmSwift._RealmObjectSchemaDiscoverable,
    names: named(_realmProperties)
)
public macro CompileTimeSchema() = #externalMacro(
    module: "RealmMacroMacros",
    type: "CompileTimeSchemaMacro"
)

@attached(
    member,
    names: named(_customRealmProperties)
)
public macro RLMCompileTimeSchema() = #externalMacro(
    module: "RealmMacroMacros",
    type: "RLMCompileTimeSchemaMacro"
)

// MARK: - Global properties

public enum RealmMacroConstants {
    public static var compileTimeSchemaIsEnabled = true
}
