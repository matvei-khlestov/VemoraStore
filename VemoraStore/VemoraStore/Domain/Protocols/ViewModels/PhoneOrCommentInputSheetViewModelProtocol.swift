//
//  PhoneOrCommentInputSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import Combine

protocol PhoneOrCommentInputSheetViewModelProtocol: AnyObject {
    // MARK: - Kind
    var kind: PhoneOrCommentInputSheetViewModel.Kind { get set }
    
    // Состояние
    var phone: String { get set }
    var comment: String { get set }
    
    // Вычисляемые свойства
    var isPhoneValid: Bool { get }
    
    // Publishers (read-only)
    var kindPublisher: AnyPublisher<PhoneOrCommentInputSheetViewModel.Kind, Never> { get }
    var phonePublisher: AnyPublisher<String, Never> { get }
    
    // Интенты
    func setKind(_ new: PhoneOrCommentInputSheetViewModel.Kind)
    func makeResultIfValid() -> String?
}
