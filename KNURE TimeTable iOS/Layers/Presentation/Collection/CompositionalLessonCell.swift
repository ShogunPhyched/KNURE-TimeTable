//
//  LessonCollectionViewCell.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

@MainActor
protocol LessonCellDelegate: AnyObject {

	func didTapLesson(cell: CompositionalLessonCell.LessonCell, model: CompositionalLessonCell.Model)
}

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

	func configure(with models: [Model], delegate: LessonCellDelegate) {
		stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		for model in models {
			let cell = LessonCell()
			cell.configure(with: model)
			cell.delegate = delegate
			cells.append(cell)
			stackView.addArrangedSubview(cell)
		}
	}

	final class LessonCell: UIView {

		private let title: UILabel
		private let subtitle: UILabel
		private let decorationView: UIView

		private var model: Model?

		private let tapGestureRecognizer: UITapGestureRecognizer
		private let longPressGestureRecognizer: UILongPressGestureRecognizer

		weak var delegate: LessonCellDelegate?

		override init(frame: CGRect) {
			title = .init(frame: .zero)
			title.adjustsFontForContentSizeCategory = true
			title.font = .preferredFont(forTextStyle: .headline)

			subtitle = .init(frame: .zero)
			subtitle.adjustsFontForContentSizeCategory = true
			subtitle.font = .preferredFont(forTextStyle: .subheadline)

			decorationView = UIView()
			decorationView.layer.cornerRadius = 2

			tapGestureRecognizer = UITapGestureRecognizer()
			longPressGestureRecognizer = UILongPressGestureRecognizer()

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

			addGestureRecognizer(tapGestureRecognizer)
			addGestureRecognizer(longPressGestureRecognizer)

			tapGestureRecognizer.addTarget(self, action: #selector(tapGestureRecognizerTapped))
			longPressGestureRecognizer.addTarget(self, action: #selector(longPressGestureRecognizerTapped))
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		func configure(with model: Model) {
			self.model = model
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

		@objc
		private func tapGestureRecognizerTapped() {
			UIView.animate(withDuration: 0.15, animations: {
				self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
			}, completion: { _ in
				if let model = self.model {
					self.delegate?.didTapLesson(cell: self, model: model)
				}

				UIView.animate(withDuration: 0.15) {
					self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.35)

				}
			})
		}

		@objc
		private func longPressGestureRecognizerTapped() {
			UIView.animate(withDuration: 0.2) {
				self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
			}
		}
	}
}

extension CompositionalLessonCell {
	struct Model: Hashable {
		let identifier: String
		let baseIdentifier: Int64
		let title: String
		let subtitle: String
		let startTime: Date
		let endTime: Date
		let number: Int
		let dummy: Bool
	}
}
