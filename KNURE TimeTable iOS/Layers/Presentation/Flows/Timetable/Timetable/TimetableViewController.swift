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

		interactor.observeTimetableUpdates(identifier: "5259428")
			.receive(on: DispatchQueue.main)
			.sink { [weak self] model in
				self?.controller.update(with: model)
			}
			.store(in: &cancellables)
	}
}
