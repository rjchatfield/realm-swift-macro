import CustomDump
import InlineSnapshotTesting
import MacroTesting
import Realm
import RealmMacro
import _RealmMacroCore
import RealmSwift
import XCTest

final class SchemaEqualityTests: XCTestCase {
    override class func setUp() {
//        InlineSnapshotTesting.isRecording = true
    }

    func testEquality() throws {
        let macroGeneratedProperties = try XCTUnwrap(RLMFooObject._customRealmProperties())
        let runtimeGeneratedProperties = RLMFooObject._getProperties()
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
            	objectClassName = ObjcRLMNestedObject;
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
            	objectClassName = ObjcRLMNestedObject;
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
            	objectClassName = ObjcRLMNestedObject;
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
            	objectClassName = ObjcRLMNestedObject;
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
        let macroGeneratedProperties = try XCTUnwrap(RLMFooObject.RLMNestedObject._customRealmProperties())
        let runtimeGeneratedProperties = RLMFooObject.RLMNestedObject._getProperties()
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
//        RealmMacro.RealmMacroConstants.compileTimeSchemaIsEnabled = true

        let s1 = RLMSchema.shared()
        assertInlineSnapshot(of: s1, as: .dump) {
            """
            - Schema {
            	ObjcRLMNestedEmbeddedObject (embedded) {
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
            	ObjcRLMNestedObject {
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
            	RLMFooObject {
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
            			objectClassName = ObjcRLMNestedObject;
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
            			objectClassName = ObjcRLMNestedObject;
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
open class RLMFooObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted(indexed: true) internal var key: String
    @Persisted public internal(set) var nestedObject: RLMNestedObject?
    @Persisted private var embeddedObjects: List<RLMNestedObject>

    var computed: String { "" }
    func method() {}

    @CompileTimeSchema
    @objc(ObjcRLMNestedObject)
    public class RLMNestedObject: Object {
        @Persisted(primaryKey: true) var id: String
        @Persisted var name2: String
    }

    @CompileTimeSchema
    @objc(ObjcRLMNestedEmbeddedObject)
    private final class RLMNestedEmbeddedObject: EmbeddedObject {
        @Persisted var name3: String
    }
}
