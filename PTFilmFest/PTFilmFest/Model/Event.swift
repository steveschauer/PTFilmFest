//
//  Event.swift
//  
//
//  Created by Steve Schauer on 6/29/15.
//
//

import Foundation
import CoreData

enum eventType:Int {
    case Main = 0, Sub, Special
}

@objc(Event)
class Event: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var bodyText: String
    @NSManaged var director: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var mainFeature: String
    @NSManaged var webSite: String
    @NSManaged var scheduleItem: NSSet

}
