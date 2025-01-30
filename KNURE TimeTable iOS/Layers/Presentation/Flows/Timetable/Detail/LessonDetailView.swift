//
//  LessonDetailView.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 10.01.2025.
//  Copyright © 2025 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct LessonDetailView: View {

	let interactor: LessonDetailInteractor
	let identifier: String

	@State var viewModel: [ViewModel] = []
	@State var title: String = ""

	var body: some View {
		List {
			Text(title)
				.frame(maxWidth: .infinity, alignment: .center)
				.multilineTextAlignment(.center)
				.font(.largeTitle)
			ForEach(viewModel) { section in
				Section(header: Text(section.id)) {
					ForEach(section.sections) { detail in
						HStack {
							Text(detail.title)
							Spacer()
							Text(detail.detail)
						}
					}
				}
			}
		}
		.scrollIndicators(.hidden)
		.task {
			let response = await interactor.obtainContent(identifier)
			title = response.0
			viewModel = response.1
		}
	}
}

extension LessonDetailView {

	struct ViewModel: Identifiable {
		let id: String
		let sections: [ViewModel.Section]

		struct Section: Identifiable {
			let id: String
			let title: String
			let detail: String
		}
	}
}
