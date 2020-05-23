import Foundation

protocol P_ClosureSelector: NSObject {
    var selector: Selector { get }
}

final class ClosureSelector: NSObject, P_ClosureSelector {

    private let action: () -> Void

    var selector: Selector { #selector(trigger) }
    
    init(action: @escaping () -> Void) {
        self.action = action
        super.init()
    }

    @objc private func trigger() {
        action()
    }

}

final class ClosureSelectorData<T>: NSObject, P_ClosureSelector {

    private let action: (T) -> Void
    private let item: T

    var selector: Selector { #selector(trigger) }
    
    init(item: T, action: @escaping (T) -> Void) {
        self.action = action
        self.item = item
        super.init()
    }

    @objc private func trigger() {
        action(item)
    }

}
