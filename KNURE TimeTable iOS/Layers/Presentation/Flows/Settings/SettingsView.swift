//
//  SettingsView.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 09.06.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

	@AppStorage("TimetableVerticalMode") var isVerticalMode: Bool = false

	var body: some View {
		NavigationStack {
			List {
				Toggle(isOn: $isVerticalMode) {
					Text("Вертикальная прокрутка")
				}
			}
			.navigationTitle("Settings")
		}
	}
}
