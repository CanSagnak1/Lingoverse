//
//  SplashInteractor.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 6.11.2025.
//

import Foundation

protocol SplashInteractorInput: AnyObject {
    func checkInternet()
}

protocol SplashInteractorOutput: AnyObject {
    func internetCheckCompleted(isSuccess: Bool)
}

final class SplashInteractor: SplashInteractorInput {
    weak var output: SplashInteractorOutput?

    func checkInternet() {
        let isConnected = Reachability.isConnectedToNetwork()
        output?.internetCheckCompleted(isSuccess: isConnected)
    }
}
