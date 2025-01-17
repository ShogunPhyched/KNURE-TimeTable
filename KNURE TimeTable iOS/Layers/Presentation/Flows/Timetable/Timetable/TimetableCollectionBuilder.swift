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

	private let estimatedItemHeight: CGFloat = 60.0
	private let itemSpacing: CGFloat = 4.0

	private func makeVerticalSection(_ section: TimetableViewModel.CollectionModel.Section) -> NSCollectionLayoutSection {
		let timeSupplementaryItem = NSCollectionLayoutSupplementaryItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(estimatedItemHeight)
			),
			elementKind: TimeColumnHeader.identifier,
			containerAnchor: NSCollectionLayoutAnchor(edges: .leading),
			itemAnchor: NSCollectionLayoutAnchor(edges: .trailing, absoluteOffset: CGPoint(x: -8.0, y: 0.0))
		)
		timeSupplementaryItem.zIndex = -1

		let layoutItem = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(estimatedItemHeight)
			),
			supplementaryItems: [timeSupplementaryItem]
		)

		let verticalGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: .init(
				widthDimension: .fractionalWidth(0.8),
				heightDimension: .estimated(estimatedItemHeight)
			),
			repeatingSubitem: layoutItem,
			count: section.cellModels.count
		)

		verticalGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(
			leading: .flexible(0.2),
			top: nil,
			trailing: .fixed(itemSpacing),
			bottom: nil
		)

		verticalGroup.interItemSpacing = .fixed(itemSpacing)

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

		section.interGroupSpacing = itemSpacing
		section.boundarySupplementaryItems = [header]

		return section
	}

	private func makeHorizontalSection(
		_ section: TimetableViewModel.CollectionModel.Section,
		maxNumberOfPairs: Int
	) -> NSCollectionLayoutSection {

		let layoutItem = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalHeight(1.0 / CGFloat(maxNumberOfPairs))
			)
		)

		let verticalGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: .init(
				widthDimension: .absolute(100),
				heightDimension: .fractionalHeight(0.9)
			),
			repeatingSubitem: layoutItem,
			count: section.cellModels.count
		)

		verticalGroup.interItemSpacing = .fixed(itemSpacing)

		verticalGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(
			leading: nil,
			top: .fixed(60),
			trailing: nil,
			bottom: .fixed(itemSpacing)
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

		section.interGroupSpacing = itemSpacing
		section.boundarySupplementaryItems = [header]

		return section
	}

	func makeLayout(
		scrollDirection: () -> UICollectionView.ScrollDirection,
		dataSource: @escaping () -> UICollectionViewDiffableDataSource<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>
	) -> UICollectionViewCompositionalLayout {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = scrollDirection()
		configuration.interSectionSpacing = 4

		if configuration.scrollDirection == .horizontal {
			let timeHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: .init(
					widthDimension: .absolute(60),
					heightDimension: .fractionalHeight(0.85)
				),
				elementKind: HorizontalTimeColumnHeader.identifier,
				alignment: .leading
			)
			timeHeader.pinToVisibleBounds = true
			timeHeader.zIndex = 2

			configuration.boundarySupplementaryItems = [timeHeader]
		}

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
					let maxNumberOfPairs = allSections.flatMap(\.cellModels).flatMap({ $0 }).map(\.number).max() ?? 1
					return self.makeHorizontalSection(itemSection, maxNumberOfPairs: maxNumberOfPairs)

				@unknown default:
					fatalError()
			}

		}, configuration: configuration)
	}

	func build(
		scrollDirection: @escaping () -> UICollectionView.ScrollDirection,
		lessonCellDelegate: LessonCellDelegate
	) -> (
		collection: UICollectionView,
		dataSource: UICollectionViewDiffableDataSource<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>
	) {
		var dataSource: UICollectionViewDiffableDataSource<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>!

		let collection = UICollectionView(
			frame: .zero,
			collectionViewLayout: makeLayout(
				scrollDirection: scrollDirection,
				dataSource: { dataSource }
			)
		)
		let registration = UICollectionView.CellRegistration<
			CompositionalLessonCell, [CompositionalLessonCell.Model]
		> { cell, indexPath, item in
			cell.configure(with: item, delegate: lessonCellDelegate)
		}

		dataSource = UICollectionViewDiffableDataSource<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>(
			collectionView: collection
		) { collectionView, indexPath, item in
			collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
		}

		let dayHeaderRegistration = UICollectionView.SupplementaryRegistration<DayColumnHeaderView>(
			elementKind: DayColumnHeaderView.identifier
		) { view, _, indexPath in
			if let model = dataSource.itemIdentifier(for: indexPath)?.first {
				let formatter = scrollDirection() == .vertical ? Formatters.verticalDate : Formatters.horizontalDate
				view.configure(
					title: formatter.string(from: model.startTime),
					isCurrentDay: Calendar.current.isDateInToday(model.startTime)
				)
			}
		}

		let timeHeaderRegistration = UICollectionView.SupplementaryRegistration<TimeColumnHeader>(
			elementKind: TimeColumnHeader.identifier
		) { view, _, indexPath in
			if let model = dataSource.itemIdentifier(for: indexPath)?.first {
				view.configure(
					startTime: Formatters.timeFormatter.string(from: model.startTime),
					endTime: Formatters.timeFormatter.string(from: model.endTime)
				)
			}
		}

		let horizontalTimeHeaderRegistration = UICollectionView.SupplementaryRegistration<HorizontalTimeColumnHeader>(
			elementKind: HorizontalTimeColumnHeader.identifier
		) { view, _, indexPath in

			let allSections = dataSource.snapshot().sectionIdentifiers
			let cellModels = allSections.flatMap({ $0.cellModels }).flatMap { $0 }

			let startTimes = cellModels.map(\.startTime).map(Formatters.timeFormatter.string(from:)).unique.sorted()
			let endTimes = cellModels.map(\.endTime).map(Formatters.timeFormatter.string(from:)).unique.sorted()

			let startEndTimes = zip(startTimes, endTimes).map {
				return ($0.0, $0.1)
			}

			view.configure(startEndTimes: startEndTimes)
		}

		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			switch kind {
				case DayColumnHeaderView.identifier:
					collectionView.dequeueConfiguredReusableSupplementary(using: dayHeaderRegistration, for: indexPath)

				case HorizontalTimeColumnHeader.identifier:
					collectionView.dequeueConfiguredReusableSupplementary(using: horizontalTimeHeaderRegistration, for: indexPath)

				case TimeColumnHeader.identifier:
					collectionView.dequeueConfiguredReusableSupplementary(using: timeHeaderRegistration, for: indexPath)

				default:
					nil
			}
		}

		return (collection, dataSource)
	}
}
