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

	private func makeVerticalSection(_ section: TimetableModel.Section) -> NSCollectionLayoutSection {
		let horizontalGroups: [NSCollectionLayoutGroup] = section.groups.enumerated().map { index, group in
			let count = group.cellModels.count

			let timeSupplementaryItem = NSCollectionLayoutSupplementaryItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(estimatedItemHeight)
				),
				elementKind: TimeColumnHeader.identifier + "_\(index)",
				containerAnchor: NSCollectionLayoutAnchor(edges: .leading),
				itemAnchor: NSCollectionLayoutAnchor(edges: .trailing, absoluteOffset: CGPoint(x: -8.0, y: 0.0))
			)
			timeSupplementaryItem.zIndex = -1

			let horizontalGroup = NSCollectionLayoutGroup.horizontal(
				layoutSize: .init(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .estimated(estimatedItemHeight)
				),
				subitems: group.cellModels.enumerated().map { subindex, _ in
					NSCollectionLayoutItem(
						layoutSize: NSCollectionLayoutSize(
							widthDimension: .fractionalWidth(1.0 / CGFloat(count)),
							heightDimension: .estimated(estimatedItemHeight)
						),
						supplementaryItems: subindex == 0 ? [timeSupplementaryItem] : []
					)
				}
			)
			horizontalGroup.interItemSpacing = .fixed(itemSpacing)

			return horizontalGroup
		}

		let verticalGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: .init(
				widthDimension: .fractionalWidth(0.8),
				heightDimension: .estimated(estimatedItemHeight)
			),
			subitems: horizontalGroups
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
		_ section: TimetableModel.Section,
		maxNumberOfPairs: Int
	) -> NSCollectionLayoutSection {
		let horizontalGroups = section.groups.map { group in
			let count = group.cellModels.count
			let horizontalGroup = NSCollectionLayoutGroup.horizontal(
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
			horizontalGroup.interItemSpacing = .fixed(itemSpacing)
			return horizontalGroup
		}

		let verticalGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: .init(
				widthDimension: .absolute(100),
				heightDimension: .fractionalHeight(0.9)
			),
			subitems: horizontalGroups
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
		dataSource: @escaping () -> UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>
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

		let timeHeaderRegistrations = (0..<10)
			.map { TimeColumnHeader.identifier + "_\($0)" }
			.reduce(into: [String: UICollectionView.SupplementaryRegistration<TimeColumnHeader>]()) { registrations, kind in
				let registration = UICollectionView.SupplementaryRegistration<TimeColumnHeader>(
					elementKind: kind
				) { view, _, indexPath in
					if let model = dataSource.itemIdentifier(for: indexPath) {
						view.configure(
							startTime: Formatters.timeFormatter.string(from: model.startTime),
							endTime: Formatters.timeFormatter.string(from: model.endTime)
						)
					}
				}

				registrations[kind] = registration
			}

		let horizontalTimeHeaderRegistration = UICollectionView.SupplementaryRegistration<HorizontalTimeColumnHeader>(
			elementKind: HorizontalTimeColumnHeader.identifier
		) { view, _, indexPath in

			let allSections = dataSource.snapshot().sectionIdentifiers
			let cellModels = allSections.flatMap(\.groups).flatMap(\.cellModels)

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
					return collectionView.dequeueConfiguredReusableSupplementary(using: dayHeaderRegistration, for: indexPath)

				case HorizontalTimeColumnHeader.identifier:
					return collectionView.dequeueConfiguredReusableSupplementary(using: horizontalTimeHeaderRegistration, for: indexPath)

				default:
					let index = kind.split(separator: "_").last!.compactMap({ Int(String($0)) }).first!
					let indexPath = IndexPath(item: index, section: indexPath.section)
					return collectionView.dequeueConfiguredReusableSupplementary(
						using: timeHeaderRegistrations[kind]!,
						for: indexPath
					)
			}
		}

		return (collection, dataSource)
	}
}
