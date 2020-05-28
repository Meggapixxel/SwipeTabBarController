import Foundation

struct SampleReflection {
    
    static func example() {
        let andy = Person(name: "Vadym Zhydenko", age: 24)
        
        let andyMirror = Mirror(reflecting: andy)

        andyMirror.children.forEach { child in
            print("\(child.label ?? "???") = \(child.value)")
        }
    }
    
}

extension SampleReflection {
    
    struct Person {
        let name: String
        let age: Int
    }
    
}
