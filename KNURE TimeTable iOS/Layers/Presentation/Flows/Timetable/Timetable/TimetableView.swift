//
//  TimetableView.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

final class TimetableMainView: UIView {

	init(controller: TimetableCollectionController) {
		super.init(frame: .zero)
		let collectionView = controller.make()
		addSubview(collectionView)
		collectionView.backgroundColor = .clear
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
