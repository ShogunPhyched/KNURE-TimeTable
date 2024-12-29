//
//  TimetableViewModel.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine
import UIKit

final class TimetableViewModel {
	@Published var addedItems: [Item] = []
	var scrollDirection: UICollectionView.ScrollDirection = .horizontal
// UserDefaults.standard.bool(forKey: "TimetableVerticalMode") ? .vertical : .horizontal

	var dataSource: UICollectionViewDiffableDataSource<TimetableModel.Section, LessonCollectionViewCellModel>?

	@MainActor func update(with model: TimetableModel, animated: Bool) {
		var snapshot = NSDiffableDataSourceSnapshot<TimetableModel.Section, LessonCollectionViewCellModel>()
		for section in model.sections {
			snapshot.appendSections([section])
			snapshot.appendItems(section.groups.flatMap(\.cellModels), toSection: section)
		}
		dataSource?.apply(snapshot, animatingDifferences: animated)
	}
}

struct TimetableModel {

	let sections: [Section]

	struct Section: Hashable {

		let groups: [Group]

		struct Group: Hashable {
			let cellModels: [LessonCollectionViewCellModel]
		}
	}
}
