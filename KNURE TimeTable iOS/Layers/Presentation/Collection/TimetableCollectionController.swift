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
		dataSource.apply(snapshot, animatingDifferences: true)
	}

	@MainActor
	func make() -> UICollectionView {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		let layout = UICollectionViewCompositionalLayout(sectionProvider: { index, environment in

			guard
				let itemSection = self.dataSource.sectionIdentifier(for: index)
			else {
				fatalError()
			}

			let timeSupplementaryItem: NSCollectionLayoutSupplementaryItem = .init(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(0.15),
					heightDimension: .absolute(60)
				),
				elementKind: TimeColumnHeader.identifier,
				containerAnchor: NSCollectionLayoutAnchor(
					edges: .leading
				)
			)

			var horizontalGroups: [NSCollectionLayoutGroup] = []
			for subsection in itemSection.cellModels.grouped(by: \.number) {

				let count = subsection.count
				let items = (0..<count).map { _ in
					return NSCollectionLayoutItem(
						layoutSize: NSCollectionLayoutSize(
							widthDimension: .fractionalWidth(1.0 / CGFloat(count)),
							heightDimension: .fractionalHeight(1.0)
						)
					)
				}

				let horizontalGroup = NSCollectionLayoutGroup.horizontal(
					layoutSize: .init(
						widthDimension: .fractionalWidth(1.0),
						heightDimension: .absolute(60.0)
					),
					subitems: items
				)
				horizontalGroup.interItemSpacing = .fixed(8)

				horizontalGroups.append(horizontalGroup)
			}

			let verticalGroup = NSCollectionLayoutGroup.vertical(
				layoutSize: .init(
					widthDimension: .fractionalWidth(0.8),
					heightDimension: .absolute(
						(60.0 * CGFloat(horizontalGroups.count)) + (8.0 * CGFloat(horizontalGroups.count - 1))
					)
				),
				subitems: horizontalGroups
			)

			verticalGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(
				leading: .flexible(0.2),
				top: nil,
				trailing: .fixed(8),
				bottom: nil
			)
			verticalGroup.interItemSpacing = .fixed(8)
			verticalGroup.supplementaryItems = [timeSupplementaryItem]

			let section = NSCollectionLayoutSection(group: verticalGroup)

			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: .init(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(0.1)
				),
				elementKind: DayColumnHeaderView.identifier,
				alignment: .top
			)

			section.interGroupSpacing = 8
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
					title: Formatters.verticalDateFormatter.string(from: model.startTime),
					isCurrentDay: Calendar.current.isDateInToday(model.startTime)
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
