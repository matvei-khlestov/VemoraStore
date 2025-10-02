//
//  EditPhoneViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

final class EditPhoneViewController: BaseEditFieldViewController {
    
    init(
        viewModel: EditPhoneViewModelProtocol,
        phoneFormatter: PhoneFormattingProtocol
    ) {
        super.init(
            viewModel: viewModel,
            fieldKind: .phone,
            navTitle: "Изменить номер телефона",
            phoneFormatter: phoneFormatter 
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
