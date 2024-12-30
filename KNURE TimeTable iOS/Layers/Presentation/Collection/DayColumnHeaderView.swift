//
//  DayColumnHeaderView.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

final class DayColumnHeaderView: UICollectionReusableView {

	static let identifier: String = String(describing: DayColumnHeaderView.self)

	private let label: UILabel = .init()
	private let backgroundView: UIView = .init()

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .systemBackground
		addSubview(backgroundView)
		addSubview(label)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.layer.cornerRadius = 12
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.adjustsFontForContentSizeCategory = true

		NSLayoutConstraint.activate([
			backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

			label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
		])
	}

	func configure(title: String, isCurrentDay: Bool) {
		label.text = title
		if isCurrentDay {
			backgroundView.backgroundColor = .systemRed.withAlphaComponent(0.5)
		} else {
			backgroundView.backgroundColor = .clear
		}
	}
}
