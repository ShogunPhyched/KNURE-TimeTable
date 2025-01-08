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
		private let decorationView: UIView

		override init(frame: CGRect) {
			title = .init(frame: .zero)
			title.adjustsFontForContentSizeCategory = true
			title.font = .preferredFont(forTextStyle: .headline)

			subtitle = .init(frame: .zero)
			subtitle.adjustsFontForContentSizeCategory = true
			subtitle.font = .preferredFont(forTextStyle: .subheadline)

			decorationView = UIView()
			decorationView.layer.cornerRadius = 2

			super.init(frame: frame)

			layer.cornerRadius = 4

			let stackView = UIStackView(arrangedSubviews: [title, subtitle, UIView()])
			stackView.axis = .vertical
			stackView.spacing = 4

			let rootStackView = UIStackView(arrangedSubviews: [decorationView, stackView])
			rootStackView.axis = .horizontal
			rootStackView.spacing = 4

			addSubview(rootStackView)
			rootStackView.translatesAutoresizingMaskIntoConstraints = false

			NSLayoutConstraint.activate([
				decorationView.widthAnchor.constraint(equalToConstant: 4),

				rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
				rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
				rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
				rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
			])
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
			UIView.animate(withDuration: 0.5) {
				self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
			}
		}

		override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
			UIView.animate(withDuration: 0.5) {
				self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.35)
			}
		}

		override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
			UIView.animate(withDuration: 0.5) {
				self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.35)
			}
		}

		func configure(with model: Model) {
			title.text = model.title
			subtitle.text = model.subtitle

			switch model.baseIdentifier {
				case 0...2:
					backgroundColor = .systemYellow.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemYellow

				case 10...12:
					backgroundColor = .systemGreen.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemGreen

				case 20...24:
					backgroundColor = .systemPurple.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemPurple

				case 40...41:
					backgroundColor = .systemPink.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemPink

				case 50...55:
					backgroundColor = .systemBlue.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemBlue

				case 60...65:
					backgroundColor = .systemPink.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemPink

				case 1337:
					backgroundColor = .clear
					decorationView.backgroundColor = .clear

				default:
					backgroundColor = .systemGray.withAlphaComponent(0.35)
					decorationView.backgroundColor = .systemGray
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
