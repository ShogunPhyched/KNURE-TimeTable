//
//  TimetableCollectionController.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

final class TimetableCollectionController {

	struct TimetableModel {
		let cellModels: [LessonCollectionViewCellModel]
	}

	enum Section {
		case main
	}

	private(set) var dataSource: UICollectionViewDiffableDataSource<Section, LessonCollectionViewCellModel>!

	@MainActor func update(with model: TimetableModel) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, LessonCollectionViewCellModel>()
		snapshot.appendSections([.main])
		snapshot.appendItems(model.cellModels)
		dataSource.apply(snapshot, animatingDifferences: false)
	}

	@MainActor
	func make() -> UICollectionView {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = .vertical
		let layout = UICollectionViewCompositionalLayout(sectionProvider: { index, environment in

			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(0.9),
					heightDimension: .estimated(44)
				)
			)

			let group = NSCollectionLayoutGroup.vertical(
				layoutSize: .init(
					widthDimension: .fractionalWidth(0.9),
					heightDimension: .fractionalHeight(1)
				), subitems: [item]
			)
			group.interItemSpacing = .fixed(10)

			let section = NSCollectionLayoutSection(group: group)

			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .estimated(60)
				),
				elementKind: DayColumnHeaderView.identifier, alignment: .top
			)

			section.boundarySupplementaryItems = [header]

			return section

		}, configuration: configuration)

		let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)

		let cellRegistration = UICollectionView.CellRegistration<
			LessonCollectionViewCell, LessonCollectionViewCellModel
		> { cell, indexPath, item in
			cell.configure(with: item)
		}

		dataSource = UICollectionViewDiffableDataSource<Section, LessonCollectionViewCellModel>(
			collectionView: collection
		) { collectionView, indexPath, item in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}

		let supplementaryRegistration = UICollectionView.SupplementaryRegistration<DayColumnHeaderView>(
			elementKind: DayColumnHeaderView.identifier
		) { view, string, indexPath in

			if let model = self.dataSource.itemIdentifier(for: indexPath) {
				let date = model.startTime.addingTimeInterval(Double(indexPath.item) * 60)
				view.configure(title: "\(date)", isCurrentDay: false)
			}
		}

		dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
			collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
		}

		return collection
	}
}
