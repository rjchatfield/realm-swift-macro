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

// MARK: - Global properties

public enum RealmMacroConstants {
    public static var compileTimeSchemaIsEnabled = true
}
