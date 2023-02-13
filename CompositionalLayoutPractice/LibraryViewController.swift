//
//  ViewController.swift
//  CompositionalLayoutPractice
//
//  Created by Ryo Mashima on 2023/02/10.
//

import UIKit

class LibraryViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case navigation
        case recentlyAddAlbums
    }

    enum Navigation: Hashable, CaseIterable {
        case playlist
        case artist
        case album
        case song
        case recommend
        case downloaded

        var cellContent: (UIImage?, String) {
            switch self {
                case .playlist: return (UIImage(systemName: "music.note.list"), "プレイリスト")
                case .artist: return (UIImage(systemName: "music.mic"), "アーティスト")
                case .album: return (UIImage(systemName: "square.stack"), "アルバム")
                case .song: return (UIImage(systemName: "music.note"), "曲")
                case .recommend: return (UIImage(systemName: "person.crop.square"), "あなたにおすすめ")
                case .downloaded: return (UIImage(systemName: "arrow.down.circle"), "ダウンロード済み")
            }
        }
    }

    private var collectionView: UICollectionView!
    private let recentlyAddAlbums: [Album] = (0..<40).map {
        .init(name: "album \($0)", artist: .init(name: "artist name"), songs: [])
    }
    private let navigationItems: [Navigation] = Navigation.allCases
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ライブラリ"
        configureCollectionView()
        // mock data append
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.navigation, .recentlyAddAlbums])
        snapshot.appendItems(navigationItems, toSection: .navigation)
        snapshot.appendItems(recentlyAddAlbums.map { $0.id }, toSection: .recentlyAddAlbums)
        self.dataSource?.apply(snapshot)
    }

    private func configureCollectionView() {
        // layout
        self.collectionView = UICollectionView(frame: view.frame, collectionViewLayout: compositionalLayout())
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(collectionView)
        // cell register
        let recentlyAddAlbumCellRegistration = UICollectionView.CellRegistration<MusicItemCell, Album> { cell, indexPath, item in
            cell.configure(content: item)
        }
        let navigationCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Navigation> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.image = item.cellContent.0
            content.imageProperties.tintColor = .systemPink
            content.text = item.cellContent.1
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .title3)
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
        let headerRegistration = UICollectionView
            .SupplementaryRegistration<HeaderSupplementaryView>(elementKind: UICollectionView.elementKindSectionHeader) { (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "最近追加した項目"
        }
        // datasource
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = Section(rawValue: indexPath.section)!
            switch section {
                case .recentlyAddAlbums:
                    return collectionView.dequeueConfiguredReusableCell(using: recentlyAddAlbumCellRegistration,
                                                                        for: indexPath,
                                                                        item: self.recentlyAddAlbums[indexPath.item])
                case .navigation:
                    return collectionView.dequeueConfiguredReusableCell(using: navigationCellRegistration,
                                                                        for: indexPath,
                                                                        item: self.navigationItems[indexPath.item])
            }
        })
        dataSource?.supplementaryViewProvider = {
            $0.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: $2)
        }
        collectionView.dataSource = dataSource
    }

    private func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                               layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section = Section(rawValue: sectionIndex)!
            switch section {
                case .recentlyAddAlbums:
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .estimated(72.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .estimated(72.0))
                    let itemCount: Int
                    if layoutEnvironment.container.contentSize.width > 1000 {
                        itemCount = 4
                    } else if layoutEnvironment.container.contentSize.width > 600 {
                        itemCount = 3
                    } else {
                        itemCount = 2
                    }
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                                   subitem: item,
                                                                   count: itemCount)
                    let spacing = 16.0
                    group.interItemSpacing = .fixed(spacing)
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = spacing
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(32))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top,
                                                                                    absoluteOffset: .init(x: 0, y: -spacing))
                    section.boundarySupplementaryItems = [sectionHeader]
                    return section
                case .navigation:
                    let listSection: NSCollectionLayoutSection = .list(using: .init(appearance: .plain),
                                                                       layoutEnvironment: layoutEnvironment)
                    listSection.contentInsets = .init(top: 0, leading: 0, bottom: 24, trailing: 0)
                    return listSection
            }
        }
    }
}
