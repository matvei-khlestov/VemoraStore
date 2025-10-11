//
//  CatalogFilterCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import Foundation

protocol CatalogFilterCoordinatingProtocol: Coordinator {
    /// Начальное состояние фильтра (может быть пустым).
    var initialState: FilterState { get }

    /// Колбэк завершения. Возвращает применённый фильтр или `nil`, если пользователь вышел без применения.
    var onFinish: ((FilterState?) -> Void)? { get set }
}
