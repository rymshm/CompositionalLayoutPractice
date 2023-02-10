//
//  ViewController.swift
//  CompositionalLayoutPractice
//
//  Created by mashima.ryo on 2023/02/10.
//

import UIKit

class ViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case navigation
        case recentlyAddAlbums
    }

    enum Item: Hashable {
        case navigation(Navigation)
        case recentlyAddAlbums(Album.ID)
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
    private let recentlyAddAlbums: [Album] = (0..<40).map { _ in
        Album(name: "album", artist: .init(name: "artist name"))
    }
    private let navigationItems: [Navigation] = Navigation.allCases
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ライブラリ"
        self.collectionView = UICollectionView(frame: view.frame, collectionViewLayout: compositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor .constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor .constraint(equalTo: view.bottomAnchor),
        ])
        configureDataSource()
        // initial data load
        var snapShot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapShot.appendSections([.navigation, .recentlyAddAlbums])
        snapShot.appendItems(navigationItems.map { .navigation($0) },
                             toSection: .navigation)
        snapShot.appendItems(recentlyAddAlbums.map { .recentlyAddAlbums($0.id) },
                             toSection: .recentlyAddAlbums)
        self.dataSource?.apply(snapShot)
    }

    private func configureDataSource() {
        let recentlyAddAlbumCellRegistration = UICollectionView.CellRegistration<AlbumCell, Album> { cell, indexPath, item in
            cell.configure(item)
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
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
                case .recentlyAddAlbums(let id):
                    let album = self.recentlyAddAlbums.first(where: { id == $0.id })!
                    return collectionView.dequeueConfiguredReusableCell(using: recentlyAddAlbumCellRegistration,
                                                                        for: indexPath,
                                                                        item: album)
                case .navigation(let navigationItem):
                    return collectionView.dequeueConfiguredReusableCell(using: navigationCellRegistration,
                                                                        for: indexPath,
                                                                        item: navigationItem)
            }
        })
        let headerRegistration = UICollectionView
            .SupplementaryRegistration<HeaderSupplementaryView>(elementKind: UICollectionView.elementKindSectionHeader) { (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "最近追加した項目"
        }
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
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                                   subitem: item,
                                                                   count: 2)
                    group.interItemSpacing = .fixed(16.0)
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 16.0
                    section.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                                    leading: 16,
                                                                    bottom: 24,
                                                                    trailing: 16)
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .estimated(32))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top)
                    section.boundarySupplementaryItems = [sectionHeader]
                    return section
                case .navigation:
                    return .list(using: .init(appearance: .plain), layoutEnvironment: layoutEnvironment)
            }
        }
    }
}

// MARK: - Custom Cell

extension ViewController {
    class AlbumCell: UICollectionViewCell {
        let imageView = UIImageView()
        let albumNameLabel = UILabel()
        let artistNameLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            // layout
            imageView.translatesAutoresizingMaskIntoConstraints = false
            albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
            artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(imageView)
            contentView.addSubview(albumNameLabel)
            contentView.addSubview(artistNameLabel)
            NSLayoutConstraint.activate([
                // imageView constraint
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
                // albumNameLabel constraint
                albumNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
                albumNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                albumNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                // artistNameLabel constraint
                artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor),
                artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                artistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
            // Appearance
            imageView.backgroundColor = .systemPink
            imageView.layer.cornerRadius = 8
            artistNameLabel.textColor = .secondaryLabel
        }

        func configure(_ album: Album) {
            self.albumNameLabel.text = album.name
            self.artistNameLabel.text = album.artist.name
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }

    class HeaderSupplementaryView: UICollectionReusableView {
        let label = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontForContentSizeCategory = true
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 24),
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        }
        required init?(coder: NSCoder) { fatalError() }
    }
}

// MARK: - Data Model

struct Album: Identifiable {
    let id: UUID = UUID()
    let name: String
    let artist: Artist
}

struct Artist {
    let name: String
}

