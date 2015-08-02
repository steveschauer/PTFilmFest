//
//  Venue.swift
//  
//
//  Created by Steve Schauer on 6/29/15.
//
//

import Foundation
import CoreData

@objc(Venue)
class Venue: NSManagedObject {

    @NSManaged var address: String
    @NSManaged var bodyText: String
    @NSManaged var imageName: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var webSite: String
    @NSManaged var scheduleItem: NSSet

}
