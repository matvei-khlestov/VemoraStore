//
//  EditEmailViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

final class EditEmailViewController: BaseEditFieldViewController {
    
    init(viewModel: EditEmailViewModelProtocol) {
        super.init(
            viewModel: viewModel,
            fieldKind: .email,
            navTitle: "Изменить почту"
        )
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
