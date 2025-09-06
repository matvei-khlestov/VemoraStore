//
//  CatalogViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class CatalogViewController: UIViewController {

    enum Section: Int, CaseIterable { case categories, products }

    // MARK: - Public
    var onSelectProduct: ((Product) -> Void)?
    var onAddToCart: ((Product) -> Void)?
    var onToggleFavorite: ((Product) -> Void)?

    // MARK: - Deps
    private let viewModel: CatalogViewModel

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemGroupedBackground
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.keyboardDismissMode = .onDrag
        cv.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseId)
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseId)
        cv.register(CatalogSectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CatalogSectionHeader.reuseId)
        return cv
    }()

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Поиск мебели"
        sc.searchResultsUpdater = self
        return sc
    }()

    // MARK: - State
    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: CatalogViewModel = Container.shared.catalogViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Каталог"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        setupLayout()
        bindViewModel()
        viewModel.reload()
    }
}

// MARK: - Layout
private extension CatalogViewController {
    func setupLayout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .categories:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(88),
                                                      heightDimension: .estimated(110))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(88),
                                                       heightDimension: .estimated(110))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = .init(top: 12, leading: 12, bottom: 8, trailing: 12)
                section.interGroupSpacing = 12
                return section

            case .products:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                      heightDimension: .estimated(320))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(320))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 8, leading: 8, bottom: 16, trailing: 8)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(44))
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
    }

    func bindViewModel() {
        viewModel.$categories
            .combineLatest(viewModel.$products)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.collectionView.reloadData()
            }
            .store(in: &bag)
    }
}

// MARK: - DataSource
extension CatalogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .categories: return viewModel.categories.count
        case .products:   return viewModel.products.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch Section(rawValue: indexPath.section)! {
        case .categories:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCell.reuseId, for: indexPath
            ) as! CategoryCell
            let c = viewModel.categories[indexPath.item]
            cell.configure(title: c.title, count: c.count, imageURL: c.imageURL)
            return cell

        case .products:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductCell.reuseId, for: indexPath
            ) as! ProductCell
            let product = viewModel.products[indexPath.item]
            cell.configure(with: product, isFavorite: false)
            cell.delegate = self
            return cell
        }
    }

    // Header
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              Section(rawValue: indexPath.section) == .products
        else { return UICollectionReusableView() }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CatalogSectionHeader.reuseId,
            for: indexPath
        ) as! CatalogSectionHeader
        header.titleLabel.text = "All Product"
        return header
    }
}

// MARK: - Delegate
extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .products else { return }
        onSelectProduct?(viewModel.products[indexPath.item])
    }
}

// MARK: - Search
extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
    }
}

// MARK: - ProductCellDelegate
extension CatalogViewController: ProductCellDelegate {
    func productCellDidTapFavorite(_ cell: ProductCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              Section(rawValue: indexPath.section) == .products else { return }
        let product = viewModel.products[indexPath.item]
        onToggleFavorite?(product)
    }

    func productCellDidTapAddToCart(_ cell: ProductCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              Section(rawValue: indexPath.section) == .products else { return }
        let product = viewModel.products[indexPath.item]
        onAddToCart?(product)
    }
}

