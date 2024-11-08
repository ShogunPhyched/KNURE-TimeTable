//
//  LessonCollectionViewCell.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

struct LessonCollectionViewCellModel: Hashable {
	let subjectId: String
	let baseIdentifier: Int64
	let title: String
	let subtitle: String
	let startTime: Date
	let endTime: Date
}

final class LessonCollectionViewCell: UICollectionViewCell {

	var subjectId: String = ""
	let title: UILabel
	let subtitle: UILabel

	override init(frame: CGRect) {
		title = .init(frame: .zero)
		subtitle = .init(frame: .zero)
		super.init(frame: frame)

		let stackView = UIStackView(arrangedSubviews: [title, subtitle])
		stackView.axis = .vertical
		stackView.spacing = 4

		contentView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with model: LessonCollectionViewCellModel) {
		subjectId = model.subjectId
		title.text = model.title
		subtitle.text = model.subtitle

		switch model.baseIdentifier {
			case 0...2:
				backgroundColor = .systemYellow.withAlphaComponent(0.25)

			case 10...12:
				backgroundColor = .systemGreen.withAlphaComponent(0.25)

			case 20...24:
				backgroundColor = .systemPink.withAlphaComponent(0.25)

			default:
				backgroundColor = .tertiarySystemBackground
		}
	}
}
