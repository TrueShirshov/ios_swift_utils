//
//  Created on 05/03/2019
//  Copyright © Vladimir Benkevich 2019
//

import Foundation

open class JetPincode {

    public static var shared: JetPincode = JetPincode(configuration: JetPincodeConfiguration(), viewFactory: PinpadViewFactoryDefault())

    public init(configuration: JetPincodeConfiguration, viewFactory: PinpadViewFactory) {
        self.viewFactory = viewFactory

        let keyChainStorage = KeyChainStorage(serviceName: "JetLib.JetPincode")
        pincodeStorage = PincodeStorage(storage: keyChainStorage)

        let uiCodeProvider = PincodeUIPresenter(pincodeStorage: pincodeStorage,
                                                viewFactory: viewFactory,
                                                configuration: configuration)

        self.configuration = configuration
        self.dataStorage = CodeProtectedStorage(origin: keyChainStorage.async(),
                                                validator: pincodeStorage,
                                                codeProvider: uiCodeProvider,
                                                configuration: configuration)
    }

    private let pincodeStorage: PincodeStorage

    public let dataStorage: CodeProtectedStorage

    public let configuration: JetPincodeConfiguration

    public let viewFactory: PinpadViewFactory

    public func setPincode(code: String) throws {
        dataStorage.codeLocker.unlock()
        try pincodeStorage.setPincode(code: code)
    }

    public func deletePincode() throws {
        dataStorage.codeLocker.invalidate()
        try pincodeStorage.deletePincode()
    }
}

public extension JetPincode {

    @discardableResult
    func value<T: Codable>(forKey defaultName: UserDefaults.Key) -> Task<T> {
        return dataStorage.value(forKey: defaultName)
    }

    @discardableResult
    func set<T: Codable>(_ value: T, forKey defaultName: UserDefaults.Key) -> Task<Void> {
        return dataStorage.set(value, forKey: defaultName)
    }

    @discardableResult
    func delete(key defaultName: UserDefaults.Key) -> Task<Void> {
        return dataStorage.delete(key: defaultName)
    }

    func invalidate() {
        dataStorage.invalidate()
    }
}
