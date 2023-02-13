//
//  BrowseViewController.swift
//  CompositionalLayoutPractice
//
//  Created by Ryo Mashima on 2023/02/15.
//

import UIKit

class BrowseViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case albums, songs, playlists, other

        var headerText: String {
            switch self {
                case .albums: return "新着アルバム"
                case .songs: return "注目の曲"
                case .playlists: return "ピックアップ"
                case .other: return "その他"
            }
        }
    }

    private enum OtherContents: Int, CaseIterable {
        case categories, ranking, chill, must, kids, musicVideo

        var text: String {
            switch self {
                case .categories: return "カテゴリ"
                case .chill: return "チル"
                case .kids: return "キッズ"
                case .musicVideo: return "ミュージックビデオ"
                case .must: return "必聴"
                case .ranking: return "ランキング"
            }
        }
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>?

    // Mock Datas
    private let sampleAlbums: [Album] = (0..<10).map { _ in
        Album(name: "album", artist: .init(name: "artist name"), songs: [])
    }
    private let samplePlaylists: [Playlist] = (0..<10).map { _ in
        .init(name: "Playlist", description: "playlist説明文")
    }
    private let sampleSongs: [Song] = (0..<20).map {
        .init(name: "Song \($0)", artist: .init(name: "artist"))
    }
    private let otherContents: [OtherContents] = OtherContents.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "見つける"
        setupCollectionView()
        // mock data append
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.albums, .songs, .playlists, .other])
        snapshot.appendItems(sampleAlbums.map { $0.id },
                             toSection: .albums)
        snapshot.appendItems(sampleSongs.map { $0.id },
                             toSection: .songs)
        snapshot.appendItems(samplePlaylists.map { $0.id },
                             toSection: .playlists)
        snapshot.appendItems(otherContents, toSection: .other)
        self.dataSource?.apply(snapshot)
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: compositionalLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(collectionView)
        configureDataSource()
    }

    private func configureDataSource() {
        let musicItemCellRegistration = UICollectionView.CellRegistration<MusicItemCell, MusicItem> { cell, indexPath, item in
            cell.configure(content: item)
        }
        let songCellRegistration = UICollectionView.CellRegistration<SongCell, Song> { cell, indexPath, item in
            cell.configure(content: .init(songName: item.name, artistName: item.artist.name))
        }
        let otherContentsCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item
            contentConfiguration.textProperties.color = .systemPink
            contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: .title2)
            cell.accessories = [.disclosureIndicator()]
            cell.contentConfiguration = contentConfiguration
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderSupplementaryView>(elementKind: UICollectionView.elementKindSectionHeader) {
            $0.label.text = Section(rawValue: $2.section)?.headerText
        }
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = Section(rawValue: indexPath.section)!
            switch section {
                case .albums:
                    return collectionView.dequeueConfiguredReusableCell(using: musicItemCellRegistration,
                                                                        for: indexPath,
                                                                        item: self.sampleAlbums[indexPath.item])
                case .playlists:
                    return collectionView.dequeueConfiguredReusableCell(using: musicItemCellRegistration,
                                                                        for: indexPath,
                                                                        item: self.samplePlaylists[indexPath.item])
                case .songs:
                    return collectionView.dequeueConfiguredReusableCell(using: songCellRegistration,
                                                                        for: indexPath,
                                                                        item: self.sampleSongs[indexPath.item])
                case .other:
                    return collectionView.dequeueConfiguredReusableCell(using: otherContentsCellRegistration,
                                                                        for: indexPath,
                                                                        item: self.otherContents[indexPath.item].text)
            }
        })
        dataSource?.supplementaryViewProvider = {
            $0.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: $2)
        }
        collectionView.dataSource = dataSource
    }

    private func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout {
            Section(rawValue: $0)!.sectionLayout(layoutEnvironment: $1)
        }
    }
}

private extension BrowseViewController.Section {
    private var sectionContentInsets: NSDirectionalEdgeInsets {
        .init(top: 8, leading: spacing, bottom: 24, trailing: spacing * 2)
    }
    private var spacing: CGFloat { 16 }

    func sectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let group: NSCollectionLayoutGroup
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(32))
        let isPad = layoutEnvironment.traitCollection.userInterfaceIdiom == .pad
        switch self {
            case .albums:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(72))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupFractionalWidth = CGFloat(isPad ? 0.2125 : 0.425)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                                       heightDimension: .estimated(72))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            case .playlists:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(240))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(isPad ? 0.425 : 0.85),
                                                       heightDimension: .estimated(240))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            case .songs:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(60))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(isPad ? 0.425 : 0.85),
                                                       heightDimension: .estimated(180))
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         subitem: item,
                                                         count: 3)
                group.interItemSpacing = .fixed(8)
            case .other:
                let listSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .topLeading,
                                                                                    absoluteOffset: CGPoint(x: 20, y: -5))
                let listSection: NSCollectionLayoutSection = .list(using: .init(appearance: .plain),
                                                                   layoutEnvironment: layoutEnvironment)
                listSection.boundarySupplementaryItems = [listSectionHeader]
                return listSection
        }
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = sectionContentInsets
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .topLeading)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
}
