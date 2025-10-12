//
//  CatalogViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine

final class CatalogViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section: Int, CaseIterable {
        case categories
        case products
    }
    
    // MARK: - Callbacks
    
    var onSelectProduct: ((Product) -> Void)?
    var onFilterTap: ((FilterState) -> Void)?
    var onSelectCategory: ((Category) -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CatalogViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 0
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 0
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Каталог"
        static let searchPlaceholder = "Поиск мебели"
    }
    
    // MARK: - CompositionLayout
    
    private enum CompositionLayout {
        // Categories
        static let categoryItemWidth: CGFloat = 88
        static let categoryItemHeight: CGFloat = 110
        static let categoryInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 12, bottom: 8, trailing: 12
        )
        static let categoryInterGroupSpacing: CGFloat = 12
        
        // Products
        static let productsRowSpacing: CGFloat = 1
        static let productsInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 8, bottom: 16, trailing: 8
        )
        static let productsHeaderHeight: CGFloat = 44
        static let productsEstimatedItemHeight: CGFloat = 325
        static let productsEstimatedGroupHeight: CGFloat = 320
        static let minColumnWidth: CGFloat = 170
    }
    
    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .systemGroupedBackground
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .onDrag
        view.showsVerticalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.register([ProductCell.self, CategoryCell.self])
        view.register(
            CatalogSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader
        )
        return view
    }()
    
    private lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.placeholder = Texts.searchPlaceholder
        s.searchResultsUpdater = self
        return s
    }()
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var inCartIds = Set<String>()
    private var favoriteIds = Set<String>()
    
    // MARK: - Init
    
    init(viewModel: CatalogViewModelProtocol) {
        self.viewModel = viewModel
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
        setupSearch()
        bindViewModel()
        viewModel.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

// MARK: - Setup

private extension CatalogViewController {
    func setupAppearance() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    func setupHierarchy() {
        view.addSubviews(collectionView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.Insets.verticalTop
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Metrics.Insets.verticalBottom
            )
        ])
    }
    
    func setupSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func bindViewModel() {
        viewModel.categoriesPublisher
            .combineLatest(
                viewModel.productsPublisher,
                viewModel.activeFiltersCountPublisher
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                self?.collectionView.reloadData()
            }
            .store(in: &bag)
        
        viewModel.inCartIdsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                self?.inCartIds = ids
            }
            .store(in: &bag)
        
        viewModel.favoriteIdsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                self?.favoriteIds = ids
            }
            .store(in: &bag)
    }
    
    func setupNavigationBar() {
        setupNavigationBar(title: Texts.navigationTitle)
    }
}

// MARK: - Layout helpers

private extension CatalogViewController {
    func prepareForAutoLayout() {
        [collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self, let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .categories:
                return self.makeCategoriesSection()
            case .products:
                return self.makeProductsSection(environment: env)
            }
        }
        layout.configuration.contentInsetsReference = .automatic
        return layout
    }
    
    func makeCategoriesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(
                CompositionLayout.categoryItemWidth
            ),
            heightDimension: .estimated(
                CompositionLayout.categoryItemHeight
            )
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(
                CompositionLayout.categoryItemWidth
            ),
            heightDimension: .estimated(
                CompositionLayout.categoryItemHeight
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = CompositionLayout.categoryInsets
        section.contentInsetsReference = .automatic
        section.interGroupSpacing = CompositionLayout.categoryInterGroupSpacing
        return section
    }
    
    func makeProductsSection(
        environment env: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        
        let containerWidth = env.container.effectiveContentSize.width
        let availableWidth = containerWidth - CompositionLayout.productsInsets.horizontal
        let columns = max(2, Int(availableWidth / CompositionLayout.minColumnWidth))
        let fraction = 1.0 / CGFloat(columns)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fraction),
            heightDimension: .estimated(
                CompositionLayout.productsEstimatedItemHeight
            )
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(
                CompositionLayout.productsEstimatedGroupHeight
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: columns)
        )
        group.interItemSpacing = .fixed(
            CompositionLayout.productsRowSpacing
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = CompositionLayout.productsInsets
        section.contentInsetsReference = .automatic
        section.interGroupSpacing = CompositionLayout.productsRowSpacing
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(
                CompositionLayout.productsHeaderHeight
            )
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - Helpers

private extension NSDirectionalEdgeInsets {
    var horizontal: CGFloat {
        leading + trailing
    }
    
    var vertical: CGFloat {
        top + bottom
    }
}

// MARK: - UICollectionViewDataSource

extension CatalogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .categories:
            return viewModel.categories.count
        case .products:
            return viewModel.products.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .categories:
            let cell = collectionView.dequeueReusableCell(CategoryCell.self, for: indexPath)
            let category = viewModel.categories[indexPath.item]
            let count = viewModel.productCount(in: category.id)
            cell.configure(category: category, count: count)
            return cell
            
        case .products:
            let cell = collectionView.dequeueReusableCell(ProductCell.self, for: indexPath)
            let product = viewModel.products[indexPath.item]
            
            let isInCart = inCartIds.contains(product.id)
            let isFavorite = favoriteIds.contains(product.id)
            
            cell.configure(with: product, isFavorite: isFavorite, isInCart: isInCart)
            cell.delegate = self
            cell.bindCartState(cartIdsPublisher: viewModel.inCartIdsPublisher)
            cell.bindFavoriteState(favoriteIdsPublisher: viewModel.favoriteIdsPublisher)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              Section(rawValue: indexPath.section) == .products else {
            return UICollectionReusableView()
        }
        let header: CatalogSectionHeader = collectionView.dequeueReusableSupplementaryView(
            CatalogSectionHeader.self, ofKind: kind, for: indexPath
        )
        header.onFilterTap = { [weak self] in
            guard let self else { return }
            self.onFilterTap?(self.viewModel.currentState)
        }
        
        header.setFilterCount(viewModel.activeFiltersCount)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .categories:
            onSelectCategory?(viewModel.categories[indexPath.item])
        case .products:
            onSelectProduct?(viewModel.products[indexPath.item])
        }
    }
}

// MARK: - UISearchResultsUpdating

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
    }
}

// MARK: - ProductCellDelegate

extension CatalogViewController: ProductCellDelegate {
    func productCell(_ cell: ProductCell, didToggleCart toInCart: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell),
              Section(rawValue: indexPath.section) == .products else { return }
        let product = viewModel.products[indexPath.item]
        if toInCart {
            viewModel.addToCart(productId: product.id)
        } else {
            viewModel.removeFromCart(productId: product.id)
        }
    }
    
    func productCellDidTapFavorite(_ cell: ProductCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              Section(rawValue: indexPath.section) == .products else { return }
        let product = viewModel.products[indexPath.item]
        viewModel.toggleFavorite(productId: product.id)
    }
}

