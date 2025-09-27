//
//  CartService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CartService: CartServiceProtocol {
    
    // MARK: - Singleton
    static let shared = CartService()
    private init() {}
    
    // MARK: - Private
    private let itemsSubject = CurrentValueSubject<[CartItem], Never>([])
    private var items: [CartItem] {
        get { itemsSubject.value }
        set { itemsSubject.send(newValue) }
    }
    
    // MARK: - CartServiceProtocol
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    
    func add(product: ProductTest, quantity: Int = 1) {
        if let idx = items.firstIndex(where: { $0.id == product.id }) {
            items[idx].quantity += quantity
        } else {
            items.append(CartItem(id: product.id, product: product, quantity: max(1, quantity)))
        }
    }
    
    func setQuantity(productId: String, quantity: Int) {
        guard let idx = items.firstIndex(where: { $0.id == productId }) else { return }
        items[idx].quantity = max(1, quantity)
    }
    
    func increase(productId: String) {
        guard let idx = items.firstIndex(where: { $0.id == productId }) else { return }
        items[idx].quantity += 1
    }
    
    func decrease(productId: String) {
        guard let idx = items.firstIndex(where: { $0.id == productId }) else { return }
        items[idx].quantity = max(1, items[idx].quantity - 1)
    }
    
    func remove(productId: String) {
        items.removeAll { $0.id == productId }
    }
    
    func loadMocks() {
        let mocks = MockData.products
        items = mocks.map { CartItem(id: $0.id, product: $0, quantity: 1) }
    }
}

// MARK: - MockData
private enum MockData {
    static let products: [ProductTest] = [
        ProductTest(
            id: "p_sofa_oslo",
            name: "Vemora Oslo Sofa 3-Seater",
            description: "Compact 3-seater sofa with soft fabric upholstery and wooden legs.",
            price: 45999,
            image: URL(string: "https://picsum.photos/seed/oslo-sofa/800/600")!,
            categoryId: "sofas",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_table_nordic",
            name: "Nordic Oak Coffee Table",
            description: "Minimal coffee table made of solid oak with rounded corners.",
            price: 12999,
            image: URL(string: "https://picsum.photos/seed/nordic-table/800/600")!,
            categoryId: "coffee_tables",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_chair_luna",
            name: "Luna Accent Chair",
            description: "Ergonomic accent chair with textured upholstery and metal frame.",
            price: 9999,
            image: URL(string: "https://picsum.photos/seed/luna-chair/800/600")!,
            categoryId: "chairs",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_bed_eden",
            name: "Eden King Size Bed",
            description: "Elegant king size bed frame with padded headboard and wooden legs.",
            price: 55999,
            image: URL(string: "https://picsum.photos/seed/eden-bed/800/600")!,
            categoryId: "beds",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_dresser_metro",
            name: "Metro 6-Drawer Dresser",
            description: "Spacious dresser with six drawers and sleek metal handles.",
            price: 23999,
            image: URL(string: "https://picsum.photos/seed/metro-dresser/800/600")!,
            categoryId: "dressers",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_lamp_aurora",
            name: "Aurora Floor Lamp",
            description: "Modern floor lamp with adjustable arm and soft LED light.",
            price: 7999,
            image: URL(string: "https://picsum.photos/seed/aurora-lamp/800/600")!,
            categoryId: "lighting",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_rug_sahara",
            name: "Sahara Area Rug",
            description: "Handwoven area rug with geometric patterns in warm tones.",
            price: 14999,
            image: URL(string: "https://picsum.photos/seed/sahara-rug/800/600")!,
            categoryId: "rugs",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_shelf_urban",
            name: "Urban Wall Shelf",
            description: "Floating wall shelf made of reclaimed wood and black metal brackets.",
            price: 6999,
            image: URL(string: "https://picsum.photos/seed/urban-shelf/800/600")!,
            categoryId: "shelves",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_desk_nova",
            name: "Nova Writing Desk",
            description: "Compact writing desk with drawer and metal frame, perfect for small spaces.",
            price: 17999,
            image: URL(string: "https://picsum.photos/seed/nova-desk/800/600")!,
            categoryId: "desks",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_cabinet_alto",
            name: "Alto Storage Cabinet",
            description: "Tall storage cabinet with adjustable shelves and matte finish.",
            price: 29999,
            image: URL(string: "https://picsum.photos/seed/alto-cabinet/800/600")!,
            categoryId: "cabinets",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_stool_milo",
            name: "Milo Bar Stool",
            description: "Comfortable bar stool with cushioned seat and wooden legs.",
            price: 8999,
            image: URL(string: "https://picsum.photos/seed/milo-stool/800/600")!,
            categoryId: "stools",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_mirror_elysium",
            name: "Elysium Wall Mirror",
            description: "Round wall mirror with thin gold frame and minimalist design.",
            price: 5999,
            image: URL(string: "https://picsum.photos/seed/elysium-mirror/800/600")!,
            categoryId: "mirrors",
            brendId: "vemora"
        ),
        ProductTest(
            id: "p_couch_venice",
            name: "Venice Velvet Couch",
            description: "Luxurious velvet couch with deep seating and button tufting.",
            price: 49999,
            image: URL(string: "https://picsum.photos/seed/venice-couch/800/600")!,
            categoryId: "sofas",
            brendId: "vemora"
        )
    ]
}
