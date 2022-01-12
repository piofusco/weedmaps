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
        iconImage.contentMode = .scaleAspectFill
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
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 3
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.addSubview(iconImage)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(ratingLabel)

        NSLayoutConstraint.activate([
            iconImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            iconImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImage.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            iconImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6)
        ])

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            nameLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 10),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            priceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5)
        ])

        NSLayoutConstraint.activate([
            ratingLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            ratingLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        priceLabel.text = ""
        ratingLabel.text = ""
        activityIndicator.startAnimating()
        iconImage.isHidden = true
        iconImage.image = nil
    }

    func setupLabels(name: String, price: String?, rating: Double?) {
        nameLabel.text = name
        priceLabel.text = price ?? "$"
        ratingLabel.text = "Average rating: \(rating ?? 0)"
    }

    func updateImage(data: Data) {
        activityIndicator.stopAnimating()
        iconImage.isHidden = false
        iconImage.image = UIImage(data: data)
    }
}