//
//  EditNameViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

final class EditNameViewController: BaseEditFieldViewController {
    
    init(viewModel: EditNameViewModelProtocol) {
        super.init(
            viewModel: viewModel,
            fieldKind: .name,
            navTitle: "Изменить имя"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
