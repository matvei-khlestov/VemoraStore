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

    // MARK: - Public
    var onSelectProduct: ((Product) -> Void)?

    // MARK: - Deps
    private let viewModel: CatalogViewModel

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.alwaysBounceVertical = true
        cv.dataSource = self
        cv.delegate = self
        cv.keyboardDismissMode = .onDrag
        cv.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseId)
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
    private var items: [Product] = []
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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        setupLayout()
        bindViewModel()
        reload()
    }
}

// MARK: - Private
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

    func bindViewModel() {
        // TODO: Подпишись на паблишеры VM, когда добавишь их
        // Пример (если сделаешь @Published products в VM):
        // viewModel.$filtered
        //   .receive(on: DispatchQueue.main)
        //   .sink { [weak self] products in
        //       self?.items = products
        //       self?.collectionView.reloadData()
        //   }
        //   .store(in: &bag)
    }

    func reload() {
        // TODO: дерни метод загрузки у VM (если будет)
        // viewModel.reload()
    }

    func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .estimated(260))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(260))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource
extension CatalogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.reuseId,
            for: indexPath
        ) as? ProductCell else {
            return UICollectionViewCell()
        }
        let product = items[indexPath.item]
        cell.configure(with: product)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = items[indexPath.item]
        onSelectProduct?(product)
    }
}

// MARK: - UISearchResultsUpdating
extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: пробросить запрос во VM, если добавишь фильтрацию
        // viewModel.query = searchController.searchBar.text ?? ""
    }
}
