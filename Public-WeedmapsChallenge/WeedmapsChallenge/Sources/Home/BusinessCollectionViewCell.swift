//
// Created by jarvis on 1/9/22.
// Copyright (c) 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit

class BusinessCollectionViewCell: UICollectionViewCell {
    private lazy var iconImage: UIImageView = {
        let iconImage = UIImageView()
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.isHidden = true
        iconImage.layer.cornerRadius = 5
        iconImage.layer.masksToBounds = true
        return iconImage
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.backgroundColor = .gray

        contentView.addSubview(iconImage)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            iconImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            iconImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImage.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            iconImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75)
        ])

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        activityIndicator.startAnimating()
        iconImage.isHidden = true
        iconImage.image = nil
    }

    func setupLabels(name: String) {
        nameLabel.text = name
        setNeedsLayout() // do we need this?
    }

    func updateImage(data: Data) {
        activityIndicator.stopAnimating()
        iconImage.isHidden = false
        iconImage.image = UIImage(data: data)
    }
}