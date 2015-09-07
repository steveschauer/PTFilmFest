////
//  MasterViewController.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 8/7/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var suspendUpdates = false


    override func awakeFromNib() {
        super.awakeFromNib()
        preferredContentSize = CGSize(width: 320.0, height: 9/16 * 320)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView:", name:"updateTableView", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkForUpdates:", name:"checkForUpdates", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        
        title = "PTFilmFest"
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }
    
    func checkForUpdates(notification:NSNotification) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let defaults = NSUserDefaults.standardUserDefaults()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let now = NSDate()
        var shouldUpdate = true
        
        if let lastCheckedString = defaults.stringForKey("lastCheckedString"), let lastCheckedTime = dateFormatter.dateFromString(lastCheckedString) {
            let elapsedTime = now.timeIntervalSinceDate(lastCheckedTime)
            shouldUpdate = elapsedTime > (60 * 60 * 2)
        }
        
        if shouldUpdate == true {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UpdateViewController = storyboard.instantiateViewControllerWithIdentifier("updateViewController") as! UpdateViewController
            presentViewController(vc, animated: true, completion: nil)
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // on iPad, we need to kickstart the detailViewController
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            performSegueWithIdentifier("showDetail", sender: self)
        }
        
        defaults.setObject(dateFormatter.stringFromDate(now), forKey:"lastCheckedString")
    }
    
    func updateTableView(notification: NSNotification) {
        tableView.reloadData()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            performSegueWithIdentifier("showDetail", sender: self)
        }
    }

    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            var indexPath = tableView.indexPathForSelectedRow()
            
            // more iPad funnyness
            if indexPath == nil {
                indexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
            
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            if (fetchedResultsController.fetchedObjects!.count > 0) {
                let object = fetchedResultsController.objectAtIndexPath(indexPath!) as! ScheduleItem
                controller.item = object
            }
            
            controller.masterVC = self
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            title = ""
            
        }
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView=UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.alpha = 0.9
        var label = UILabel(frame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.font = UIFont(name:"Helvetice Neue", size:16.0)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.blackColor()
        headerView.addSubview(label)
        return headerView
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            var title = "PT Film Festival"
            var day = currentSection.name!
            switch currentSection.name! {
            case "Friday":
                title = "\(title) - \(day) Sept. 25"
            case "Saturday":
                title = "\(title) - \(day) Sept. 26"
            case "Sunday":
                title = "\(title) - \(day) Sept. 27"
            default:
                title = "\(title) - \(day)"
            }
            return title
            }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let imageHeight =  9/16 * view.frame.size.width //UIScreen.mainScreen().bounds.size.width
        return imageHeight
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    func configureCell(cell: TableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let item:ScheduleItem = fetchedResultsController.objectAtIndexPath(indexPath) as! ScheduleItem
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.stringFromDate(item.date)
        
        if let event = item.event {
            let venue = item.venue
            
            cell.imageViewForCell.image = UIImage(data: event.imageData)//UIImage(named:"\(item.event.name)_small")
            cell.eventTitleLabel.text = event.title
            cell.timeAndVenueLabel.text = "\(dateString) \(venue!.title)"
            
            cell.likeImageView.image = event.like == true ? UIImage(named: "heart-full") : UIImage(named: "heart-empty")
//            if (event.like == true) {
//                let image = UIImage(named: "heart-full.png") as UIImage!
//                cell.likeImageView.setImage(image, forState: UIControlState.Normal)
//            } else {
//                cell.likeImageView.image = UIImage(named:"heart-empty")
//            }
        }
        
    }
    
    func moveToAdjacentItem(item: ScheduleItem?, forward: Bool) -> ScheduleItem? {
        if let indexPath = tableView.indexPathForSelectedRow() {
            
            var newIndexPath:NSIndexPath = indexPath  // assignment is to keep the compiler quiet only

            var sectionCount = tableView.numberOfSections()
            var rowsInSection = tableView.numberOfRowsInSection(indexPath.section)
            
            if (forward) {
                if indexPath.row == rowsInSection-1 {
                    if indexPath.section == sectionCount-1 {
                        return nil
                    } else {
                        newIndexPath = NSIndexPath(forRow: 0, inSection:indexPath.section+1)
                    }
                } else {
                    newIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection:indexPath.section)
                }
            } else {
                if indexPath.section == 0 && indexPath.row == 0 {
                    return nil
                } else {
                    if indexPath.row == 0 {
                        rowsInSection = tableView.numberOfRowsInSection(indexPath.section-1)
                        newIndexPath = NSIndexPath(forRow: rowsInSection-1, inSection:indexPath.section-1)
                    } else {
                        newIndexPath = NSIndexPath(forRow: indexPath.row-1, inSection:indexPath.section)
                    }
                }
            }
            
            if let currentItem = fetchedResultsController.objectAtIndexPath(newIndexPath) as? ScheduleItem {
                tableView.selectRowAtIndexPath(newIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                return currentItem
            }
            
        }
        return nil
    }
    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("ScheduleItem", inManagedObjectContext: managedObjectContext!)
        fetchRequest.entity = entity
        
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: true)
        let sortDescriptors = [sortDescriptor1]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "day", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        tableView.beginUpdates()
//    }
//
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//            case .Insert:
//                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//            case .Delete:
//                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//            default:
//                return
//        }
//    }
//
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//            case .Insert:
//                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            case .Delete:
//                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//            case .Update:
//                configureCell(tableView.cellForRowAtIndexPath(indexPath!)! as! TableViewCell, atIndexPath: indexPath!)
//            case .Move:
//                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            default:
//                return
//        }
//    }
//
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }

    
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if suspendUpdates == false {
            tableView.reloadData()
            // on iPad, we need to kickstart the detailViewController
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
        }
    }
    

}

