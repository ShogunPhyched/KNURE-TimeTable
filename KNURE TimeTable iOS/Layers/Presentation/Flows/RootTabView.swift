//
//  RootTabView.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 08.06.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct RootTabView: View {

	@State private var selectedTab: TabOption = .timetable

	enum TabOption: String, CaseIterable, Identifiable {
		case timetable = "Timetable"
		case items = "Items"
		case settings = "Settings"

		var id: String {
			self.rawValue
		}
	}

	var body: some View {
		switch UIDevice.current.userInterfaceIdiom {
			case .phone:
				TabView {
					TimetableView()
						.tabItem { Label("Timetable", systemImage: "calendar") }
					Assembly.shared.makeItemsView()
						.tabItem { Label("Items", systemImage: "list.bullet") }
					Assembly.shared.makeSettingsView()
						.tabItem { Label("Settings", systemImage: "gearshape.fill") }
				}
			default:
				NavigationSplitView {
					List(TabOption.allCases) { tab in
						Button(tab.rawValue) {
							selectedTab = tab
						}
					}
				} detail: {
					switch selectedTab {
						case .timetable:
							TimetableView()
						case .items:
							Assembly.shared.makeItemsView()
						case .settings:
							Assembly.shared.makeSettingsView()
					}
				}
		}
	}
}
