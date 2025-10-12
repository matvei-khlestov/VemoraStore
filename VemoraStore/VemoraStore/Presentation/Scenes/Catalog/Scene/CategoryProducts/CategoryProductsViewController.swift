//
//  CategoryProductsViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import UIKit
import Combine

final class CategoryProductsViewController: UIViewController {
    
    // MARK: - Callbacks (navigation-only)
    
    var onSelectProduct: ((Product) -> Void)?
    var onToggleFavorite: ((Product) -> Void)?
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CategoryProductsViewModelProtocol
    
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
        static let searchPlaceholder = "Поиск в категории"
    }
    
    // MARK: - CompositionLayout
    
    private enum CompositionLayout {
        static let rowSpacing: CGFloat = 1
        static let insets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        static let estimatedItemHeight: CGFloat = 325
        static let estimatedGroupHeight: CGFloat = 320
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
        view.register([ProductCell.self])
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
    
    init(viewModel: CategoryProductsViewModelProtocol) {
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
        setupNavigationBarWithNavLeftItem(
            title: self.title ?? "",
            action: #selector(backTapped),
            largeTitleDisplayMode: .always,
            prefersLargeTitles: true
        )
    }
}

// MARK: - Setup

private extension CategoryProductsViewController {
    func setupAppearance() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    func setupHierarchy() {
        view.addSubviews(collectionView)
    }
    
    func setupLayout() {
        [collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
        viewModel.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &bag)

        viewModel.inCartIdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                guard let self else { return }
                self.inCartIds = ids
            }
            .store(in: &bag)
        
        viewModel.favoriteIdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in self?.favoriteIds = ids }
            .store(in: &bag)
    }
}

// MARK: - Layout

private extension CategoryProductsViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, env in
            let containerWidth = env.container.effectiveContentSize.width
            let available = containerWidth - CompositionLayout.insets.horizontal
            let columns = max(2, Int(available / CompositionLayout.minColumnWidth))
            let fraction = 1.0 / CGFloat(columns)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(fraction),
                heightDimension: .estimated(CompositionLayout.estimatedItemHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(CompositionLayout.estimatedGroupHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: Array(repeating: item, count: columns)
            )
            group.interItemSpacing = .fixed(CompositionLayout.rowSpacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = CompositionLayout.insets
            section.contentInsetsReference = .automatic
            section.interGroupSpacing = CompositionLayout.rowSpacing
            return section
        }
        layout.configuration.contentInsetsReference = .automatic
        return layout
    }
}

// MARK: - UICollectionViewDataSource

extension CategoryProductsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

// MARK: - UICollectionViewDelegate

extension CategoryProductsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectProduct?(viewModel.products[indexPath.item])
    }
}

// MARK: - UISearchResultsUpdating

extension CategoryProductsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
    }
}

// MARK: - ProductCellDelegate

extension CategoryProductsViewController: ProductCellDelegate {
    func productCell(_ cell: ProductCell, didToggleCart toInCart: Bool) {
        guard let idx = collectionView.indexPath(for: cell) else { return }
        let product = viewModel.products[idx.item]
        if toInCart {
            viewModel.addToCart(productId: product.id)
        } else {
            viewModel.removeFromCart(productId: product.id)
        }
    }

    func productCellDidTapFavorite(_ cell: ProductCell) {
        guard let idx = collectionView.indexPath(for: cell) else { return }
        let product = viewModel.products[idx.item]
        viewModel.toggleFavorite(productId: product.id)
    }
}

// MARK: - Actions

private extension CategoryProductsViewController {
    @objc func backTapped() { onBack?() }
}

// MARK: - Helpers

private extension NSDirectionalEdgeInsets {
    var horizontal: CGFloat { leading + trailing }
}
