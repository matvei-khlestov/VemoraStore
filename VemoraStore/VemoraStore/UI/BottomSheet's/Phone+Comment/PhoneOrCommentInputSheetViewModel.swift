//
//  PhoneOrCommentInputSheetViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import Combine

final class PhoneOrCommentInputSheetViewModel: PhoneOrCommentInputSheetViewModelProtocol {

    enum Kind { case phone, comment }

    // Inputs (state)
    @Published var kind: Kind
    @Published var phone: String
    @Published var comment: String

    // Publishers
    var kindPublisher: AnyPublisher<Kind, Never> { $kind.eraseToAnyPublisher() }
    var phonePublisher: AnyPublisher<String, Never> { $phone.eraseToAnyPublisher() }

    // Outputs
    var isPhoneValid: Bool {
        let pattern = #"^\+7\d{10}$"#
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    init(kind: Kind = .phone, initialPhone: String? = nil, initialComment: String? = nil) {
        self.kind = kind
        self.phone = initialPhone?.isEmpty == false ? initialPhone! : "+7"
        self.comment = initialComment ?? ""
    }

    func setKind(_ new: Kind) { kind = new }

    func makeResultIfValid() -> String? {
        switch kind {
        case .phone:
            return isPhoneValid ? phone : nil
        case .comment:
            let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
    }
}
