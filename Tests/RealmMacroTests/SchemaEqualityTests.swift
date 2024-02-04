import MacroTesting
import RealmMacroMacros
import InlineSnapshotTesting
import RealmMacro
import RealmSwift
import XCTest
import CustomDump
import Realm

final class SchemaEqualityTests: XCTestCase {
    override class func setUp() {
//        InlineSnapshotTesting.isRecording = true
    }

    func testEquality() throws {
        RealmMacro.RealmMacroConstants.compileTimeSchemaIsEnabled = true

        let macroGeneratedProperties = try XCTUnwrap(FooObject._realmProperties).map(ObjectiveCSupport.convert(object:))
        let runtimeGeneratedProperties = FooObject._getProperties()
        XCTAssertNoDifference(macroGeneratedProperties, runtimeGeneratedProperties)
        assertInlineSnapshot(of: macroGeneratedProperties, as: .dump) {
            """
            ▿ 5 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name {
            	type = string;
            	columnName = name;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - key {
            	type = string;
            	columnName = key;
            	indexed = YES;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - nestedObject {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = nestedObject;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = YES;
            }
              - embeddedObjects {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = embeddedObjects;
            	indexed = NO;
            	isPrimary = NO;
            	array = YES;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
        assertInlineSnapshot(of: runtimeGeneratedProperties, as: .dump) {
            """
            ▿ 5 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name {
            	type = string;
            	columnName = name;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - key {
            	type = string;
            	columnName = key;
            	indexed = YES;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - nestedObject {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = nestedObject;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = YES;
            }
              - embeddedObjects {
            	type = object;
            	objectClassName = ObjcNestedObject;
            	linkOriginPropertyName = (null);
            	columnName = embeddedObjects;
            	indexed = NO;
            	isPrimary = NO;
            	array = YES;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
    }

    func testEqualityNested() throws {
        RealmMacro.RealmMacroConstants.compileTimeSchemaIsEnabled = true

        let macroGeneratedProperties = try XCTUnwrap(FooObject.NestedObject._realmProperties).map(ObjectiveCSupport.convert(object:))
        let runtimeGeneratedProperties = FooObject.NestedObject._getProperties()
        XCTAssertNoDifference(macroGeneratedProperties, runtimeGeneratedProperties)
        assertInlineSnapshot(of: macroGeneratedProperties, as: .dump) {
            """
            ▿ 2 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name2 {
            	type = string;
            	columnName = name2;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
        assertInlineSnapshot(of: runtimeGeneratedProperties, as: .dump) {
            """
            ▿ 2 elements
              - id {
            	type = string;
            	columnName = id;
            	indexed = YES;
            	isPrimary = YES;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }
              - name2 {
            	type = string;
            	columnName = name2;
            	indexed = NO;
            	isPrimary = NO;
            	array = NO;
            	set = NO;
            	dictionary = NO;
            	optional = NO;
            }

            """
        }
    }

    func testDebugSchema() {
        // Toggle this true/false between test runs the ensure snapshots are identical
        RealmMacro.RealmMacroConstants.compileTimeSchemaIsEnabled = true

        let s1 = RLMSchema.shared()
        assertInlineSnapshot(of: s1, as: .dump) {
            """
            - Schema {
            	FooObject {
            		id {
            			type = string;
            			columnName = id;
            			indexed = YES;
            			isPrimary = YES;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		name {
            			type = string;
            			columnName = name;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		key {
            			type = string;
            			columnName = key;
            			indexed = YES;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		nestedObject {
            			type = object;
            			objectClassName = ObjcNestedObject;
            			linkOriginPropertyName = (null);
            			columnName = nestedObject;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = YES;
            		}
            		embeddedObjects {
            			type = object;
            			objectClassName = ObjcNestedObject;
            			linkOriginPropertyName = (null);
            			columnName = embeddedObjects;
            			indexed = NO;
            			isPrimary = NO;
            			array = YES;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            	}
            	ObjcNestedEmbeddedObject (embedded) {
            		name3 {
            			type = string;
            			columnName = name3;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            	}
            	ObjcNestedObject {
            		id {
            			type = string;
            			columnName = id;
            			indexed = YES;
            			isPrimary = YES;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            		name2 {
            			type = string;
            			columnName = name2;
            			indexed = NO;
            			isPrimary = NO;
            			array = NO;
            			set = NO;
            			dictionary = NO;
            			optional = NO;
            		}
            	}
            }

            """
        }
    }
}

// MARK: -

/*
 Example object that ensures all generated code is valid
 */
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
