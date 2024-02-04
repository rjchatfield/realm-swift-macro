import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Add extension for `_RealmObjectSchemaDiscoverable` conformance to Realm `Object`s
public struct CompileTimeSchemaMacro: ExtensionMacro {
    public static func expansion(
      of node: AttributeSyntax,
      attachedTo declaration: some DeclGroupSyntax,
      providingExtensionsOf typeSyn: some TypeSyntaxProtocol,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self),
              classDecl.inheritanceClause?.inheritedTypes.isEmpty == false
        else {
            throw DiagnosticsError(diagnostics: [
                CompileTimeSchemaError.notAClass.diagnose(at: node)
            ])
        }

        // Map all `@Persisted` ivars into `Property`s
        let properties = try classDecl.memberBlock.members
            .compactMap { try $0.propertyDetails }
            .map { (name, type, persistedAttr) in
                /*
                 - Source: `@Persisted(...) var foo: Bar`
                 - Output: `RealmSwift.Property(name: "foo", objectType: Self.self, valueType: Bar.self, ...)`

                 Note: The arguments in `@Persisted` must match the order/type/defaults of `Property.init`
                 */
                let expr = ExprSyntax("RealmSwift.Property(name: \(literal: name), objectType: Self.self, valueType: \(raw: type).self)")
                var functionCall = expr.as(FunctionCallExprSyntax.self)!
                if let arguments = persistedAttr.arguments,
                   case let .argumentList(argList) = arguments {
                    var argumentList = Array(functionCall.arguments)
                    argumentList[argumentList.count - 1].trailingComma = ", "
                    argumentList.append(contentsOf: argList)
                    functionCall.arguments = LabeledExprListSyntax(argumentList)
                }
                return functionCall.as(ExprSyntax.self)!
            }

        // Format properties
        let formattedArrayElements = properties
            .map { "\t\t\t\($0.description)," }
            .joined(separator: "\n")

        let extensionDecl = try ExtensionDeclSyntax("""
        extension \(classDecl.name): RealmSwift._RealmObjectSchemaDiscoverable {
            \(raw: classDecl.formattedAccessModifier)static var _realmProperties: [RealmSwift.Property]? {
                guard RealmMacroConstants.compileTimeSchemaIsEnabled else { return nil }
                return [
        \(raw: formattedArrayElements)
                ]
            }
        }
        """)
        return [extensionDecl]
    }
}

// MARK: - Private helpers

private extension ClassDeclSyntax {
    var formattedAccessModifier: String {
        if modifiers.contains(where: { Self.openAndPublicSet.contains($0.name.tokenKind) }) {
            "public "
        } else {
            ""
        }
    }

    private static let openAndPublicSet = Set([TokenKind.keyword(.open), TokenKind.keyword(.public)])
}

private extension MemberBlockItemListSyntax.Element {
    var propertyDetails: (name: String, type: String, attr: AttributeSyntax)? {
        get throws {
            guard let property = decl.as(VariableDeclSyntax.self),
                  property.bindings.count == 1,
                  let binding = property.bindings.first,
                  let persistedAttr = property.attributes.lazy.compactMap(\.attribute).first(where: \.isRealmPersistedPropertyWrapper),
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self)
            else { return nil }
            guard let typeAnnotation = binding.typeAnnotation
            else {
                throw DiagnosticsError(diagnostics: [
                    CompileTimeSchemaError.missingTypeAnnotation.diagnose(at: binding)
                ])
            }
            let name = identifier.identifier.text
            let type = typeAnnotation.type.trimmedDescription
            return (name, type, persistedAttr)
        }
    }
}

private extension AttributeListSyntax.Element {
    var attribute: AttributeSyntax? {
        switch self {
        case .attribute(let attributeSyntax):
            return attributeSyntax
        case .ifConfigDecl:
            return nil
        }
    }
}

private extension AttributeSyntax {
    var isRealmPersistedPropertyWrapper: Bool {
        attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Persisted"
    }
}

// MARK: - Error

private enum CompileTimeSchemaError {
    case notAClass
    case missingTypeAnnotation
}

extension CompileTimeSchemaError: DiagnosticMessage {
    var message: String {
        switch self {
        case .notAClass:
            return "Only works with Object classes"
        case .missingTypeAnnotation:
            return "@CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value"
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID { MessageID(domain: "CompileTimeSchemaError", id: id) }
    var severity: SwiftDiagnostics.DiagnosticSeverity { .error }

    private var id: String {
        switch self {
        case .notAClass: "notAClass"
        case .missingTypeAnnotation: "missingTypeAnnotation"
        }
    }

    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }
}
