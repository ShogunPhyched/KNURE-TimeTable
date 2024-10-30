//
//  Publishers.Entity.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 28/07/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import Combine
import CoreData

extension Publishers {

	final class Entity<T: NSFetchRequestResult & Convertable>: NSObject, NSFetchedResultsControllerDelegate {

		private let fetchResultsController: NSFetchedResultsController<T>
		private let context: NSManagedObjectContext

		fileprivate let subject: PassthroughSubject<[T.NewType], Never> = .init()

		init(
			request: NSFetchRequest<T>,
			context: NSManagedObjectContext,
			cacheName: String? = nil
		) {

			self.context = context
			fetchResultsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: context,
				sectionNameKeyPath: nil,
				cacheName: cacheName
			)

			super.init()

			fetchResultsController.delegate = self
		}

		// MARK: - NSFetchedResultsControllerDelegate

		func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
			context.perform { [weak self] in
				guard let self = self else { return }
				guard let objects = controller.fetchedObjects as? [T] else { return self.subject.send([]) }
				let result = objects.compactMap { $0.convert() }
				self.subject.send(result)
			}
		}
	}
}

extension Publishers.Entity: Publisher {

	typealias Output = [T.NewType]
	typealias Failure = Never

	func receive<S>(subscriber: S) where S: Subscriber,
		Publishers.Entity<T>.Failure == S.Failure,
		Publishers.Entity<T>.Output == S.Input {

			context.perform { [weak self] in
				guard let self = self else { return }

				do {
					try self.fetchResultsController.performFetch()
				} catch {
					self.subject.send([])
				}

				guard let objects = self.fetchResultsController.fetchedObjects else { return self.subject.send([]) }
				let result = objects.compactMap { $0.convert() }
				self.subject.send(result)
			}

		Subscribers.Entity<T>(publisher: self, subscriber: AnySubscriber(subscriber))
	}
}

extension Subscribers {

	final class Entity<T: NSFetchRequestResult & Convertable>: Subscription {
		private var publisher: Publishers.Entity<T>?
		private var cancellable: AnyCancellable?

		@discardableResult
		init(publisher: Publishers.Entity<T>, subscriber: AnySubscriber<[T.NewType], Never>) {
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
