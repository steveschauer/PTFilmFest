//
//  AppDelegate.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 6/29/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        loadDatabase()
        
        let device = UIDevice()
        let screenRect = UIScreen.mainScreen().bounds.size.width
        println(screenRect)
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = self.managedObjectContext
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.item == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "org.steveschauer.PTFilmFest" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("PTFilmFest", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("PTFilmFest.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: database creation
    func loadDatabase () {
        let context = self.managedObjectContext!;
        context.undoManager = nil;
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        
        // MARK: Venues
        var venueRose = NSEntityDescription.insertNewObjectForEntityForName("Venue", inManagedObjectContext: context) as! Venue
        venueRose.name = "rose"
        venueRose.title = "Rose Theatre"
        venueRose.address = "235 Taylor St."
        venueRose.webSite = "http://www.rosetheatre.com"
        venueRose.imageName = ""
        venueRose.latitude = 48.114840
        venueRose.longitude = -122.757035
        venueRose.bodyText = "Port Townsend enjoyed a lively theater scene before the dawn of the twentieth century.  The Palace Theatre, The Standard, and the Learned Opera House showcased local talent and traveling vaudeville troupes 'of the highest caliber.'  The Rose, which opened around the corner on Water Street in 1907, continued this tradition but added a recent invention to its repertoire: moving pictures.  In December 1908 the Rose moved to its current location in Taylor Street.\n\nTom Mix, Mary Pickford, Douglas Fairbanks, Lillian Gish, and countless other Hollywood stars graced the Rose Theatre's silver screen for more than fifty years before it closed its doors November 8, 1958 with the potboiler High School Confidential.  The Rose reopened July 11, 1992, and with the addition of the Rosebud Cinema three years later, has become one of the most treasured features of Port Townsend's National Historic District.\n\nSo, experience a film at the Rose, where the popcorn is fresh, the butter is real, the sound is superb, and every show is personally introduced by our host."
        
        var venueRosebud = NSEntityDescription.insertNewObjectForEntityForName("Venue", inManagedObjectContext: context) as! Venue
        venueRosebud.name = "rosebud"
        venueRosebud.title = "Rosebud Theatre"
        venueRosebud.address = "235 Taylor St."
        venueRosebud.webSite = "http://www.rosetheatre.com"
        venueRosebud.imageName = ""
        venueRosebud.latitude = 48.114840
        venueRosebud.longitude = -122.757035
        venueRosebud.bodyText = "Port Townsend enjoyed a lively theater scene before the dawn of the twentieth century.  The Palace Theatre, The Standard, and the Learned Opera House showcased local talent and traveling vaudeville troupes 'of the highest caliber.'  The Rose, which opened around the corner on Water Street in 1907, continued this tradition but added a recent invention to its repertoire: moving pictures.  In December 1908 the Rose moved to its current location in Taylor Street.\n\nTom Mix, Mary Pickford, Douglas Fairbanks, Lillian Gish, and countless other Hollywood stars graced the Rose Theatre's silver screen for more than fifty years before it closed its doors November 8, 1958 with the potboiler High School Confidential.  The Rose reopened July 11, 1992, and with the addition of the Rosebud Cinema three years later, has become one of the most treasured features of Port Townsend's National Historic District.\n\nSo, experience a film at the Rose, where the popcorn is fresh, the butter is real, the sound is superb, and every show is personally introduced by our host."
        
        var venueTaylor = NSEntityDescription.insertNewObjectForEntityForName("Venue", inManagedObjectContext: context) as! Venue
        venueTaylor.name = "taylor"
        venueTaylor.title = "Taylor Street"
        venueTaylor.address = ""
        venueTaylor.webSite = ""
        venueTaylor.imageName = ""
        venueTaylor.latitude = 48.114740
        venueTaylor.longitude = -122.756826
        venueTaylor.bodyText = "Grab a seat on a straw bale and enjoy a movie under the stars!"
        
        // MARK: Events and Items

        var event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
        event.name = "cream"
        event.type = eventType.Sub.rawValue
        event.title = "Cream City Sound Check: Allen Stone"
        event.director = "USA/2014/14 min. Director: Ryan Sarnowski"
        event.webSite = ""
        event.imageName = "cream.png"
        event.bodyText = "Allen Stone gets some science dropped on him at the Microphone Museum and fills his belly at Speed Queen Bar-B-Que before doing a radio interview with 88Nine Radio Milwaukee and rocking two amazing sets at Turner Hall."
        
        var item1 = NSEntityDescription.insertNewObjectForEntityForName("ScheduleItem", inManagedObjectContext: context) as! ScheduleItem
        item1.date = dateFormatter.dateFromString("09/19/2015 09:00:00")!
        item1.day = "Saturday"
        item1.event = event;
        item1.venue = venueRosebud

        var item2 = NSEntityDescription.insertNewObjectForEntityForName("ScheduleItem", inManagedObjectContext: context) as! ScheduleItem
        item2.date = dateFormatter.dateFromString("09/20/2015 21:30:00")!
        item2.day = "Sunday"
        item2.event = event;
        item2.venue = venueRose
        
        saveContext()
//------------------------------------------------------------------
      
        event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
        event.name = "ballad"
        event.type = eventType.Main.rawValue
        event.title = "The Ballad of Shovels and Rope"
        event.director = "USA/2014/72 min. Director: Jace Freeman"
        event.webSite = "http://www.theballadofshovelsandrope.com/"
        event.imageName = ""
        event.bodyText = "Make it work with what you've got. Two guitars, a junkyard drum kit, a handful of harmonicas, voices, and above all... songs. The Ballad of Shovels and Rope captures the tours and detours of a husband and wife as they create and release the critically acclaimed album “O’ Be Joyful.” Follow Cary Ann Hearst and Michael Trent as they travel from town to town, living out of their van with their hound dog and recording their album wherever they can. From working for tips to becoming 'Emerging Artist of the Year,' the family duo uses ingenuity and hard work to create something out of nothing."
        
        item1 = NSEntityDescription.insertNewObjectForEntityForName("ScheduleItem", inManagedObjectContext: context) as! ScheduleItem
        item1.date = dateFormatter.dateFromString("09/19/2015 09:00:00")!
        item1.day = "Saturday"
        item1.event = event;
        item1.venue = venueRosebud

        item2 = NSEntityDescription.insertNewObjectForEntityForName("ScheduleItem", inManagedObjectContext: context) as! ScheduleItem
        item2.date = dateFormatter.dateFromString("09/20/2015 21:30:00")!
        item2.day = "Sunday"
        item2.event = event;
        item2.venue = venueRose
        
        saveContext()
//------------------------------------------------------------------
        
        
        event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
        event.name = "woman"
        event.type = eventType.Main.rawValue
        event.title = "For a Woman (Pour une Femme)"
        event.director = "France/2013/110 min. Director: Diane Kurys"
        event.webSite = "http://www.filmmovement.com/filmcatalog/index.asp?MerchandiseID=361"
        event.imageName = ""
        event.bodyText = "After her mother's death, Anne discovers old photos and letters that convince her to take a closer look at the life of her parents, Michel and Léna, who met in the concentration camps during World War II. Liberated, they moved to France to begin a new life together. Anne's research into their Jewish history and their ties to Lyon's Communist Party reveals the existence of her uncle Jean, who had never been mentioned. As she gradually closes in on the discovery she didn't know she was looking for, her father grows ever more ill, and may take the family secret to his grave. In a journey that stretches from post-war France to the 1980s, Anne's destiny intertwines with her father's past until they form a single, unforgettable story. "
        
        item1 = NSEntityDescription.insertNewObjectForEntityForName("ScheduleItem", inManagedObjectContext: context) as! ScheduleItem
        item1.date = dateFormatter.dateFromString("09/18/2015 09:00:00")!
        item1.day = "Friday"
        item1.event = event;
        item1.venue = venueTaylor
        
        item2 = NSEntityDescription.insertNewObjectForEntityForName("ScheduleItem", inManagedObjectContext: context) as! ScheduleItem
        item2.date = dateFormatter.dateFromString("09/20/2015 21:00:00")!
        item2.day = "Sunday"
        item2.event = event;
        item2.venue = venueRose
        
        
        saveContext()
    }

}

