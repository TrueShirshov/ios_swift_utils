//
//  Created by Vladimir Benkevich on 08/01/2019.
//  Copyright © Vladimir Benkevich 2019
//

import Foundation
import UIKit

extension PinpadWidget {

    class PincodeView: UIStackView {

        var count: Int = 0

        var configuration: PinpadWidgetConfiguration!

        var filledViews: [UIView] = [] {
            didSet {
                for view in oldValue {
                    removeArrangedSubview(view)
                }
                for (index, view) in filledViews.enumerated() {
                    addArrangedSubview(view)
                    view.isHidden = index >= pincode.count
                }
            }
        }

        var emptyViews: [UIView] = [] {
            didSet {
                for view in oldValue {
                    removeArrangedSubview(view)
                }
                for (index, view) in emptyViews.enumerated() {
                    addArrangedSubview(view)
                    view.isHidden = index < pincode.count
                }
            }
        }

        convenience init(configuration: PinpadWidgetConfiguration) {
            self.init(arrangedSubviews: [])
            self.configuration = configuration
            self.axis = .horizontal
            self.distribution = .fillEqually
        }

        var pincode: String = "" {
            didSet {
                for index in 0..<emptyViews.count {
                    emptyViews[index].isHidden = index < pincode.count
                    filledViews[index].isHidden = index >= pincode.count
                }
            }
        }

        func setup(symbolsCount: UInt8?) {
            guard let count = symbolsCount else { return }

            spacing = configuration.horizontalSpacing
            filledViews = (0..<count).map { _ in configuration.createFilledDot() }
            emptyViews = (0..<count).map { _ in configuration.createEmptyDot() }
        }
    }
}
