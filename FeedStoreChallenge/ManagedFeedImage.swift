//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Vidyadhar LONARMATH on 15/07/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedFeedImage)

class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache

	var local: LocalFeedImage {
		LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}

	static func images(with feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: feed.map { local in
			let image = ManagedFeedImage(context: context)
			image.id = local.id
			image.imageDescription = local.description
			image.location = local.location
			image.url = local.url
			return image
		})
	}
}
