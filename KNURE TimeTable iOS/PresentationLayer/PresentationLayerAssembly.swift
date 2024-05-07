//
//  PresentationLayerAssembly.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

struct PresentationLayerAssembly: Assembly {

	func assemble(container: Container) {
		let assembies: [Assembly] = [
			TimetableAssembly(),

			ItemsAssembly(),
			AddItemsAssembly()
		]

		assembies.forEach { $0.assemble(container: container) }

		configureFactories(container)
	}

	private func configureFactories(_ container: Container) {
		container.register(ViewControllerFactory.self, in: .graph) { _ in
			ViewControllerFactoryImpl()
		}
	}
}
