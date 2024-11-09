//
//  TimeColumnHeader.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 09.11.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

final class TimeColumnHeader: UICollectionReusableView {

	static let identifier: String = String(describing: TimeColumnHeader.self)

	private let startLabel: UILabel
	private let endLabel: UILabel

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		startLabel = .init(frame: .zero)
		startLabel.textAlignment = .right

		endLabel = .init(frame: .zero)
		endLabel.textAlignment = .right
		super.init(frame: frame)

		let stackView = UIStackView(arrangedSubviews: [startLabel, endLabel])
		stackView.axis = .vertical
		stackView.spacing = 4

		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	func configure(startTime: String, endTime: String) {
		startLabel.text = startTime
		endLabel.text = endTime
	}
}
