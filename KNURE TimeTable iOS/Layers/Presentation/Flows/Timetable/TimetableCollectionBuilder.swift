//
//  TimetableCollectionBuilder.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import UIKit

@MainActor
final class TimetableCollectionBuilder {

	private func makeVerticalSection(_ section: TimetableModel.Section) -> NSCollectionLayoutSection {
//		let timeSupplementaryItem = NSCollectionLayoutSupplementaryItem(
//			layoutSize: NSCollectionLayoutSize(
//				widthDimension: .fractionalWidth(0.2),
//				heightDimension: .absolute(60)
//			),
//			elementKind: TimeColumnHeader.identifier,
//			containerAnchor: NSCollectionLayoutAnchor(
//				edges: .all
//			)
//		)

		let innerGroups = section.groups.map { group in
			let count = group.cellModels.count
			let innerGroup = NSCollectionLayoutGroup.horizontal(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(60.0)
				),
				repeatingSubitem: NSCollectionLayoutItem(
					layoutSize: NSCollectionLayoutSize(
						widthDimension:  .fractionalWidth(1.0 / CGFloat(count)),
						heightDimension: .fractionalHeight(1.0)
					)
				),
				count: count
			)
			innerGroup.interItemSpacing = .fixed(4)
			return innerGroup
		}

//		let horizontalGroup = NSCollectionLayoutGroup.vertical(
//			layoutSize: NSCollectionLayoutSize(
//				widthDimension: .fractionalWidth(1.0),
//				heightDimension: .absolute(60.0)
//			),
//			repeatingSubitem: NSCollectionLayoutItem(
//				layoutSize: NSCollectionLayoutSize(
//					widthDimension: .fractionalWidth(0.2),
//					heightDimension: .absolute(60)
//				), supplementaryItems: [timeSupplementaryItem]
//			),
//			count: section.groups.count
//		)
//
//		horizontalGroup.interItemSpacing = .fixed(8)

		let verticalGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: .init(
				widthDimension: .fractionalWidth(0.8),
				heightDimension: .estimated(60.0)
			),
			subitems: innerGroups
		)

		verticalGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(
			leading: .flexible(0.2),
			top: nil,
			trailing: .fixed(4),
			bottom: nil
		)

		verticalGroup.interItemSpacing = .fixed(4)

		let header = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: .init(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(44.0)
			),
			elementKind: DayColumnHeaderView.identifier,
			alignment: .top
		)
		header.pinToVisibleBounds = true

		let section = NSCollectionLayoutSection(group: verticalGroup)

		section.interGroupSpacing = 4
		section.boundarySupplementaryItems = [header]

		return section
	}

	private func makeHorizontalSection(
		_ section: TimetableModel.Section,
		maxNumberOfPairs: Int
	) -> NSCollectionLayoutSection {
		let innerGroups = section.groups.map { group in
			let count = group.cellModels.count
			let innerGroup = NSCollectionLayoutGroup.horizontal(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(1.0 / CGFloat(maxNumberOfPairs))
				),
				repeatingSubitem: NSCollectionLayoutItem(
					layoutSize: NSCollectionLayoutSize(
						widthDimension:  .fractionalWidth(1.0 / CGFloat(count)),
						heightDimension: .fractionalHeight(1.0)
					)
				),
				count: count
			)
			innerGroup.interItemSpacing = .fixed(4)
			return innerGroup
		}

		let verticalGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: .init(
				widthDimension: .absolute(100),
				heightDimension: .fractionalHeight(0.9)
			),
			subitems: innerGroups
		)

		verticalGroup.interItemSpacing = .fixed(4)

		verticalGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(
			leading: nil,
			top: .fixed(60),
			trailing: nil,
			bottom: .fixed(4)
		)

		let section = NSCollectionLayoutSection(group: verticalGroup)

		let header = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: .init(
				widthDimension: .absolute(100),
				heightDimension: .fractionalHeight(0.1)
			),
			elementKind: DayColumnHeaderView.identifier,
			alignment: .top
		)

		section.interGroupSpacing = 4
		section.boundarySupplementaryItems = [header]

		return section
	}

	func makeLayout(
		scrollDirection: () -> UICollectionView.ScrollDirection,
		dataSource: @escaping () -> UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>
	) -> UICollectionViewCompositionalLayout {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = scrollDirection()
		configuration.interSectionSpacing = 4
		return UICollectionViewCompositionalLayout(sectionProvider: { index, environment in
			guard
				let itemSection = dataSource().sectionIdentifier(for: index)
			else {
				fatalError()
			}

			switch configuration.scrollDirection {
				case .vertical:
					return self.makeVerticalSection(itemSection)

				case .horizontal:
					let allSections = dataSource().snapshot().sectionIdentifiers
					let maxNumberOfPairs = allSections.flatMap(\.groups).flatMap(\.cellModels).map(\.number).max() ?? 1
					return self.makeHorizontalSection(itemSection, maxNumberOfPairs: maxNumberOfPairs)

				@unknown default:
					fatalError()
			}

		}, configuration: configuration)
	}

	func build(
		scrollDirection: @escaping () -> UICollectionView.ScrollDirection
	) -> (
		collection: UICollectionView,
		dataSource: UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>
	) {
		var dataSource: UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>!

		let collection = UICollectionView(
			frame: .zero,
			collectionViewLayout: makeLayout(
				scrollDirection: scrollDirection,
				dataSource: { dataSource }
			)
		)
		let registration = UICollectionView.CellRegistration<
			LessonCollectionViewCell, LessonCollectionViewCellModel
		> { cell, indexPath, item in
			cell.configure(with: item)
		}

		dataSource = UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>(
			collectionView: collection
		) { collectionView, indexPath, item in
			collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
		}

		let dayHeaderRegistration = UICollectionView.SupplementaryRegistration<DayColumnHeaderView>(
			elementKind: DayColumnHeaderView.identifier
		) { view, _, indexPath in
			if let model = dataSource.itemIdentifier(for: indexPath) {
				let formatter = scrollDirection() == .vertical ? Formatters.verticalDate : Formatters.horizontalDate
				view.configure(
					title: formatter.string(from: model.startTime),
					isCurrentDay: Calendar.current.isDateInToday(model.startTime)
				)
			}
		}

		let timeHeaderRegistration = UICollectionView.SupplementaryRegistration<TimeColumnHeader>(
			elementKind: TimeColumnHeader.identifier
		) { view, kind, indexPath in
			if let model = dataSource.itemIdentifier(for: indexPath) {
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

		return (collection, dataSource)
	}
}
