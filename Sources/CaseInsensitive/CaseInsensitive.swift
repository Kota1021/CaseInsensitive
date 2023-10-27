/// Generates a member for Enum:
///  - `init?(rawValue: String)`, witch ignores capital or small.
/// Makes Enum conform to Protocol
///  - `CaseIterable` protocol so `.allCases` method can be used
@attached(member, names: named(init))
@attached(extension, conformances: CaseIterable)
public macro CaseInsensitive() = #externalMacro(module: "CaseInsensitiveMacros", type: "CaseInsensitiveMacro")
