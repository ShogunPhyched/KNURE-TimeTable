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

		let sections: [Section]

		struct Section: Hashable {
			let cellModels: [LessonCollectionViewCellModel]
		}
	}

	private(set) var dataSource: UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>!

	@MainActor func update(with model: TimetableModel) {
		var snapshot = NSDiffableDataSourceSnapshot<TimetableModel.Section, LessonCollectionViewCellModel>()
		for section in model.sections {
			snapshot.appendSections([section])
			snapshot.appendItems(section.cellModels)
		}
		dataSource.apply(snapshot, animatingDifferences: false)
	}

	@MainActor
	func make() -> UICollectionView {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = .vertical
		let layout = UICollectionViewCompositionalLayout(sectionProvider: { index, environment in

			let item = NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(0.85),
					heightDimension: .estimated(44)
				),
				supplementaryItems: [
					.init(
						layoutSize: NSCollectionLayoutSize(
							widthDimension: .fractionalWidth(0.15),
							heightDimension: .estimated(44)
						),
						elementKind: TimeColumnHeader.identifier,
						containerAnchor: NSCollectionLayoutAnchor(
							edges: .leading, fractionalOffset: CGPoint(x: -1.1, y: 0)
						)
					)
				]
			)
			item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
				leading: .flexible(0.15),
				top: nil,
				trailing: .fixed(8),
				bottom: nil
			)

			let group = NSCollectionLayoutGroup.vertical(
				layoutSize: .init(
					widthDimension: .fractionalWidth(1),
					heightDimension: .estimated(44)
				), subitems: [item]
			)
			group.interItemSpacing = .fixed(8)

			let section = NSCollectionLayoutSection(group: group)

			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(0.09)
				),
				elementKind: DayColumnHeaderView.identifier, alignment: .top
			)
			section.interGroupSpacing = 10
			section.boundarySupplementaryItems = [header]

			return section

		}, configuration: configuration)

		let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collection.showsVerticalScrollIndicator = false
		collection.showsHorizontalScrollIndicator = false

		let cellRegistration = UICollectionView.CellRegistration<
			LessonCollectionViewCell, LessonCollectionViewCellModel
		> { cell, indexPath, item in
			cell.configure(with: item)
		}

		dataSource = UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>(
			collectionView: collection
		) { collectionView, indexPath, item in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
		}

		let dayHeaderRegistration = UICollectionView.SupplementaryRegistration<DayColumnHeaderView>(
			elementKind: DayColumnHeaderView.identifier
		) { view, _, indexPath in
			if let model = self.dataSource.itemIdentifier(for: indexPath) {
				view.configure(
					title: Formatters.dateFormatter.string(from: model.startTime),
					isCurrentDay: false
				)
			}
		}

		let timeHeaderRegistration = UICollectionView.SupplementaryRegistration<TimeColumnHeader>(
			elementKind: TimeColumnHeader.identifier
		) { view, _, indexPath in
			if let model = self.dataSource.itemIdentifier(for: indexPath) {
				view.configure(
					startTime: Formatters.timeFormatter.string(from: model.startTime),
					endTime: Formatters.timeFormatter.string(from: model.endTime)
				)
			}
		}

		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			switch kind {
				case DayColumnHeaderView.identifier:
					collectionView.dequeueConfiguredReusableSupplementary(
						using: dayHeaderRegistration,
						for: indexPath
					)

				case TimeColumnHeader.identifier:
					collectionView.dequeueConfiguredReusableSupplementary(
						using: timeHeaderRegistration,
						for: indexPath
					)
				default: nil
			}
		}

		return collection
	}
}
