//
//  CatalogFilterViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import UIKit
import Combine

// MARK: - CatalogFilterViewController

final class CatalogFilterViewController: UIViewController {
    
    // MARK: - Sections / Items
    
    private enum Section: Int, CaseIterable {
        case categories
        case brands
        case price
    }
    
    private enum Item: Hashable {
        case category(id: String, name: String, imageURL: String)
        case brand(id: String, name: String, imageURL: String)
        case price
    }
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Screen {
            static let topInset: CGFloat = 15
        }
        
        enum CapsulesLayout {
            static let itemEstimatedWidth: CGFloat = 120
            static let itemHeight: CGFloat = 44
            static let sectionInsets = NSDirectionalEdgeInsets(
                top: 12, leading: 12, bottom: 8, trailing: 12
            )
            static let interGroupSpacing: CGFloat = 8
            static let headerHeight: CGFloat = 36
        }
        
        enum PriceLayout {
            static let itemHeight: CGFloat = 72
            static let sectionInsets = NSDirectionalEdgeInsets(
                top: 8, leading: 12, bottom: 24, trailing: 12
            )
            static let interGroupSpacing: CGFloat = 8
            static let headerHeight: CGFloat = 36
        }
        
        enum Insets {
            static let extraBottomSpacing: CGFloat = 12
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Фильтр"
        static let reset = "Сбросить"
        
        static let headerCategories = "Категории"
        static let headerBrands = "Бренды"
        static let headerPrice = "Цена"
    }
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onApply: ((FilterState) -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CatalogFilterViewModelProtocol
    private let initialState: FilterState
    
    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemGroupedBackground
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .onDrag
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = true
        cv.dataSource = self
        cv.delegate = self
        cv.register([CapsuleTagCell.self, PriceFieldCell.self])
        cv.register(
            FilterSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )
        return cv
    }()
    
    private let bottomBar = FilterBottomBar()
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var categories: [Category] = []
    private var brands: [Brand] = []
    private var currentState: FilterState
    
    private var bottomConstraint: NSLayoutConstraint!
    private var keyboardOverlap: CGFloat = 0
    private var lastAppliedBottomInset: CGFloat = .zero
    
    // MARK: - Init
    
    init(
        viewModel: CatalogFilterViewModelProtocol,
        initialState: FilterState
    ) {
        self.viewModel = viewModel
        self.initialState = initialState
        self.currentState = initialState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupNavigation()
        setupBottomBar()
        bind()
        apply(state: initialState)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInsets()
    }
    
    // MARK: - Apply external state into VM
    
    private func apply(state: FilterState) {
        state.selectedCategoryIds.forEach {
            viewModel.toggleCategory(id: $0)
        }
        
        state.selectedBrandIds.forEach {
            viewModel.toggleBrand(id: $0)
        }
        
        if let min = state.minPrice {
            viewModel.setMinPrice("\(min)")
        }
        
        if let max = state.maxPrice {
            viewModel.setMaxPrice("\(max)")
        }
    }
}

// MARK: - Active filters flag

private extension CatalogFilterViewController {
    var hasActiveFilters: Bool {
        !(currentState.selectedCategoryIds.isEmpty &&
          currentState.selectedBrandIds.isEmpty &&
          currentState.minPrice == nil &&
          currentState.maxPrice == nil)
    }
}

// MARK: - Setup

private extension CatalogFilterViewController {
    func setupAppearance() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    func setupHierarchy() {
        view.addSubviews(collectionView, bottomBar)
    }
    
