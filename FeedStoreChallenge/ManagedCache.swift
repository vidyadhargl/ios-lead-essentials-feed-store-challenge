//
//  ManagedCache.swift
//  FeedStoreChallenge
//
//  Created by Vidyadhar LONARMATH on 15/07/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}
