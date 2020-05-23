import Foundation

struct Reflection {
    
    static func example() {
        let andy = Person(name: "Vadym Zhydenko", age: 24)
        
        let andyMirror = Mirror(reflecting: andy)

        andyMirror.children.forEach { child in
            print("\(child.label) = \(child.value)")
        }
    }
    
}

extension Reflection {
    
    struct Person {
        let name: String
        let age: Int
    }
    
}
