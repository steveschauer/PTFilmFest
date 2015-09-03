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
        self.preferredContentSize = CGSize(width: 320.0, height: 9/16 * 320)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PTFilmFest"
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCompleted:", name:"updateFestivalDataComplete", object: nil)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.didUpdateFestivalData == false {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UpdateViewController = storyboard.instantiateViewControllerWithIdentifier("updateViewController") as! UpdateViewController
            self.presentViewController(vc, animated: true, completion: nil)
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // on iPad, we need to kickstart the detailViewController
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    func updateCompleted(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.tableView.reloadData()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! ScheduleItem
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.item = object
                controller.managedObjectContext = self.managedObjectContext
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                self.title = ""
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView=UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        headerView.backgroundColor = UIColor.lightGrayColor()
        headerView.alpha = 0.9
        var label = UILabel(frame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18))
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.font = UIFont(name:"Helvetice Neue", size:16.0)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        headerView.addSubview(label)
        return headerView
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            let title = "PT Film Fest - \(currentSection.name!)"
            return title
            }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let imageHeight =  9/16 * self.view.frame.size.width //UIScreen.mainScreen().bounds.size.width
        return imageHeight
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    func configureCell(cell: TableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let item:ScheduleItem = self.fetchedResultsController.objectAtIndexPath(indexPath) as! ScheduleItem
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm a"
        let dateString = dateFormatter.stringFromDate(item.date)
        
        if let event = item.event {
        let venue = item.venue
        
        cell.imageViewForCell.image = UIImage(data: event.imageData)//UIImage(named:"\(item.event.name)_small")
        cell.eventTitleLabel.text = event.title
        cell.timeAndVenueLabel.text = "\(dateString) \(venue!.title)"
        }
        
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("ScheduleItem", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: true)
        //let sortDescriptor2 = NSSortDescriptor(key: "venue", ascending: true)
        //let sortDescriptor3 = NSSortDescriptor(key: "event.type", ascending: true)
        let sortDescriptors = [sortDescriptor1]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "day", cacheName: "Master")
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
//        self.tableView.beginUpdates()
//    }
//
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//            case .Insert:
//                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//            case .Delete:
//                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
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
//                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)! as! TableViewCell, atIndexPath: indexPath!)
//            case .Move:
//                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
//                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
//            default:
//                return
//        }
//    }
//
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.endUpdates()
//    }

    
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // In the simplest, most efficient, case, reload the table view.
        if suspendUpdates == false {
            self.tableView.reloadData()
            // on iPad, we need to kickstart the detailViewController
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
        }
    }
    

}

