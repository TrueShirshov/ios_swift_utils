//
//  Created on 05/03/2019
//  Copyright © Vladimir Benkevich 2019
//

import Foundation
import LocalAuthentication
import JetLib

public class DeviceOwnerLock {

    public enum AuthType {
        case faceID
        case touchID
        case unknown
        case none
    }

    private let storage: KeyChainStorage
    private let context = LAContext()

    public init(storage: KeyChainStorage) {
        self.storage = storage
    }

    public var type: AuthType {
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .LABiometryNone:   return .none
            case .faceID:           return .faceID
            case .touchID:          return .touchID
            default:                return .unknown
            }
        } else {
            var error: NSError?
            return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) ? .touchID : .none
        }
    }

    public func getCode() -> Task<String> {
        return checkDeviceOwnerAuth().map { [storage] in
            return try storage.value(forKey: UserDefaults.Key.pincodeKey)
        }
    }

    public func checkDeviceOwnerAuth() -> Task<Void> {
        let taskSource = Task<Void>.Source()

        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: JetPincodeConfiguration.Strings.touchIdReason)
        {
            if let error = $1 {
                try? taskSource.error(Exception(nil, error))
            } else if $0 {
                try? taskSource.complete()
            } else {
                try? taskSource.error(Exception(JetPincodeConfiguration.Strings.notRecognized))
            }
        }

        return taskSource.task
    }
}