    func setupLayout() {
        [collectionView, bottomBar].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        bottomConstraint = bottomBar.bottomAnchor.constraint(
            equalTo: view.bottomAnchor
        )
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.Screen.topInset
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            
            bottomBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            bottomBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            bottomConstraint
        ])
    }
    
    private func updateContentInsets(extraSpacing: CGFloat = Metrics.Insets.extraBottomSpacing) {
        let barHeight = bottomBar.bounds.height > 0
        ? bottomBar.bounds.height
        : bottomBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        let safe = view.safeAreaInsets.bottom
        let targetBottom = barHeight + extraSpacing + safe + keyboardOverlap
        
        if abs(collectionView.contentInset.bottom - targetBottom) > 0.5 {
            collectionView.contentInset.bottom = targetBottom
            collectionView.verticalScrollIndicatorInsets.bottom = barHeight + safe + keyboardOverlap
            lastAppliedBottomInset = targetBottom
        }
    }
    
    func setupNavigation() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.navigationTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .never
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Texts.reset,
            style: .plain,
            target: self,
            action: #selector(resetTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .brightPurple
    }
    
    func setupBottomBar() {
        bottomBar.onApply = { [weak self] in
            guard let self else { return }
            self.onApply?(self.currentState)
        }
        bottomBar.set(
            count: viewModel.currentFoundCount,
            hasActiveFilters: hasActiveFilters
        )
        observeKeyboard()
    }
}

// MARK: - Bind

private extension CatalogFilterViewController {
    func bind() {
        // данные реально изменились → перерисовываем
        viewModel.categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.categories = items
                self?.collectionView.reloadData()
                self?.syncSelection()
            }
            .store(in: &bag)
        
        viewModel.brands
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.brands = items
                self?.collectionView.reloadData()
                self?.syncSelection()
            }
            .store(in: &bag)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.currentState = state
                self.syncSelection()
                // Обновим нижнюю панель: мог измениться флаг активных фильтров
                self.bottomBar.set(
                    count: self.viewModel.currentFoundCount,
                    hasActiveFilters: self.hasActiveFilters
                )
            }
            .store(in: &bag)
        
        viewModel.foundCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                guard let self else { return }
                self.bottomBar.set(
                    count: count,
                    hasActiveFilters: self.hasActiveFilters
                )
            }
            .store(in: &bag)
    }
    
    /// Держим выделение ячеек в согласии с `currentState`
    func syncSelection() {
        sync(
            section: .categories,
            ids: categories.map { $0.id },
            selected: Set(currentState.selectedCategoryIds)
        )
        sync(
            section: .brands,
            ids: brands.map { $0.id },
            selected: Set(currentState.selectedBrandIds)
        )
    }
    
    /// Универсальная синхронизация выделения для секции с капсулами
    private func sync(section: Section, ids: [String], selected: Set<String>) {
        for (idx, id) in ids.enumerated() {
            let indexPath = IndexPath(item: idx, section: section.rawValue)
            let shouldBeSelected = selected.contains(id)
            let isSelectedNow = collectionView.indexPathsForSelectedItems?.contains(indexPath) == true
            
            if shouldBeSelected && !isSelectedNow {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                (collectionView.cellForItem(at: indexPath) as? CapsuleTagCell)?.setSelected(true)
            } else if !shouldBeSelected && isSelectedNow {
                collectionView.deselectItem(at: indexPath, animated: false)
                (collectionView.cellForItem(at: indexPath) as? CapsuleTagCell)?.setSelected(false)
            }
        }
    }
}

// MARK: - Layout

