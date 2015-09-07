//
//  Event.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 8/30/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import Foundation
import CoreData

@objc(Event)
class Event: NSManagedObject {

    @NSManaged var bodyText: String
    @NSManaged var director: String
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var webSite: String
    @NSManaged var runTime: String
    @NSManaged var year: String
    @NSManaged var imageURLString: String
    @NSManaged var imageData: NSData
    @NSManaged var country: String
    @NSManaged var scheduleItem: NSSet
    @NSManaged var like: Bool

}
