//
//  MapPickerViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit

/// Протокол ViewModel для экрана выбора локации на карте.
///
/// Отвечает за:
/// - обработку событий карты (изменение региона, масштабирование, перемещение);
/// - управление геолокацией пользователя и статусами авторизации;
/// - центрирование карты при нажатии «Моё местоположение»;
/// - отображение и обновление адреса в нижнем листе.
///
/// ViewModel взаимодействует с контроллером через callbacks, обеспечивая реактивную логику отображения.

protocol MapPickerViewModelProtocol: AnyObject {
    
    // MARK: - Inputs (from ViewController)
    
    /// Устанавливает состояние редактирования листа адреса.
    func setIsSheetEditing(_ isEditing: Bool)
    
    /// Обрабатывает событие появления экрана (инициализация состояния и геолокации).
    func onViewDidAppear()
    
    /// Обрабатывает изменение региона карты — обновляет адрес по новым координатам.
    func onRegionDidChange(center: CLLocationCoordinate2D)
    
    /// Центрирует карту на текущем местоположении пользователя.
    func onLocateTapped()
    
    /// Приближает карту относительно текущего региона.
    func onZoomIn(currentRegion: MKCoordinateRegion) -> MKCoordinateRegion
    
    /// Отдаляет карту относительно текущего региона.
    func onZoomOut(currentRegion: MKCoordinateRegion) -> MKCoordinateRegion
    
    /// Обрабатывает изменение статуса авторизации геолокации.
    func onLocationAuthChanged(_ status: CLAuthorizationStatus, manager: CLLocationManager)
    
    /// Обрабатывает обновление координат пользователя.
    func onLocationsUpdated(_ locations: [CLLocation], manager: CLLocationManager)
    
    /// Обрабатывает ошибку при определении местоположения.
    func onLocationFailed(_ error: Error)
    
    // MARK: - Outputs (callbacks to ViewController)
    
    /// Запрашивает показ листа с адресом.
    var requestPresentAddressSheet: ((String?) -> Void)? { get set }
    
    /// Запрашивает центрирование карты на указанных координатах и масштабе.
    var requestCenterMap: ((CLLocationCoordinate2D, CLLocationDistance) -> Void)? { get set }
    
    /// Обновляет отображаемый текст адреса.
    var updateAddressText: ((String) -> Void)? { get set }
}
