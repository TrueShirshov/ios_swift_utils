//
//  Created on 02/10/2018
//  Copyright © Vladimir Benkevich 2018
//

import Foundation

public protocol UpdateInitiator: class {

    func updateStarted()

    func updateCompleted()

    func updateAborted()
}

public protocol Updatable {

    func dataUpdateRequested(initiator: UpdateInitiator)
}

public extension ViewModel {

    func reload(force: Bool = false) {
        guard force else {
            self.dataUpdateRequested(initiator: self)
            return
        }

        cancelAll().notify(queue: DispatchQueue.main) {
            self.dataUpdateRequested(initiator: self)
        }
    }
}

extension ViewModel: UpdateInitiator {

    @objc
    open func updateAborted() {
    }

    @objc
    open func updateStarted() {
    }

    @objc
    open func updateCompleted() {
    }
}

extension ViewModel: Updatable {

    public func dataUpdateRequested(initiator: UpdateInitiator) {
        guard canLoadData else {
            initiator.updateAborted()
            return
        }

        initiator.updateStarted()

        self.loadData().notify(DispatchQueue.main) { _ in
            initiator.updateCompleted()
        }
    }
}
