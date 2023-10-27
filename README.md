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
enum Area {
  case tokyo
  case nagoya
  
  init?(rawValue: String) {
    let area = Area.allCases.first {
        rawValue.lowercased() == $0.rawValue.lowercased()
    }
    guard let area else {
        return nil
    }
    self = area
  }
}
  
extension Area: CaseIterable {}
```
