//
//  RootTabView.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 08.06.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct RootTabView: View {

	var body: some View {
		TabView {
			TimetableView()
				.tabItem { Label("Timetable", systemImage: "calendar") }
			Assembly.shared.makeItemsView()
				.tabItem { Label("Items", systemImage: "list.bullet") }
			Assembly.shared.makeSettingsView()
				.tabItem { Label("Settings", systemImage: "gearshape.fill") }
		}
	}
}
