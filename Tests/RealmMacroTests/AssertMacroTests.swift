import MacroTesting
import RealmMacroMacros
import InlineSnapshotTesting
import RealmMacro
import RealmSwift
import XCTest
import CustomDump
import Realm

final class AssertMacroTests: XCTestCase {
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
            @CompileTimeSchema
            open class FooObject: Object {
                @Persisted(primaryKey: true) var id: String
                @Persisted var name: String
                @Persisted(indexed: true) internal var key: String
                @Persisted public internal(set) var nestedObject: NestedObject?
                @Persisted private var embeddedObjects: List<NestedObject>

                var computed: String { "" }
                func method() {}

                @CompileTimeSchema
                @objc(ObjcNestedObject)
                public class NestedObject: Object {
                    @Persisted(primaryKey: true) var id: String
                    @Persisted var name2: String
                }

                @CompileTimeSchema
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

                    public override class func _customRealmProperties() -> [RLMProperty]? {
                        return [
                            RLMProperty(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
                            RLMProperty(name: "name2", objectType: Self.self, valueType: String.self)
                        ]
                    }
                }
                @objc(ObjcNestedEmbeddedObject)
                private final class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String

                    override class func _customRealmProperties() -> [RLMProperty]? {
                        return [
                            RLMProperty(name: "name3", objectType: Self.self, valueType: String.self)
                        ]
                    }
                }

                open override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
                        RLMProperty(name: "name", objectType: Self.self, valueType: String.self),
                        RLMProperty(name: "key", objectType: Self.self, valueType: String.self, indexed: true),
                        RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
                        RLMProperty(name: "embeddedObjects", objectType: Self.self, valueType: List<NestedObject>.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshot_ImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var optional1: String?
                @Persisted var optional2: String!
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var optional1: String?
                @Persisted var optional2: String!

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "optional1", objectType: Self.self, valueType: String?.self),
                        RLMProperty(name: "optional2", objectType: Self.self, valueType: String?.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExample1() {
        assertMacro {
            """
            @CompileTimeSchema
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

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleDouble() {
        assertMacro {
            """
            @CompileTimeSchema
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

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self)
                    ]
                }
            }
            """
        }
    }
    func testSnapshotNestedExampleDoubleAnnotated() {
        assertMacro {
            """
            @CompileTimeSchema
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @objc(ObjcNestedObject)
                @CompileTimeSchema
                class NestedObject: Object {
                    @Persisted var veryNestedObject: String

                    @objc(ObjcVeryNestedObject)
                    @CompileTimeSchema
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

                        override class func _customRealmProperties() -> [RLMProperty]? {
                            return [
                                RLMProperty(name: "name", objectType: Self.self, valueType: String.self)
                            ]
                        }
                    }

                    override class func _customRealmProperties() -> [RLMProperty]? {
                        return [
                            RLMProperty(name: "veryNestedObject", objectType: Self.self, valueType: String.self)
                        ]
                    }
                }

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotNestedExampleAnnotated() {
        assertMacro {
            """
            @CompileTimeSchema
            class FooObject: Object {
                @Persisted var nestedObject: NestedObject?

                @CompileTimeSchema
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

                    override class func _customRealmProperties() -> [RLMProperty]? {
                        return [
                            RLMProperty(name: "name", objectType: Self.self, valueType: String.self)
                        ]
                    }
                }

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self)
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

                @CompileTimeSchema
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

                    override class func _customRealmProperties() -> [RLMProperty]? {
                        return [
                            RLMProperty(name: "name1", objectType: Self.self, valueType: String.self),
                            RLMProperty(name: "name2", objectType: Self.self, valueType: String.self)
                        ]
                    }
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_String() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = ""
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = ""
                               ┬─────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : String = ""
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : String = ""

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: String.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_BoolFalse() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = false
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = false
                               ┬────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : Bool = false
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Bool = false

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: Bool.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_BoolTrue() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = true
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = true
                               ┬───────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : Bool = true
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Bool = true

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: Bool.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_Int() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = 42
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = 42
                               ┬─────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : Int = 42
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Int = 42

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: Int.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_Double() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = 1.2
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = 1.2
                               ┬──────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : Double = 1.2
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Double = 1.2

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: Double.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_DateInit() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = Date()
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = Date()
                               ┬─────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : Date = Date()
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Date = Date()

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: Date.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_DateInit2() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.init()
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.init()
                               ┬──────────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : Date = Date.init()
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : Date = Date.init()

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: Date.self)
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_DateStaticProperty() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.now
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = Date.now
                               ┬───────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : <#Type Name#> = Date.now
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : <#Type Name#> 

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: <.self)
                    ]
                }= Date.now
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_NestedStaticProperty() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = SomeNameSpace.Nested.value
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = SomeNameSpace.Nested.value
                               ┬─────────────────────────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : <#Type Name#> = SomeNameSpace.Nested.value
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : <#Type Name#> 

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: <.self)
                    ]
                }= SomeNameSpace.Nested.value
            }
            """
        }
    }

    func testSnapshotMissingAnnotation_globalFunction() {
        assertMacro {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = globalFunction()
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value = globalFunction()
                               ┬───────────────────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
                                  ✏️ Add type annotation
            }
            """
        }fixes: {
            """
            @CompileTimeSchema class FooObject: Object {
                @Persisted var value : <#Type Name#> = globalFunction()
            }
            """
        } expansion: {
            """
            class FooObject: Object {
                @Persisted var value : <#Type Name#> 

                override class func _customRealmProperties() -> [RLMProperty]? {
                    return [
                        RLMProperty(name: "value", objectType: Self.self, valueType: <.self)
                    ]
                }= globalFunction()
            }
            """
        }
    }

    func testNotARealmObject() {
        assertMacro {
            """
            @CompileTimeSchema class NotARealmObject {}
            """
        } diagnostics: {
            """
            @CompileTimeSchema class NotARealmObject {}
            ┬────────────────────
            ╰─ 🛑 Only works with Object classes
            """
        }
    }

    func testNotAClass() {
        assertMacro {
            """
            @CompileTimeSchema struct NotAClass {}
            """
        } diagnostics: {
            """
            @CompileTimeSchema struct NotAClass {}
            ┬────────────────────
            ╰─ 🛑 Only works with Object classes
            """
        }
    }
}
