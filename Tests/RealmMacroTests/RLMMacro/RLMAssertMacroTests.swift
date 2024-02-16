import MacroTesting
import RealmMacroMacros
import InlineSnapshotTesting
import RealmMacro
import RealmSwift
import XCTest
import CustomDump
import Realm

final class RLMAssertMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
//            isRecording: true,
            macros: [
                "RLMCompileTimeSchema": RLMCompileTimeSchemaMacro.self,
            ]
        ) {
            super.invokeTest()
        }
    }

    func testSnapshot() {
        assertMacro {
            """
            @RLMCompileTimeSchema
            open class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) internal var key: String
                @Persisted public internal(set) var nestedObject: NestedObject?
                @Persisted private var embeddedObjects: List<NestedObject>

                var computed: String { "" }
                func method() {}

                @RLMCompileTimeSchema
                @objc(ObjcNestedObject)
                public class NestedObject: Object {
                    @Persisted(primaryKey: true) var id: String
                    @Persisted var name2: String
                }

                @RLMCompileTimeSchema
                @objc(ObjcNestedEmbeddedObject)
                private final class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String
                }
            }
            """
        } expansion: {
            """
            open class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) internal var key: String
                @Persisted public internal(set) var nestedObject: NestedObject?
                @Persisted private var embeddedObjects: List<NestedObject>

                var computed: String { "" }
                func method() {}
                @objc(ObjcNestedObject)
                public class NestedObject: Object {
                    @Persisted(primaryKey: true) var id: String
                    @Persisted var name2: String
                }
                @objc(ObjcNestedEmbeddedObject)
                private final class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String
                }
            }

            extension NestedObject {
                public override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RLMProperty(name: "name2", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension NestedEmbeddedObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "name3", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject {
                open override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RLMProperty(name: "name", objectType: Self.self, valueType: String.self),
            			RLMProperty(name: "key", objectType: Self.self, valueType: String.self, indexed: true),
            			RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
            			RLMProperty(name: "embeddedObjects", objectType: Self.self, valueType: List<NestedObject>.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExample1() {
        assertMacro {
            """
            @RLMCompileTimeSchema
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleDouble() {
        assertMacro {
            """
            @RLMCompileTimeSchema
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }
    func testSnapshotNestedExampleDoubleAnnotated() {
        assertMacro {
            """
            @RLMCompileTimeSchema
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                @RLMCompileTimeSchema
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    @RLMCompileTimeSchema
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    class VeryNestedObject: Object {
                        @Persisted var name: String
                    }
                }
            }

            extension VeryNestedObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension NestedObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "veryNestedObject", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleAnnotated() {
        assertMacro {
            """
            @RLMCompileTimeSchema
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @RLMCompileTimeSchema
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name: String
                }
            }

            extension NestedObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleBaseNotAnnotated() {
        assertMacro {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @RLMCompileTimeSchema
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name1: String
                    @Persisted var name2: String
                }
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?
                @objc(ObjcNestedObject)
                class NestedObject: Object {
                    @Persisted var name1: String
                    @Persisted var name2: String
                }
            }

            extension NestedObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "name1", objectType: Self.self, valueType: String.self),
            			RLMProperty(name: "name2", objectType: Self.self, valueType: String.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_String() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = ""
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = ""
                               ┬─────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : String = ""
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : String = ""
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: String.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_BoolFalse() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = false
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = false
                               ┬────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : Bool = false
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Bool = false
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: Bool.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_BoolTrue() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = true
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = true
                               ┬───────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : Bool = true
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Bool = true
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: Bool.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_Int() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = 42
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = 42
                               ┬─────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : Int = 42
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Int = 42
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: Int.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_Double() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = 1.2
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = 1.2
                               ┬──────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : Double = 1.2
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Double = 1.2
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: Double.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_DateInit() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = Date()
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = Date()
                               ┬─────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : Date = Date()
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Date = Date()
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: Date.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_DateInit2() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.init()
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.init()
                               ┬──────────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : Date = Date.init()
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Date = Date.init()
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: Date.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_DateStaticProperty() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.now
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.now
                               ┬───────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : <#Type Name#> = Date.now
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : <#Type Name#> = Date.now
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: <.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_NestedStaticProperty() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = SomeNameSpace.Nested.value
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = SomeNameSpace.Nested.value
                               ┬─────────────────────────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : <#Type Name#> = SomeNameSpace.Nested.value
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : <#Type Name#> = SomeNameSpace.Nested.value
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: <.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_globalFunction() {
        assertMacro {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = globalFunction()
            }
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value = globalFunction()
                               ┬───────────────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @RLMCompileTimeSchema class FooObject: Object {
                @Persisted var value : <#Type Name#> = globalFunction()
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : <#Type Name#> = globalFunction()
            }

            extension FooObject {
                override class func _customRealmProperties() -> [RLMProperty]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RLMProperty(name: "value", objectType: Self.self, valueType: <.self),
                    ]
                }
            }
            """
        }
    }

    func testNotARealmObject() {
        assertMacro {
            """
            @RLMCompileTimeSchema class NotARealmObject {}
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema class NotARealmObject {}
            ┬────────────────────
            ╰─ 🛑 Only works with Object classes
            """
        }
    }

    func testNotAClass() {
        assertMacro {
            """
            @RLMCompileTimeSchema struct NotAClass {}
            """
        } diagnostics: {
            """
            @RLMCompileTimeSchema struct NotAClass {}
            ┬────────────────────
            ╰─ 🛑 Only works with Object classes
            """
        }
    }
}
