//
//  MapPickerCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

/// Координатор `MapPickerCoordinator` управляет сценарием выбора адреса на карте.
///
/// Отвечает за:
/// - инициализацию `MapPickerViewModel` через `ViewModelBuildingProtocol`;
/// - создание и показ `MapPickerViewController`;
/// - обработку событий выбора полного адреса (`onFullAddressPicked`);
/// - завершение сценария (`onFinish`) и возврат к предыдущему экрану.
///
/// Особенности:
/// - передаёт фабрики для создания зависимых ViewModel (`AddressConfirmSheetViewModel`, `DeliveryDetailsViewModel`);
/// - скрывает нижний таббар при переходе;
/// - изолирует навигационную логику от View и ViewModel.

final class MapPickerCoordinator: MapPickerCoordinatingProtocol {
    
    // MARK: - Callbacks
    
    var onFinish: (() -> Void)?
    var onFullAddressPicked: ((String) -> Void)?
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let viewModelFactory: ViewModelBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Start
    
    func start() {
        let mapVM = viewModelFactory.makeMapPickerViewModel()
        
        let vc = MapPickerViewController(
            viewModel: mapVM,
            makeAddressConfirmVM: { [viewModelFactory] in
                viewModelFactory.makeAddressConfirmSheetViewModel()
            },
            makeDeliveryDetailsVM: { [viewModelFactory] base in
                viewModelFactory.makeDeliveryDetailsViewModel(baseAddress: base)
            }
        )
        
        vc.onAddressComposed = { [weak self] fullAddress in
            guard let self else { return }
            self.onFullAddressPicked?(fullAddress)
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }
        
        vc.onBack = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }
        
        navigation.pushViewController(vc, animated: true)
    }
}
