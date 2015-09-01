//
//  Venue.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 8/30/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import Foundation
import CoreData

@objc(Venue)
class Venue: NSManagedObject {

    @NSManaged var address: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var scheduleItem: NSSet

}
