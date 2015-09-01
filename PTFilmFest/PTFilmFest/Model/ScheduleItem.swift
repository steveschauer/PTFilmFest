//
//  ScheduleItem.swift
//  
//
//  Created by Steve Schauer on 6/29/15.
//
//

import Foundation
import CoreData

@objc(ScheduleItem)
class ScheduleItem: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var day: String
    @NSManaged var event: Event?
    @NSManaged var venue: Venue?

}
