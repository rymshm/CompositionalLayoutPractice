//
//  MusicItemCell.swift
//  CompositionalLayoutPractice
//
//  Created by Ryo Mashima on 2023/02/16.
//

import UIKit

class MusicItemCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let symbolImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        imageView.addSubview(symbolImageView)
        NSLayoutConstraint.activate([
            // imageView constraint
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
            // nameLabel constraint
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // descriptionLabel constraint
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // symbolImageView constraint
            symbolImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            symbolImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8),
            symbolImageView.widthAnchor.constraint(equalToConstant: 24),
            symbolImageView.heightAnchor.constraint(equalToConstant: 24),
        ])
        // Appearance
        imageView.backgroundColor = .systemPink
        imageView.layer.cornerRadius = 8
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        symbolImageView.tintColor = .white
    }

    func configure(content item: any MusicItem) {
        self.nameLabel.text = item.name
        self.descriptionLabel.text = item.description
        self.symbolImageView.image = item.symbolImage
    }

    required init?(coder: NSCoder) { fatalError() }
}

class SongCell: UICollectionViewCell {
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()

    private let songInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

    private let thumbnailImageView = UIImageView()
    private let songNameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let actionButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(thumbnailImageView)
        songInfoStackView.addArrangedSubview(songNameLabel)
        songInfoStackView.addArrangedSubview(artistNameLabel)
        containerStackView.addArrangedSubview(songInfoStackView)
        containerStackView.addArrangedSubview(actionButton)
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // imageView constraint
            thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor,
                                                      multiplier: 1.0)
        ])
        artistNameLabel.textColor = .secondaryLabel
        artistNameLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        actionButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        actionButton.tintColor = UIColor.label
        thumbnailImageView.backgroundColor = .systemPink
        thumbnailImageView.layer.cornerRadius = 8
    }

    struct Content {
        let songName: String
        let artistName: String
    }

    func configure(content: Content) {
        self.songNameLabel.text = content.songName
        self.artistNameLabel.text = content.artistName
    }

    required init?(coder: NSCoder) { fatalError() }
}

class HeaderSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        if let descriptor =
                UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
                .withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: descriptor, size: 0)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
