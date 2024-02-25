import SwiftSyntax
import Foundation
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Add method overriding Realm `Object`s `_customRealmProperties()`
public struct CompileTimeSchemaMacro: MemberMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self),
              classDecl.inheritanceClause?.inheritedTypes.isEmpty == false
        else {
            throw DiagnosticsError(diagnostics: [
                CompileTimeSchemaDiagnostic.notAClass.diagnose(at: node)
            ])
        }

        // Map all `@Persisted` ivars into `Property`s
        let properties = try classDecl.memberBlock.members
            .compactMap { try $0.propertyDetails }
            .map { (name, type, persistedAttr) in
                /*
                 - Source: `@Persisted(...) var foo: Bar`
                 - Output: `RLMProperty(name: "foo", objectType: Self.self, valueType: Bar.self, ...)`

                 Note: The arguments in `@Persisted` must match the order/type/defaults of `Property.init`
                 */
                let expr = ExprSyntax("RLMProperty(name: \(literal: name), objectType: Self.self, valueType: \(raw: type).self)")
                var functionCall = expr.as(FunctionCallExprSyntax.self)!
                functionCall.leadingTrivia = .newline
                if let arguments = persistedAttr.arguments,
                   case let .argumentList(argList) = arguments {
                    var argumentList = Array(functionCall.arguments)
                    argumentList[argumentList.count - 1].trailingComma = ", "
                    argumentList.append(contentsOf: argList)
                    functionCall.arguments = LabeledExprListSyntax(argumentList)
                }
                return functionCall.as(ExprSyntax.self)!
            }

        let array = ArrayExprSyntax(
            elements: ArrayElementListSyntax(expressions: properties),
            rightSquare: .rightSquareToken(leadingTrivia: .newline)
        )

        let decl = DeclSyntax("""
        \(raw: classDecl.formattedAccessModifier)override class func _customRealmProperties() -> [RLMProperty]? {
            return \(array)
        }
        """)
        return [decl]
    }
}

// MARK: - Private helpers

private extension ClassDeclSyntax {
    var formattedAccessModifier: String {
        guard var accessModifier = modifiers.first(where: { Self.openAndPublicSet.contains($0.name.tokenKind) })?.trimmed else { return "" }
        accessModifier.trailingTrivia = .space
        return accessModifier.description
    }

    private static let openAndPublicSet = Set(
        [
            TokenKind.keyword(.open),
            TokenKind.keyword(.public),
            TokenKind.keyword(.package),
        ]
    )
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
                    CompileTimeSchemaDiagnostic.missingTypeAnnotation.diagnose(at: binding)
                ])
            }
            var name = identifier.identifier.text
            if name.first == "`" {
                name = name.trimmingCharacters(in: .backtickSet)
            }
            var type = typeAnnotation.type.trimmedDescription
            if type.last == "!" {
                type = type.replacingOccurrences(of: "!", with: "?")
            }
            return (name, type, persistedAttr)
        }
    }
}

private extension CharacterSet {
    static let backtickSet = CharacterSet("`".unicodeScalars)
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

// MARK: - Diagnostic

private enum CompileTimeSchemaDiagnostic {
    case notAClass
    case missingTypeAnnotation
}

extension CompileTimeSchemaDiagnostic: DiagnosticMessage {
    var message: String {
        switch self {
        case .notAClass:
            return "Only works with Object classes"
        case .missingTypeAnnotation:
            return "@CompileTimeSchema requires an explicit type annotation for all @Persisted properties and cannot infer the type from the default value"
        }
    }

    var diagnosticID: MessageID { MessageID(domain: "CompileTimeSchemaError", id: id) }
    var severity: DiagnosticSeverity { .error }

    private var id: String {
        switch self {
        case .notAClass: "notAClass"
        case .missingTypeAnnotation: "missingTypeAnnotation"
        }
    }

    private var fixIt: CompileTimeSchemaFixIt? {
        switch self {
        case .notAClass: nil
        case .missingTypeAnnotation: .addTypeAnnotation
        }
    }

    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(
            node: Syntax(node),
            message: self,
            fixIts: fixIt?.makeFixIts(at: node) ?? []
        )
    }
}

// MARK: - FixIt

private enum CompileTimeSchemaFixIt: FixItMessage {
    case addTypeAnnotation

    var fixItID: MessageID { MessageID(domain: "CompileTimeSchemaFixItMessage", id: id) }

    var message: String {
        switch self {
        case .addTypeAnnotation:
            return "Add type annotation"
        }
    }

    private var id: String {
        switch self {
        case .addTypeAnnotation: "typeAnnotation"
        }
    }

    private func changes(at node: some SyntaxProtocol) -> [FixIt.Change] {
        switch self {
        case .addTypeAnnotation:
            guard var newBinding = node.as(PatternBindingSyntax.self) else { return [] }
            newBinding.typeAnnotation = TypeAnnotationSyntax(
                leadingTrivia: .none,
                colon: .colonToken(
                    leadingTrivia: [],
                    trailingTrivia: [.spaces(1)],
                    presence: SourcePresence.present
                ),
                type: IdentifierTypeSyntax(
                    name: .identifier(newBinding.initialiserValueFixitTypeName)
                ),
                trailingTrivia: .space
            )
            return [
                .replace(
                    oldNode: Syntax(node),
                    newNode: Syntax(newBinding)
                )
            ]
        }
    }

    func makeFixIts(at node: some SyntaxProtocol) -> [FixIt] {
        return [
            FixIt(
                message: self,
                changes: changes(at: node)
            )
        ]
    }
}

private extension PatternBindingSyntax {
    var initialiserValueFixitTypeName: String {
        if let typeValue = initializer?.as(InitializerClauseSyntax.self)?.value {
            if typeValue.is(StringLiteralExprSyntax.self) {
                return "String"
            }
            if typeValue.is(BooleanLiteralExprSyntax.self) {
                return "Bool"
            }
            if typeValue.is(IntegerLiteralExprSyntax.self) {
                return "Int"
            }
            if typeValue.is(FloatLiteralExprSyntax.self) {
                return "Double"
            }
            if let funcCall = typeValue.as(FunctionCallExprSyntax.self) {
                var declRef: DeclReferenceExprSyntax? {
                    // eg `var ivar = Date()`
                    if let ref = funcCall.calledExpression.as(DeclReferenceExprSyntax.self),
                       // Handle `var ivar = globalFunction()`. Assume uppercased first letter is a type.
                       ref.description.first?.isUppercase == true {
                        return ref
                    }
                    // eg `var ivar = Date.init()`
                    if let memberAccessExpr = funcCall.calledExpression.as(MemberAccessExprSyntax.self),
                       let ref = memberAccessExpr.base?.as(DeclReferenceExprSyntax.self),
                       case .keyword(.`init`) = memberAccessExpr.declName.baseName.tokenKind {
                        return ref
                    }
                    return nil
                }
                if case .identifier(let typeName) = declRef?.baseName.tokenKind {
                    return typeName
                }
            }
        }
        return Self.placeholder
    }

    static let placeholder = "<#Type Name#>" // this may produce a debug error, but works fine
}
