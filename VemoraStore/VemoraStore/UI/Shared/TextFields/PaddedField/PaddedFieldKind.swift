//
//  PaddedFieldKind.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

/// Тип поля — управляет клавиатурой/капсом и др. настройками
enum PaddedFieldKind {
    case apt        // квартира
    case entrance   // подъезд
    case floor      // этаж
    case intercom   // домофон (буквы+цифры, CAPS)
}
