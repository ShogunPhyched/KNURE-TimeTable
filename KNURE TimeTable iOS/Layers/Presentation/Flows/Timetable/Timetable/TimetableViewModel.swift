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
	var isVerticalMode: Bool = UserDefaults.standard.bool(forKey: "TimetableVerticalMode")

	var dataSource: UICollectionViewDiffableDataSource<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>!

	@MainActor func update() {
		update(with: TimetableViewModel.CollectionModel(sections: dataSource.snapshot().sectionIdentifiers), animated: false)
	}

	@MainActor func update(with model: TimetableViewModel.CollectionModel, animated: Bool) {
		var snapshot = NSDiffableDataSourceSnapshot<TimetableViewModel.CollectionModel.Section, [CompositionalLessonCell.Model]>()
		for section in model.sections {
			snapshot.appendSections([section])
			var items = section.cellModels
			if isVerticalMode {
				 for index in items.indices {
					 let item = items[index]
					 items[index] = item.filter { !$0.dummy }
				}
				items = items.filter { !$0.isEmpty }
			}
			snapshot.appendItems(items, toSection: section)
		}
		dataSource?.apply(snapshot, animatingDifferences: animated)
	}
}

extension TimetableViewModel {

	struct CollectionModel {

		let sections: [Section]

		struct Section: Hashable {

			let cellModels: [[CompositionalLessonCell.Model]]
		}
	}
}
