//
//  TimetableViewController.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

struct TimetableView: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UIViewController {
		UINavigationController(
			rootViewController: Assembly.shared.makeTimetableView()
		)
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
	}
}

final class TimetableViewController: UIViewController {

	private var cancellables: Set<AnyCancellable> = []
	private let builder: TimetableCollectionBuilder = .init()
	private let viewModel: TimetableViewModel = .init()

	private let interactor: TimetableInteractorInput

	private lazy var refreshButton: UIButton = {
		let refreshButton = UIButton(type: .system)
		refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
		refreshButton.setTitleColor(.systemGray, for: .disabled)
		refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
		return refreshButton
	}()

	private lazy var titleButton: UIButton = {
		var configuration = UIButton.Configuration.plain()
		configuration.imagePlacement = .leading
		configuration.imagePadding = 8

		let titleButton = UIButton(configuration: configuration)
		titleButton.addTarget(self, action: #selector(displayPicker), for: .touchUpInside)
		titleButton.semanticContentAttribute = .forceRightToLeft
		return titleButton
	}()

	init(interactor: TimetableInteractorInput) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
		navigationController?.navigationBar.isTranslucent = false

		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
		navigationItem.titleView = titleButton
		navigationItem.largeTitleDisplayMode = .never
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		let output = builder.build(
			scrollDirection: { [weak self] in
				guard let self else { return .horizontal }
				return self.viewModel.isVerticalMode ? .vertical : .horizontal
			},
			lessonCellDelegate: self
		)
		viewModel.dataSource = output.dataSource
		view = TimetableMainView(collectionView: output.collection)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		print("Document Directory Path: \(documentsDirectory.path)")

		viewModel.$addedItems
			.compactMap { items in
				let value = items.first(where: { $0.selected })
				self.refreshButton.isEnabled = value != nil
				self.titleButton.setTitle(value?.shortName, for: .normal)
				self.titleButton.setImage(
					value != nil ? UIImage(systemName: "chevron.down") : nil,
					for: .normal
				)
				self.titleButton.sizeToFit()
				return value?.identifier
			}
			.map(interactor.observeTimetableUpdates(identifier:))
			.switchToLatest()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] model in
				self?.viewModel.update(with: model, animated: false)
			}
			.store(in: &cancellables)

		NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
			.sink { [weak self] _ in
				self?.viewModel.isVerticalMode = UserDefaults.standard.bool(forKey: "TimetableVerticalMode")
			}
			.store(in: &cancellables)

		viewModel.$isVerticalMode
			.receive(on: DispatchQueue.main)
			.sink { [weak self] value in
				guard let self else { return }
				let collectionView = (self.view as? TimetableMainView)?.collectionView
				collectionView?.setCollectionViewLayout(
					self.builder.makeLayout(
						scrollDirection: { value ? .vertical : .horizontal },
						dataSource: { self.viewModel.dataSource }
					), animated: false
				)
				collectionView?.reloadData()
				self.viewModel.update()
			}
			.store(in: &cancellables)

		interactor.observeAddedItems()
			.assign(to: &viewModel.$addedItems)
	}

	@objc
	private func refresh() {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.fromValue = 0.0
		rotateAnimation.toValue = CGFloat(Double.pi * 2)
		rotateAnimation.isRemovedOnCompletion = false
		rotateAnimation.duration = 1.0
		rotateAnimation.repeatCount = .infinity
		refreshButton.isEnabled = false
		refreshButton.layer.add(rotateAnimation, forKey: nil)

		if let selectedItem = viewModel.addedItems.first(where: { $0.selected }) {
			Task {
				do {
					try await interactor.updateTimetable(identifier: selectedItem.identifier, type: selectedItem.type)
				} catch {
					let alert = UIAlertController(
						title: "Error",
						message: error.localizedDescription,
						preferredStyle: .alert
					)
					let action = UIAlertAction(title: "OK", style: .default)
					alert.addAction(action)
					present(alert, animated: true)
				}
				refreshButton.layer.removeAllAnimations()
				refreshButton.isEnabled = true
			}
		}
	}

	@objc
	private func displayPicker() {
		let hostingController = UIHostingController(
			rootView: ItemsPickerView(items: viewModel.addedItems) { [weak self] item in
				Task {
					try await self?.interactor.selectItem(identifier: item.identifier)
				}
			}
		)

		hostingController.modalPresentationStyle = .popover
		hostingController.popoverPresentationController?.sourceView = titleButton
		present(hostingController, animated: true)
	}
}

extension TimetableViewController: LessonCellDelegate {
	func didTapLesson(_ cell: CompositionalLessonCell.Model) {
		let hostingController = UIHostingController(
			rootView: Assembly.shared.makeLessonDetailView(cell.identifier)
		)

		hostingController.modalPresentationStyle = .popover
		hostingController.popoverPresentationController?.sourceView = titleButton
		present(hostingController, animated: true)
	}
}
