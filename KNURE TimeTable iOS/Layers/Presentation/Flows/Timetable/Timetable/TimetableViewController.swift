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

protocol TimetableViewControllerOutput {
}

final class TimetableViewController: UIViewController {

	private var cancellables: Set<AnyCancellable> = []
	private let controller: TimetableCollectionController = .init()
	private let viewModel: TimetableViewModel = .init()

	private let interactor: TimetableInteractorInput

	init(interactor: TimetableInteractorInput) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
		navigationItem.largeTitleDisplayMode = .never
		navigationController?.navigationBar.isTranslucent = false
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = TimetableMainView(controller: controller)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		viewModel.$addedItems
			.filter { $0.contains(where: \.selected) }
			.compactMap(\.first?.identifier)
			.map { identifier in
				self.interactor.observeTimetableUpdates(identifier: identifier)
			}
			.switchToLatest()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] model in
				self?.controller.update(with: model)
			}
			.store(in: &cancellables)

		interactor.observeAddedItems()
			.assign(to: &viewModel.$addedItems)
	}
}
