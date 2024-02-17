@attached(
    member,
    names: named(_customRealmProperties)
)
public macro CompileTimeSchema() = #externalMacro(
    module: "RealmMacroMacros",
    type: "CompileTimeSchemaMacro"
)
