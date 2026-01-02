//
//  CatalogFilterViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class CatalogFilterViewModelTests: XCTestCase {

    private var repo: CatalogRepositoryMock!
    private var vm: CatalogFilterViewModel!
    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        repo = CatalogRepositoryMock()
        vm = CatalogFilterViewModel(repository: repo)
        bag = []
    }

    override func tearDown() {
        bag = nil
        vm = nil
        repo = nil
        super.tearDown()
    }

    func test_categories_sorted_and_propagated() throws {
        let incoming: [VemoraStore.Category] = [
            .init(
                id: "c2",
                name: "sofas",
                imageURL: "",
                brandIds: [],
                isActive: true,
                createdAt: "",
                updatedAt: ""
            ),
            .init(
                id: "c3",
                name: "Chairs",
                imageURL: "",
                brandIds: [],
                isActive: true,
                createdAt: "",
                updatedAt: ""
            ),
            .init(
                id: "c1",
                name: "beds",
                imageURL: "",
                brandIds: [],
                isActive: true,
                createdAt: "",
                updatedAt: ""
            )
        ]
        let expectedOrder = ["beds", "Chairs", "sofas"]

        let received = try awaitValue(
            vm.categories,
            where: { !$0.isEmpty },
            after: { self.repo.categoriesSubject.send(incoming) }
        )

        XCTAssertEqual(received.map(\.name), expectedOrder)
    }

    func test_brands_sorted_and_propagated() throws {
        let incoming: [VemoraStore.Brand] = [
            .init(
                id: "b3",
                name: "IKEA",
                imageURL: "",
                isActive: true,
                createdAt: "",
                updatedAt: ""
            ),
            .init(
                id: "b1",
                name: "divanru",
                imageURL: "",
                isActive: true,
                createdAt: "",
                updatedAt: ""
            ),
            .init(
                id: "b2",
                name: "Hoff",
                imageURL: "",
                isActive: true,
                createdAt: "",
                updatedAt: ""
            )
        ]
        let expectedOrder = ["divanru", "Hoff", "IKEA"]

        let received = try awaitValue(
            vm.brands,
            where: { !$0.isEmpty },
            after: { self.repo.brandsSubject.send(incoming) }
        )

        XCTAssertEqual(received.map(\.name), expectedOrder)
    }

    func test_initial_state_is_empty_and_foundCount_zero() throws {
        let state = try awaitValue(
            vm.statePublisher,
            where: { $0.isEmpty }
        )
        XCTAssertTrue(state.isEmpty)
        XCTAssertEqual(vm.currentFoundCount, 0)

        _ = try? awaitValue(
            vm.foundCountPublisher,
            where: { _ in true },
            after: { self.repo.productsSubject.send([
                self.sampleProduct(id: "p1", cat: "c1", brand: "b1")
            ]) }
        )
        XCTAssertEqual(vm.currentFoundCount, 0)
    }

    func test_toggleCategory_triggers_state_and_foundCount() throws {
        vm.toggleCategory(id: "c1")

        let state = vm.currentState
        XCTAssertEqual(state.selectedCategoryIds, Set(["c1"]))
        XCTAssertTrue(state.selectedBrandIds.isEmpty)
        XCTAssertNil(state.minPrice)
        XCTAssertNil(state.maxPrice)

        _ = try awaitValue(
            vm.foundCountPublisher,
            where: { $0 == 2 },
            after: {
                self.repo.productsSubject.send([
                    self.sampleProduct(id: "p1", cat: "c1", brand: "b1"),
                    self.sampleProduct(id: "p2", cat: "c1", brand: "b2")
                ])
            }
        )

        XCTAssertEqual(vm.currentFoundCount, 2)
    }

    func test_toggleBrand_and_setPrice_parsing_and_foundCount() throws {
        vm.toggleBrand(id: "b2")
        vm.setMinPrice("10,5")
        vm.setMaxPrice("20.0")

        let st = vm.currentState
        XCTAssertEqual(st.selectedBrandIds, Set(["b2"]))
        XCTAssertEqual(st.minPrice, Decimal(string: "10.5"))
        XCTAssertEqual(st.maxPrice, Decimal(string: "20.0"))

        _ = try awaitValue(
            vm.foundCountPublisher,
            where: { $0 == 1 },
            after: {
                self.repo.productsSubject.send([
                    self.sampleProduct(id: "p10", cat: "cZ", brand: "b2")
                ])
            }
        )

        XCTAssertEqual(vm.currentFoundCount, 1)
    }

    func test_reset_clears_state_and_sets_foundCount_zero() throws {
        vm.toggleCategory(id: "c1")
        vm.toggleBrand(id: "b1")
        vm.setMinPrice("100")
        vm.setMaxPrice("200")

        _ = try awaitValue(
            vm.foundCountPublisher,
            where: { $0 == 2 },
            after: {
                self.repo.productsSubject.send([
                    self.sampleProduct(id: "p1", cat: "c1", brand: "b1"),
                    self.sampleProduct(id: "p2", cat: "c1", brand: "b1")
                ])
            }
        )
        XCTAssertEqual(vm.currentFoundCount, 2)

        vm.reset()

        let zero = try awaitValue(
            vm.foundCountPublisher,
            where: { $0 == 0 }
        )
        XCTAssertEqual(zero, 0)

        let st = vm.currentState
        XCTAssertTrue(st.isEmpty)
        XCTAssertNil(st.minPrice)
        XCTAssertNil(st.maxPrice)
    }

    private func sampleProduct(
        id: String,
        cat: String,
        brand: String
    ) -> VemoraStore.Product {
        .init(
            id: id,
            name: "N",
            description: "",
            nameLower: "n",
            categoryId: cat,
            brandId: brand,
            price: 1,
            imageURL: "",
            isActive: true,
            createdAt: "",
            updatedAt: "",
            keywords: []
        )
    }
}
