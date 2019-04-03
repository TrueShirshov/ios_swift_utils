//
//  Created on 02/10/2018
//  Copyright © Vladimir Benkevich 2018
//

import UIKit

private var appeaarancesSwizzled: Int32 = 0
private var lifecycleDelegatesKey = 1

public extension View {

    func sendViewAppearance(to delegate: ViewLifecycleDelegate) {
        sendViewAppearance(to: delegate, retain: true)
    }
}

extension UIViewController: View {

    var lifecycleDelegates: [LifecycleDelegeteHolder] {
        get { return objc_getAssociatedObject(self, &lifecycleDelegatesKey) as? [LifecycleDelegeteHolder] ?? [] }
        set { objc_setAssociatedObject(self, &lifecycleDelegatesKey, newValue, .OBJC_ASSOCIATION_RETAIN)}
    }

    public static func swizzleViewAppearances() {
        guard OSAtomicCompareAndSwap32(0, 1, &appeaarancesSwizzled) else {
            return
        }

        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(viewWillAppear(_:)))!,
            class_getInstanceMethod(self, #selector(swizzled_viewWillAppear(_:)))!)

        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(viewDidAppear(_:)))!,
            class_getInstanceMethod(self, #selector(swizzled_viewDidAppear(_:)))!)

        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(viewWillDisappear(_:)))!,
            class_getInstanceMethod(self, #selector(swizzled_viewWillDisappear(_:)))!)

        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(viewDidDisappear(_:)))!,
            class_getInstanceMethod(self, #selector(swizzled_viewDidDisappear(_:)))!)
    }

    public func sendViewAppearance(to delegate: ViewLifecycleDelegate, retain: Bool) {
        if !lifecycleDelegates.contains(where: { $0.delegate === delegate }) {
            lifecycleDelegates.append(retain ? Strong(delegate) : Weak(delegate))
        }
    }

    public func remove(_ delegete: ViewLifecycleDelegate) {
        lifecycleDelegates.removeAll(where: { $0.delegate === delegete })
    }

    @objc fileprivate func swizzled_viewWillAppear(_ animated: Bool) {
        lifecycleDelegates = lifecycleDelegates.filter { $0.delegate != nil }

        self.swizzled_viewWillAppear(animated)

        for holder in lifecycleDelegates {
            holder.delegate?.viewWillAppear(animated)
        }
    }

    @objc fileprivate func swizzled_viewDidAppear(_ animated: Bool) {
        self.swizzled_viewDidAppear(animated)

        for holder in lifecycleDelegates {
            holder.delegate?.viewDidAppear(animated)
        }
    }

    @objc fileprivate func swizzled_viewWillDisappear(_ animated: Bool) {
        self.swizzled_viewWillDisappear(animated)

        for holder in lifecycleDelegates {
            holder.delegate?.viewWillDisappear(animated)
        }
    }

    @objc fileprivate func swizzled_viewDidDisappear(_ animated: Bool) {
        lifecycleDelegates = lifecycleDelegates.filter { $0.delegate != nil }

        self.swizzled_viewDidDisappear(animated)

        for holder in lifecycleDelegates {
            holder.delegate?.viewDidDisappear(animated)
        }
    }
}

protocol LifecycleDelegeteHolder {
    var delegate: ViewLifecycleDelegate? { get }
}

private class Strong: LifecycleDelegeteHolder {

    let delegate: ViewLifecycleDelegate?

    init(_ delegate: ViewLifecycleDelegate) {
        self.delegate = delegate
    }
}

private class Weak: LifecycleDelegeteHolder {

    weak var delegate: ViewLifecycleDelegate?

    init(_ delegate: ViewLifecycleDelegate) {
        self.delegate = delegate
    }
}
