//
//  HorizontalTimeColumnHeader.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 03.01.2025.
//  Copyright © 2025 Vladislav Chapaev. All rights reserved.
//

import UIKit

final class HorizontalTimeColumnHeader: UICollectionReusableView {

	static let identifier: String = String(describing: HorizontalTimeColumnHeader.self)

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private let stackView: UIStackView

	override init(frame: CGRect) {
		self.stackView = UIStackView()

		super.init(frame: frame)

		stackView.axis = .vertical
		stackView.spacing = 4
		stackView.distribution = .fillEqually

		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		backgroundColor = .systemBackground

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
		])
	}

	func configure(startEndTimes: [(String, String)]) {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		let stackViews = startEndTimes.map { typle in
			let startLabel = UILabel(frame: .zero)
			startLabel.textAlignment = .right
			startLabel.text = typle.0

			let endLabel = UILabel(frame: .zero)
			endLabel.textAlignment = .right
			endLabel.text = typle.1

			let stackView = UIStackView(arrangedSubviews: [startLabel, UIView(), endLabel])
			stackView.axis = .vertical
			stackView.spacing = 4
			return stackView
		}

		stackViews.forEach { stackView.addArrangedSubview($0) }
	}

	override func preferredLayoutAttributesFitting(
		_ layoutAttributes: UICollectionViewLayoutAttributes
	) -> UICollectionViewLayoutAttributes {
		let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
		attributes.frame.origin = .zero
		return attributes
	}
}
