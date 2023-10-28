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
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw SimpleDiagnosticMessage(
                message: "Macro `CaseInsensitive` can only be applied to a enum",
                diagnosticID: messageID,
                severity: .error
            )
        }
        
        // Validate that the enum has RawValue of `String` type
        guard checkIfHasStringRawValue(enumDecl) else {
            throw SimpleDiagnosticMessage(
                message: "Macro `CaseInsensitive` can only be applied to a enum with raw value of `String` type",
                diagnosticID: messageID,
                severity: .error
            )
        }
        let initializer = try generateInitForStringRawValue(enumDecl: enumDecl)
        return [initializer.as(DeclSyntax.self)!]
    }
}

extension CaseInsensitiveMacro {
    private static func checkIfHasStringRawValue(_ enumDecl: EnumDeclSyntax) -> Bool {
        guard let inheritanceClause = enumDecl.inheritanceClause else { return false }
        let inheritedTypes: InheritedTypeListSyntax = inheritanceClause.inheritedTypes
        guard let firstInheritedType = inheritedTypes.first else { return false }
        guard let type: TypeSyntax = firstInheritedType.type.as(TypeSyntax.self) else { return false }
        guard "String" == type.trimmed.description else { return false } // RawValue on Enum may also be Int or Float.
        return true
    }
    
    private static func generateInitForStringRawValue(enumDecl: EnumDeclSyntax) throws -> InitializerDeclSyntax {
        let members = enumDecl.memberBlock.members
        let caseDecl = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecl.flatMap { $0.elements }
        
        let initializer =  try InitializerDeclSyntax("init?(rawValue: String)") {
            try SwitchExprSyntax("switch rawValue.lowercased()") {
                for element in elements {
                    SwitchCaseSyntax(
                        """
                        case \"\(raw: "\(element.name)".lowercased())\":
                            self = .\(element.name)
                        """
                    )
                }
                SwitchCaseSyntax("default: return nil")
            }
        }
        return initializer
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
