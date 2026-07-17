import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum PresenterStateError: Error, CustomStringConvertible {
    case onlyOnStoredProperty
    case onlyOnVar
    case requiresExplicitType

    var description: String {
        switch self {
        case .onlyOnStoredProperty:
            return "@PresenterState can only be applied to stored properties"
        case .onlyOnVar:
            return "@PresenterState can only be applied to var properties (not let)"
        case .requiresExplicitType:
            return "@PresenterState requires an explicit type annotation"
        }
    }
}

public struct PresenterStateMacro: AccessorMacro, PeerMacro {

    // MARK: - AccessorMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            throw PresenterStateError.onlyOnStoredProperty
        }

        guard let binding = varDecl.bindings.first,
              let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw PresenterStateError.onlyOnStoredProperty
        }

        // Reject let bindings
        if varDecl.bindingSpecifier.tokenKind == .keyword(.let) {
            throw PresenterStateError.onlyOnVar
        }

        let dollarName = "$\(name)"

        let getter: AccessorDeclSyntax = """
        get { \(raw: dollarName) }
        """

        let setter: AccessorDeclSyntax = """
        set { setState { \(raw: dollarName) = newValue } }
        """

        return [getter, setter]
    }

    // MARK: - PeerMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            return []
        }

        guard let binding = varDecl.bindings.first,
              let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            return []
        }

        if varDecl.bindingSpecifier.tokenKind == .keyword(.let) {
            return []
        }

        let dollarName = "$\(name)"
        let methodName = "set\(name.prefix(1).uppercased())\(name.dropFirst())"

        // Extract the type annotation
        let typeStr: String
        if let typeAnnotation = binding.typeAnnotation {
            typeStr = typeAnnotation.type.description.trimmingCharacters(in: .whitespaces)
        } else {
            throw PresenterStateError.requiresExplicitType
        }

        // Extract access modifiers from the original declaration
        let modifiers = varDecl.modifiers
            .filter { modifier in
                let name = modifier.name.text
                return name == "private" || name == "fileprivate" ||
                       name == "internal" || name == "public" || name == "open" ||
                       name == "package"
            }
            .map { $0.description.trimmingCharacters(in: .whitespaces) }

        let modifierStr = modifiers.isEmpty ? "" : modifiers.joined(separator: " ") + " "

        var declarations: [DeclSyntax] = []

        // Generate $propertyName backing storage
        if let accessorBlock = binding.accessorBlock {
            // Has willSet/didSet observers — preserve them on backing storage
            let hasObservers = accessorBlock.accessors.as(AccessorDeclListSyntax.self)?.contains { accessor in
                let kind = accessor.accessorSpecifier.tokenKind
                return kind == .keyword(.willSet) || kind == .keyword(.didSet)
            } ?? false

            if hasObservers {
                let initializerStr = binding.initializer.map { " = \($0.value.description)" } ?? ""
                declarations.append(
                    DeclSyntax(stringLiteral: """
                    \(modifierStr)var \(dollarName): \(typeStr)\(initializerStr) \(accessorBlock.description)
                    """)
                )
            } else {
                let initializerStr = binding.initializer.map { " = \($0.value.description)" } ?? ""
                declarations.append(
                    DeclSyntax(stringLiteral: """
                    \(modifierStr)var \(dollarName): \(typeStr)\(initializerStr)
                    """)
                )
            }
        } else {
            let initializerStr = binding.initializer.map { " = \($0.value.description)" } ?? ""
            declarations.append(
                DeclSyntax(stringLiteral: """
                \(modifierStr)var \(dollarName): \(typeStr)\(initializerStr)
                """)
            )
        }

        // Generate setPropertyName convenience method
        declarations.append(
            DeclSyntax(stringLiteral: """
            \(modifierStr)func \(methodName)(_ newValue: \(typeStr), context: (inout ViewUpdateContext) -> Void = { _ in }, completion: (() -> Void)? = nil) {
                setState(updater: { \(dollarName) = newValue }, context: context, completion: completion)
            }
            """)
        )

        return declarations
    }
}