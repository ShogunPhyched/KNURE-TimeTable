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
		environment: NSCollectionLayoutEnvironment,
		maxNumberOfPairs: Int
	) -> NSCollectionLayoutSection {
		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .absolute(100.0),
				heightDimension: .fractionalHeight(1.0)
			),
			repeatingSubitem: NSCollectionLayoutItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(1.0 / CGFloat(maxNumberOfPairs))
				)
			),
			count: section.cellModels.count
		)
		group.interItemSpacing = .fixed(itemSpacing)
		group.contentInsets = NSDirectionalEdgeInsets(
			top: environment.container.effectiveContentSize.height * 0.1,
			leading: 0,
			bottom: 0,
			trailing: 0
		)

		let section = NSCollectionLayoutSection(group: group)

		let header = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .absolute(100.0),
				heightDimension: .fractionalHeight(0.1)
			),
			elementKind: DayColumnHeaderView.identifier,
			alignment: .top
		)

		section.boundarySupplementaryItems = [header]

		return section
	}

	func makeLayout(
		scrollDirection: () -> UICollectionView.ScrollDirection,
		dataSource: @escaping () -> UICollectionViewDiffableDataSource<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>
	) -> UICollectionViewCompositionalLayout {
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.scrollDirection = scrollDirection()
		configuration.interSectionSpacing = itemSpacing
		configuration.contentInsetsReference = .automatic
		if configuration.scrollDirection == .horizontal {
			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: .init(
					widthDimension: .absolute(60.0),
					heightDimension: .fractionalHeight(0.9)
				),
				elementKind: HorizontalTimeColumnHeader.identifier,
				alignment: .bottomLeading
			)
			header.pinToVisibleBounds = true
			header.zIndex = 2
			configuration.boundarySupplementaryItems = [header]
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
					let pairNumbers = allSections.flatMap(\.cellModels).flatMap({ $0 }).map(\.number)
					let maxNumberOfPairs = pairNumbers.max() ?? 1
					let minNumberOfPairs = pairNumbers.min() ?? 0
					return self.makeHorizontalSection(
						itemSection,
						environment: environment,
						maxNumberOfPairs: abs(minNumberOfPairs - maxNumberOfPairs) + 1
					)

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
