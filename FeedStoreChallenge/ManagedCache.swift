//
//  ManagedCache.swift
//  FeedStoreChallenge
//
//  Created by Vidyadhar LONARMATH on 15/07/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedCache)
final class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	var localFeed: [LocalFeedImage] {
		feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}

	static func find(in context: NSManagedObjectContext) throws -> Self? {
		let fetchRequest = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		fetchRequest.returnsObjectsAsFaults = false
		return try context.fetch(fetchRequest).first as? Self
	}

	static func newUniqueItem(in context: NSManagedObjectContext) throws -> ManagedCache {
		try ManagedCache.find(in: context).map(context.delete)
		return ManagedCache(context: context)
	}
}
