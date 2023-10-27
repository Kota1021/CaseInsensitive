import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Implementation of the `CaseInsensitive` macro.
public struct CaseInsensitiveMacro: MemberMacro {
    
    /// Unique identifier for messages related to this macro.
    private static let messageID = MessageID(domain: "CaseInsensitiveMacro", id: "EnumDefaultImplementation")
    
    // MARK: MemberMacro
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Validate that the macro is being applied to a enum declaration
        guard declaration.is(EnumDeclSyntax.self) else {
            throw SimpleDiagnosticMessage(
              message: "Macro `CaseInsensitive` can only be applied to a enum",
              diagnosticID: messageID,
              severity: .error
            )
        }
        
        
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
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
          throw SimpleDiagnosticMessage(
            message: "Macro `CaseInsensitive` can only be applied to a enum",
            diagnosticID: messageID,
            severity: .error
          )
        }
        
        // Check if Enum on which this macro is attached to conforms to RawRepresentable.
        guard checkIfEnumHasRawValue(enumDecl: enumDecl) else { throw throwNoRawValue() }
        
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
    
    public static func checkIfEnumHasRawValue(enumDecl: EnumDeclSyntax) -> Bool {
        guard let inheritanceClause = enumDecl.inheritanceClause else {
            return false
        }
        let inheritedTypes: InheritedTypeListSyntax = inheritanceClause.inheritedTypes
        let inheritedTypeNames: [String] = inheritedTypes.map { inheritedType in
            guard let identifierType = inheritedType.type.as(IdentifierTypeSyntax.self) else {
                preconditionFailure()
            }
            return identifierType.name.text
        }
        let hasRawValue: Bool =
            inheritedTypeNames.contains("String") ||
            inheritedTypeNames.contains("Character") ||
            inheritedTypeNames.contains("Int") ||
            inheritedTypeNames.contains("Float")
        
        return hasRawValue
    }
    
    public static func throwNoRawValue() -> Error {
         SimpleDiagnosticMessage(
          message: "Macro `CaseInsensitive` can only be applied to a enum with RawValue",
          diagnosticID: messageID,
          severity: .error
        )
    }
}

@main
struct CaseInsensitivePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CaseInsensitiveMacro.self
    ]
}

struct SimpleDiagnosticMessage: DiagnosticMessage, Error {
  let message: String
  let diagnosticID: MessageID
  let severity: DiagnosticSeverity
}

extension SimpleDiagnosticMessage: FixItMessage {
  var fixItID: MessageID { diagnosticID }
}

enum CustomError: Error, CustomStringConvertible {
  case message(String)

  var description: String {
    switch self {
    case .message(let text):
      return text
    }
  }
}
