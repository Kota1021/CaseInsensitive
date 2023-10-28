/// Generates a member for Enum:
///  - `init?(rawValue: String)`, witch ignores capital or small.
@attached(member, names: named(init))
public macro CaseInsensitive() = #externalMacro(module: "CaseInsensitiveMacros", type: "CaseInsensitiveMacro")
