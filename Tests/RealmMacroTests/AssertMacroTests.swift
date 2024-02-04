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
                "CompileTimeSchema": CompileTimeSchemaMacro.self,
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
                }
                @objc(ObjcNestedEmbeddedObject)
                private final class NestedEmbeddedObject: EmbeddedObject {
                    @Persisted var name3: String
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RealmSwift.Property(name: "name2", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension NestedEmbeddedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name3", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                public static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "id", objectType: Self.self, valueType: String.self, primaryKey: true),
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
            			RealmSwift.Property(name: "key", objectType: Self.self, valueType: String.self, indexed: true),
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
            			RealmSwift.Property(name: "embeddedObjects", objectType: Self.self, valueType: List<NestedObject>.self),
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
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
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
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
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
                    }
                }
            }

            extension VeryNestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "veryNestedObject", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
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
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name", objectType: Self.self, valueType: String.self),
                    ]
                }
            }

            extension FooObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "nestedObject", objectType: Self.self, valueType: NestedObject?.self),
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
                }
            }

            extension NestedObject: RealmSwift._RealmObjectSchemaDiscoverable {
                static var _realmProperties: [RealmSwift.Property]? {
                    guard RealmMacroConstants.compileTimeSchemaIsEnabled else {
                        return nil
                    }
                    return [
            			RealmSwift.Property(name: "name1", objectType: Self.self, valueType: String.self),
            			RealmSwift.Property(name: "name2", objectType: Self.self, valueType: String.self),
                    ]
                }
            }
            """
        }
    }

    func testSnapshotMissingAnnotation() {
        assertMacro {
            """
            @CompileTimeSchema
            class FooObject: Object {
                @Persisted var value1: String
                @Persisted var value2: String = ""
                @Persisted var value3 = ""
            }
            """
        } diagnostics: {
            """
            @CompileTimeSchema
            class FooObject: Object {
                @Persisted var value1: String
                @Persisted var value2: String = ""
                @Persisted var value3 = ""
                               ┬──────────
                               ╰─ 🛑 @CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value
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
            ┬─────────────────
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
            ┬─────────────────
            ╰─ 🛑 Only works with Object classes
            """
        }
    }
}
