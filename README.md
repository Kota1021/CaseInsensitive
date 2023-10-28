# CaseInsensitive
An attached macro that makes an Enum have `init?(rawValue: String)` which ignores capital or small letters.

# Usage

``` swift
import CaseInsensitive
import Foundation

@CaseInsensitive
enum Area: String {
    case tokyo
    case nagoya
    
}

Area.tokyo == Area(rawValue: "Tokyo") // true

```

# Expanded

``` swift
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
```
