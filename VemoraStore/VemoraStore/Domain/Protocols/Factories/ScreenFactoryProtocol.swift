//
//  ScreenFactoryProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import UIKit

protocol ScreenFactoryProtocol {
    func makeSignInViewController() -> UIViewController
    func makeSignUpViewController() -> UIViewController
    func makeProfileUserViewController(userId: String) -> UIViewController
    func makeEditProfileViewController(userId: String) -> UIViewController
    func makeEditNameViewController(userId: String) -> UIViewController
    func makeEditEmailViewController(userId: String) -> UIViewController
    func makeEditPhoneViewController(userId: String) -> UIViewController
}
