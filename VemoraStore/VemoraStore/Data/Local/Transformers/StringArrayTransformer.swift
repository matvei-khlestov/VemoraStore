//
//  StringArrayTransformer.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation

/// Трансформер значений Core Data для хранения массива строк `[String]` в бинарном формате.
///
/// Отвечает за:
/// - сериализацию массива строк в `Data` при сохранении (`transformedValue`);
/// - десериализацию `Data` обратно в `[String]` при чтении (`reverseTransformedValue`);
/// - регистрацию пользовательского ValueTransformer с именем `"StringArrayTransformer"`.
///
/// Особенности реализации:
/// - используется `JSONEncoder`/`JSONDecoder` для надёжной сериализации;
/// - класс помечен как `@objc(StringArrayTransformer)` для корректной работы с Core Data моделями;
/// - поддерживает обратимое преобразование (`allowsReverseTransformation = true`);
/// - при ошибках сериализации/десериализации выводит сообщения в консоль, не выбрасывая исключений.

@objc(StringArrayTransformer)
final class StringArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String] else { return nil }
        do {
            let data = try JSONEncoder().encode(array)
            return data
        } catch {
            print("❌ Encode keywords error:", error)
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let array = try JSONDecoder().decode([String].self, from: data)
            return array
        } catch {
            print("❌ Decode keywords error:", error)
            return nil
        }
    }
}
