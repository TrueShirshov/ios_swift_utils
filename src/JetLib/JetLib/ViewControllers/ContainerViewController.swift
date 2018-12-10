//
//  Created on 29/09/2018
//  Copyright © Vladimir Benkevich 2018
//

import UIKit

public protocol ControllerPresenter: class {

    var currentController: UIViewController? { get set }
}

open class ContainerViewController: UIViewController, ControllerPresenter {

    public var currentController: UIViewController? {
        didSet {
            if isBeingPresented {
                oldValue?.beginAppearanceTransition(false, animated: false)
                currentController?.beginAppearanceTransition(true, animated: false)

                defer {
                    currentController?.endAppearanceTransition()
                    oldValue?.endAppearanceTransition()
                }
            }

            oldValue?.willMove(toParent: nil)

            if let newValue = currentController {
                addChild(newValue)
                newValue.view.frame = view.bounds
                view.addSubview(newValue.view)
            }
            title = currentController?.title
            oldValue?.view.removeFromSuperview()

            oldValue?.removeFromParent()
            currentController?.didMove(toParent: self)
        }
    }
}
