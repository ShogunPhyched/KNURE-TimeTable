//
//  LessonCollectionViewCell.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

final class CompositionalLessonCell: UICollectionViewCell {

	private var cells: [LessonCell] = []
	private let stackView: UIStackView

	override init(frame: CGRect) {

		self.stackView = UIStackView()
		self.stackView.axis = .horizontal
		self.stackView.spacing = 4
		self.stackView.distribution = .fillEqually

		super.init(frame: frame)

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

	func configure(with models: [Model]) {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for model in models {
			let cell = LessonCell()
			cell.configure(with: model)
			cells.append(cell)
			stackView.addArrangedSubview(cell)
		}
	}

	final class LessonCell: UIView {

		private let title: UILabel
		private let subtitle: UILabel

		override init(frame: CGRect) {
			title = .init(frame: .zero)
			title.adjustsFontForContentSizeCategory = true
			title.font = .preferredFont(forTextStyle: .headline)

			subtitle = .init(frame: .zero)
			subtitle.adjustsFontForContentSizeCategory = true
			subtitle.font = .preferredFont(forTextStyle: .subheadline)

			super.init(frame: frame)

			let stackView = UIStackView(arrangedSubviews: [title, subtitle, UIView()])
			stackView.axis = .vertical
			stackView.spacing = 4

			addSubview(stackView)
			stackView.translatesAutoresizingMaskIntoConstraints = false

			NSLayoutConstraint.activate([
				stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
				stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
				stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
				stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
			])
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func configure(with model: Model) {
			title.text = model.title
			subtitle.text = model.subtitle

			switch model.baseIdentifier {
				case 0...2:
					backgroundColor = .systemYellow.withAlphaComponent(0.35)

				case 10...12:
					backgroundColor = .systemGreen.withAlphaComponent(0.35)

				case 20...24:
					backgroundColor = .systemPurple.withAlphaComponent(0.35)

				case 40...41:
					backgroundColor = .systemPink.withAlphaComponent(0.35)

				case 50...55:
					backgroundColor = .systemBlue.withAlphaComponent(0.35)

				case 60...65:
					backgroundColor = .systemPink.withAlphaComponent(0.35)

				case 1337:
					backgroundColor = .clear

				default:
					backgroundColor = .systemGray.withAlphaComponent(0.35)
			}
		}
	}
}

extension CompositionalLessonCell {
	struct Model: Hashable {
		let subjectId: String
		let baseIdentifier: Int64
		let title: String
		let subtitle: String
		let startTime: Date
		let endTime: Date
		let number: Int
		let dummy: Bool
	}
}
