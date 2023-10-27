import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `CaseInsensitive` macro.
public struct CaseInsensitiveMacro: MemberMacro {
    
    // MARK: MemberMacro
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TODO: Now DeclSyntax is written in string literal, however, should be written with Syntax Node Types.
            let initializer: DeclSyntax =
              """
              init?(rawValue: String) {
                  let area = Area.allCases.first { rawValue.lowercased() == $0.rawValue.lowercased() }
                  guard let area else { return nil }
                  self = area
              }
              """
            return [initializer]
    }
}

extension CaseInsensitiveMacro: ExtensionMacro {
    
    // MARK: Conforms to ExtensionMacro to conform to CaseIterable
    public static func expansion(
         of node: SwiftSyntax.AttributeSyntax,
         attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
         providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
         conformingTo protocols: [SwiftSyntax.TypeSyntax],
         in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        //https://forums.swift.org/t/examples-of-extensionmacro/66717/9
        let caseIterableExtension: DeclSyntax =
              """
              extension \(type.trimmed): CaseIterable {}
              """

        guard let extensionDecl = caseIterableExtension.as(ExtensionDeclSyntax.self) else {
          return []
        }

        return [extensionDecl]
    }
}

@main
struct CaseInsensitivePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CaseInsensitiveMacro.self
    ]
}
