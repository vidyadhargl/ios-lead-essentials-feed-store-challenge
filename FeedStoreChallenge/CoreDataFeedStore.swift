//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				let fetchRequest = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				fetchRequest.returnsObjectsAsFaults = false

				if let cache = try context.fetch(fetchRequest).first {
					let feed = cache.feed
						.compactMap { $0 as? ManagedFeedImage }
						.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url) }
					completion(.found(feed: feed, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}

			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			do {
				let fetchRequest = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				fetchRequest.returnsObjectsAsFaults = false
				if let cache = try context.fetch(fetchRequest).first {
					context.delete(cache)
				}

				let newCache = ManagedCache(context: context)
				newCache.timestamp = timestamp
				newCache.feed = NSOrderedSet(array: feed.map { feed in
					let managedFeedImage = ManagedFeedImage(context: context)
					managedFeedImage.id = feed.id
					managedFeedImage.imageDescription = feed.description
					managedFeedImage.location = feed.location
					managedFeedImage.url = feed.url
					//managedFeedImage.cache = newCache
					return managedFeedImage
				})

				try context.save()
				completion(nil)

			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				request.returnsObjectsAsFaults = false
				if let cache = try context.fetch(request).first {
					context.delete(cache)
					try context.save()
				}
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	// MARK: - HELPERS
	func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		context.perform { [context] in
			action(context)
		}
	}
}
