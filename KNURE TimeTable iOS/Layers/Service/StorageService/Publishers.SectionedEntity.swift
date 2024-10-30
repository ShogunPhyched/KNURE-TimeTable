//
//  Publishers.SectionedEntity.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 13.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import Combine
import CoreData

extension Publishers {

	final class SectionedEntity<T: NSFetchRequestResult & Convertable>: NSObject, NSFetchedResultsControllerDelegate {

		struct Section: Sendable {
			let name: String
			let items: [T.NewType]
		}

		private let fetchResultsController: NSFetchedResultsController<T>
		private let context: NSManagedObjectContext

		fileprivate let subject: PassthroughSubject<[Section], Never> = .init()

		init(
			request: NSFetchRequest<T>,
			context: NSManagedObjectContext,
			sectionNameKeyPath: String? = nil,
			cacheName: String? = nil
		) {

			self.context = context
			fetchResultsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: context,
				sectionNameKeyPath: sectionNameKeyPath,
				cacheName: cacheName
			)

			super.init()

			fetchResultsController.delegate = self
		}

		// MARK: - NSFetchedResultsControllerDelegate

		func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
			context.perform { [weak self] in
				guard let self = self else { return }

				guard let sections = controller.sections else { return self.subject.send([]) }

				var result: [Section] = []

				for section in sections {
					guard let objects = section.objects as? [T] else { continue }
					result.append(
						Section(
							name: section.name,
							items: objects.compactMap { $0.convert() }
						)
					)
				}

				self.subject.send(result)
			}
		}
	}
}

extension Publishers.SectionedEntity: Publisher {

	typealias Output = [Section]
	typealias Failure = Never

	func receive<S>(subscriber: S) where S: Subscriber,
		Publishers.SectionedEntity<T>.Failure == S.Failure,
		Publishers.SectionedEntity<T>.Output == S.Input {

		context.perform { [weak self] in
			guard let self = self else { return }

			do {
				try self.fetchResultsController.performFetch()
			} catch {
				self.subject.send([])
			}

			if let sections = self.fetchResultsController.sections {

				var result: [Section] = []

				for section in sections {
					guard let objects = section.objects as? [T] else { continue }
					result.append(
						Section(
							name: section.name,
							items: objects.compactMap { $0.convert() }
						)
					)
				}

				self.subject.send(result)
			}
		}

		Subscribers.SectionedEntity<T>(publisher: self, subscriber: AnySubscriber(subscriber))
	}
}

extension Subscribers {

	final class SectionedEntity<T: NSFetchRequestResult & Convertable>: Subscription {
		private var publisher: Publishers.SectionedEntity<T>?
		private var cancellable: AnyCancellable?

		@discardableResult
		init(
			publisher: Publishers.SectionedEntity<T>,
			subscriber: AnySubscriber<[Publishers.SectionedEntity<T>.Section], Never>
		) {
			self.publisher = publisher

			subscriber.receive(subscription: self)

			cancellable = publisher.subject.sink(receiveCompletion: { completion in
				subscriber.receive(completion: completion)
			}, receiveValue: { value in
				_ = subscriber.receive(value)
			})
		}

		func request(_ demand: Subscribers.Demand) { }

		func cancel() {
			cancellable?.cancel()
			cancellable = nil
			publisher = nil
		}
	}
}
