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
    /// Current user scope for in-memory items (used to build CartItem)
    private var userId: String = "local"
    /// Configure the service with an actual user id
    func configure(userId: String) { self.userId = userId }
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
    
    func add(product: Product, quantity: Int = 1) {
        let qty = max(1, quantity)
        if let idx = items.firstIndex(where: { $0.productId == product.id }) {
            items[idx].quantity += qty
            items[idx].updatedAt = Date()
        } else {
            items.append(
                CartItem(
                    userId: userId,
                    productId: product.id,
                    brandName: product.brandId, // if you have a brand name resolver, map here
                    title: product.name,
                    price: product.price,
                    imageURL: product.imageURL,
                    quantity: qty,
                    updatedAt: Date()
                )
            )
        }
    }
    
    func setQuantity(productId: String, quantity: Int) {
        guard let idx = items.firstIndex(where: { $0.productId == productId }) else { return }
        items[idx].quantity = max(1, quantity)
        items[idx].updatedAt = Date()
    }
    
    func increase(productId: String) {
        guard let idx = items.firstIndex(where: { $0.productId == productId }) else { return }
        items[idx].quantity += 1
        items[idx].updatedAt = Date()
    }
    
    func decrease(productId: String) {
        guard let idx = items.firstIndex(where: { $0.productId == productId }) else { return }
        items[idx].quantity = max(1, items[idx].quantity - 1)
        items[idx].updatedAt = Date()
    }
    
    func remove(productId: String) {
        items.removeAll { $0.productId == productId }
    }
    
    func loadMocks() {
        let mocks = MockData.products
        items = mocks.map {
            CartItem(
                userId: userId,
                productId: $0.id,
                brandName: $0.brandId,
                title: $0.name,
                price: $0.price,
                imageURL: $0.imageURL,
                quantity: 1,
                updatedAt: Date()
            )
        }
    }
}

// MARK: - MockData
private enum MockData {
    static let products: [Product] = [
        Product(
            id: "p_sofa_oslo",
            name: "Vemora Oslo Sofa 3-Seater",
            description: "Compact 3-seater sofa with soft fabric upholstery and wooden legs.",
            nameLower: "vemora oslo sofa 3-seater",
            categoryId: "sofas",
            brandId: "vemora",
            price: 45999,
            imageURL: "https://picsum.photos/seed/oslo-sofa/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["sofa", "oslo", "vemora", "диван", "мебель"]
        ),
        Product(
            id: "p_table_nordic",
            name: "Nordic Oak Coffee Table",
            description: "Minimal coffee table made of solid oak with rounded corners.",
            nameLower: "nordic oak coffee table",
            categoryId: "coffee_tables",
            brandId: "vemora",
            price: 12999,
            imageURL: "https://picsum.photos/seed/nordic-table/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["table", "nordic", "oak", "coffee", "стол", "мебель"]
        ),
        Product(
            id: "p_chair_luna",
            name: "Luna Accent Chair",
            description: "Ergonomic accent chair with textured upholstery and metal frame.",
            nameLower: "luna accent chair",
            categoryId: "chairs",
            brandId: "vemora",
            price: 9999,
            imageURL: "https://picsum.photos/seed/luna-chair/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["chair", "luna", "accent", "кресло", "мебель"]
        ),
        Product(
            id: "p_bed_eden",
            name: "Eden King Size Bed",
            description: "Elegant king size bed frame with padded headboard and wooden legs.",
            nameLower: "eden king size bed",
            categoryId: "beds",
            brandId: "vemora",
            price: 55999,
            imageURL: "https://picsum.photos/seed/eden-bed/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["bed", "eden", "king", "bedroom", "кровать", "мебель"]
        ),
        Product(
            id: "p_dresser_metro",
            name: "Metro 6-Drawer Dresser",
            description: "Spacious dresser with six drawers and sleek metal handles.",
            nameLower: "metro 6-drawer dresser",
            categoryId: "dressers",
            brandId: "vemora",
            price: 23999,
            imageURL: "https://picsum.photos/seed/metro-dresser/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["dresser", "metro", "storage", "шкаф", "мебель"]
        ),
        Product(
            id: "p_lamp_aurora",
            name: "Aurora Floor Lamp",
            description: "Modern floor lamp with adjustable arm and soft LED light.",
            nameLower: "aurora floor lamp",
            categoryId: "lighting",
            brandId: "vemora",
            price: 7999,
            imageURL: "https://picsum.photos/seed/aurora-lamp/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["lamp", "aurora", "floor", "light", "лампа", "освещение"]
        ),
        Product(
            id: "p_rug_sahara",
            name: "Sahara Area Rug",
            description: "Handwoven area rug with geometric patterns in warm tones.",
            nameLower: "sahara area rug",
            categoryId: "rugs",
            brandId: "vemora",
            price: 14999,
            imageURL: "https://picsum.photos/seed/sahara-rug/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["rug", "sahara", "carpet", "ковер", "декор"]
        ),
        Product(
            id: "p_shelf_urban",
            name: "Urban Wall Shelf",
            description: "Floating wall shelf made of reclaimed wood and black metal brackets.",
            nameLower: "urban wall shelf",
            categoryId: "shelves",
            brandId: "vemora",
            price: 6999,
            imageURL: "https://picsum.photos/seed/urban-shelf/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["shelf", "urban", "wood", "полка", "мебель"]
        ),
        Product(
            id: "p_desk_nova",
            name: "Nova Writing Desk",
            description: "Compact writing desk with drawer and metal frame, perfect for small spaces.",
            nameLower: "nova writing desk",
            categoryId: "desks",
            brandId: "vemora",
            price: 17999,
            imageURL: "https://picsum.photos/seed/nova-desk/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["desk", "nova", "office", "стол", "рабочий"]
        ),
        Product(
            id: "p_cabinet_alto",
            name: "Alto Storage Cabinet",
            description: "Tall storage cabinet with adjustable shelves and matte finish.",
            nameLower: "alto storage cabinet",
            categoryId: "cabinets",
            brandId: "vemora",
            price: 29999,
            imageURL: "https://picsum.photos/seed/alto-cabinet/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["cabinet", "alto", "storage", "шкаф", "мебель"]
        ),
        Product(
            id: "p_stool_milo",
            name: "Milo Bar Stool",
            description: "Comfortable bar stool with cushioned seat and wooden legs.",
            nameLower: "milo bar stool",
            categoryId: "stools",
            brandId: "vemora",
            price: 8999,
            imageURL: "https://picsum.photos/seed/milo-stool/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["stool", "bar", "milo", "табурет", "кухня"]
        ),
        Product(
            id: "p_mirror_elysium",
            name: "Elysium Wall Mirror",
            description: "Round wall mirror with thin gold frame and minimalist design.",
            nameLower: "elysium wall mirror",
            categoryId: "mirrors",
            brandId: "vemora",
            price: 5999,
            imageURL: "https://picsum.photos/seed/elysium-mirror/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["mirror", "elysium", "decor", "зеркало", "интерьер"]
        ),
        Product(
            id: "p_couch_venice",
            name: "Venice Velvet Couch",
            description: "Luxurious velvet couch with deep seating and button tufting.",
            nameLower: "venice velvet couch",
            categoryId: "sofas",
            brandId: "vemora",
            price: 49999,
            imageURL: "https://picsum.photos/seed/venice-couch/800/600",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["couch", "venice", "velvet", "sofa", "диван", "мебель"]
        )
    ]
}