private extension CatalogFilterViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex), let self else { return nil }
            switch section {
            case .categories, .brands:
                return self.makeCapsulesSection()
            case .price:
                return self.makePriceSection()
            }
        }
    }
    
    func makeCapsulesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(Metrics.CapsulesLayout.itemEstimatedWidth),
            heightDimension: .absolute(Metrics.CapsulesLayout.itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Metrics.CapsulesLayout.itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(Metrics.CapsulesLayout.interGroupSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = Metrics.CapsulesLayout.sectionInsets
        section.interGroupSpacing = Metrics.CapsulesLayout.interGroupSpacing
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Metrics.CapsulesLayout.headerHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func makePriceSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Metrics.PriceLayout.itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = Metrics.PriceLayout.sectionInsets
        section.interGroupSpacing = Metrics.PriceLayout.interGroupSpacing
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(Metrics.PriceLayout.headerHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }
}

// MARK: - Actions

private extension CatalogFilterViewController {
    @objc func backTapped() {
        onBack?()
    }
    
    @objc func resetTapped() {
        collectionView.indexPathsForSelectedItems?.forEach { indexPath in
            collectionView.deselectItem(at: indexPath, animated: true)
            if let cell = collectionView.cellForItem(at: indexPath) as? CapsuleTagCell {
                cell.setSelected(false)
            }
        }
        viewModel.reset()
        bottomBar.set(count: 0, hasActiveFilters: false)
        (collectionView.cellForItem(at: IndexPath(item: 0, section: Section.price.rawValue)) as? PriceFieldCell)?.clearFields()
    }
}

// MARK: - UICollectionViewDataSource

extension CatalogFilterViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .categories:
            return categories.count
        case .brands:
            return brands.count
        case .price:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        switch section {
        case .categories:
            let cell = collectionView.dequeueReusableCell(CapsuleTagCell.self, for: indexPath)
            let model = categories[indexPath.item]
            let selected = currentState.selectedCategoryIds.contains(model.id)
            cell.configure(title: model.name, imageURL: model.imageURL, isSelected: selected)
            return cell
            
        case .brands:
            let cell = collectionView.dequeueReusableCell(CapsuleTagCell.self, for: indexPath)
            let model = brands[indexPath.item]
            let selected = currentState.selectedBrandIds.contains(model.id)
            cell.configure(title: model.name, imageURL: model.imageURL, isSelected: selected)
            return cell
            
        case .price:
            let cell = collectionView.dequeueReusableCell(PriceFieldCell.self, for: indexPath)
            cell.configure(
                min: currentState.minPrice.map {
                    Self.format($0)
                },
                
                max: currentState.maxPrice.map {
                    Self.format($0)
                }
            )
            cell.onMinChange = { [weak self] text in
                self?.viewModel.setMinPrice(text)
            }
            cell.onMaxChange = { [weak self] text in
                self?.viewModel.setMaxPrice(text)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header: FilterSectionHeader = collectionView.dequeueReusableSupplementaryView(
            FilterSectionHeader.self, ofKind: kind, for: indexPath
        )
        guard let section = Section(rawValue: indexPath.section) else { return header }
        switch section {
        case .categories:
            header.setTitle(Texts.headerCategories)
        case .brands:
            header.setTitle(Texts.headerBrands)
        case .price:
            header.setTitle(Texts.headerPrice)
        }
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension CatalogFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .categories:
            let id = categories[indexPath.item].id
            viewModel.toggleCategory(id: id)
            (collectionView.cellForItem(at: indexPath) as? CapsuleTagCell)?.setSelected(true)
            
        case .brands:
            let id = brands[indexPath.item].id
            viewModel.toggleBrand(id: id)
            (collectionView.cellForItem(at: indexPath) as? CapsuleTagCell)?.setSelected(true)
            
        case .price:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .categories:
            let id = categories[indexPath.item].id
            viewModel.toggleCategory(id: id)
            (collectionView.cellForItem(at: indexPath) as? CapsuleTagCell)?.setSelected(false)
            
        case .brands:
            let id = brands[indexPath.item].id
            viewModel.toggleBrand(id: id)
            (collectionView.cellForItem(at: indexPath) as? CapsuleTagCell)?.setSelected(false)
            
        case .price:
            break
        }
    }
}

// MARK: - Keyboard

private extension CatalogFilterViewController {
    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self,
                  let frameEnd = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                  let duration = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                  let curveRaw = note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
            
            let kbEnd = self.view.convert(frameEnd, from: nil)
            let overlap = max(0, self.view.bounds.maxY - kbEnd.origin.y)
            
            self.keyboardOverlap = overlap
            self.bottomConstraint.constant = -overlap
            self.updateContentInsets()
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curveRaw << 16)
            ) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Helpers

private extension CatalogFilterViewController {
    static func format(_ dec: Decimal) -> String {
        NSDecimalNumber(decimal: dec).stringValue
    }
}
