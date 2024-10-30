//
//  CalendarLayout.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import UIKit

protocol CalendarLayoutDataSource: AnyObject {
}

final class CalendarLayout: UICollectionViewFlowLayout {

	unowned var datasource: CalendarLayoutDataSource

	init(datasource: CalendarLayoutDataSource) {
		self.datasource = datasource
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
