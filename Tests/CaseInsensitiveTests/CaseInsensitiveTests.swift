import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CaseInsensitive
// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CaseInsensitiveMacros)
import CaseInsensitiveMacros

let testMacros: [String: Macro.Type] = [
    "CaseInsensitive": CaseInsensitiveMacro.self,
]
#endif

final class CaseInsensitiveTests: XCTestCase {
    func testMacro() throws {
        #if canImport(CaseInsensitiveMacros)
        assertMacroExpansion(
            """
            @CaseInsensitive
            enum Area: String {
                case tokyo
                case nagoya
            }
            """,
            expandedSource: """
            
            enum Area: String {
                case tokyo
                case nagoya
            
                init?(rawValue: String) {
                    switch rawValue.lowercased() {
                    case "tokyo":
                        self = .tokyo
                    case "nagoya":
                        self = .nagoya
                    default:
                        return nil
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testIf_CaseInsensitiveMacro_DoesWork() throws {
        XCTAssertEqual(Area.Tokyo, Area(rawValue: "tokyo"))
    }
}

@CaseInsensitive
enum Area: String {
    case Tokyo
    case nagoya
}
