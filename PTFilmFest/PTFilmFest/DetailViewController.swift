//
//  DetailViewController.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 8/7/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapPin : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class DetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var masterVC: MasterViewController?
    var item: ScheduleItem?
    
    var locationManager: CLLocationManager? = nil
    var fullMapRect: CGRect? = nil
    var shouldUpdateTableViewOnExit = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var eventDetailsLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var venueNameButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeAction(sender: UIButton) {
        if let item = item, let event = item.event {
            if event.like == true {
                let image = UIImage(named: "heart-empty.png") as UIImage!
                likeButton.setBackgroundImage(image, forState: UIControlState.Normal)
                event.like = false
            } else {
                let image = UIImage(named: "heart-full.png") as UIImage!
                likeButton.setBackgroundImage(image, forState: UIControlState.Normal)
                event.like = true
            }
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.updateLike(event)
            shouldUpdateTableViewOnExit = true
        }
        
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        
        //navigationController?.interactivePopGestureRecognizer.enabled = false;
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeft:")
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "handleSwipeRight:")
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        mapView.hidden = true
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        bodyTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fullMapRect = mapView.frame
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad && shouldUpdateTableViewOnExit {
            NSNotificationCenter.defaultCenter().postNotificationName("updateTableView", object: nil)
            shouldUpdateTableViewOnExit = false
        }
    }
    
    func configureView() {
        if let item = item, let event = item.event, let venue = item.venue {
            
            mapButton.layer.borderWidth=1.0
            mapButton.layer.borderColor=UIColor.lightGrayColor().CGColor
            mapButton.layer.cornerRadius = 4.0
            
            bodyTextView.layer.borderWidth=1.0
            bodyTextView.layer.borderColor=UIColor.lightGrayColor().CGColor
            bodyTextView.layer.cornerRadius = 4.0
            bodyTextView.textContainerInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
            
            venueNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            venueNameButton.setTitle(venue.title, forState: UIControlState.Normal)
            
            title = event.title
            
            imageView.image = UIImage(data: event.imageData)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let dateString = dateFormatter.stringFromDate(item.date)
            dateAndTimeLabel!.text = "\(item.day) \(dateString)"
            eventDetailsLabel!.text = "\(event.director)     \(event.country) \(event.year), \(event.runTime) minutes"
            
            bodyTextView.text = event.bodyText
            
            if (event.like == true) {
                let image = UIImage(named: "heart-full.png") as UIImage!
                likeButton.setBackgroundImage(image, forState: UIControlState.Normal)
            } else {
                let image = UIImage(named: "heart-empty.png") as UIImage!
                likeButton.setBackgroundImage(image, forState: UIControlState.Normal)
            }
            
            
        }
    }
    
    // MARK: - Segues
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if identifier == "showWebView" {
            if item!.event!.webSite == "" {
                return false
            }
        }
        return true
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWebView" {            
            let controller = segue.destinationViewController as! WebViewController
            controller.urlString  = item!.event!.webSite
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.title = item!.event!.title
        }
        
    }
    
    
    // MARK: - Gesture recognizers
    
    func handleSwipeLeft(sender: UISwipeGestureRecognizer) {
        handleSwipeGesture(true)
    }
    
    func handleSwipeRight(sender: UISwipeGestureRecognizer) {
        handleSwipeGesture(false)
    }
    
    func handleSwipeGesture(forward: Bool) {
        if let newItem = masterVC?.moveToAdjacentItem(item, forward: forward) {
            self.item = newItem
            self.configureView()
            self.view.alpha = 1.0
        }
    }
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        // animate mapView unZoom
        view.removeGestureRecognizer(sender)
        let endRect = mapButton.frame
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.mapView.frame = endRect
            }, completion:
            {
                (value: Bool) in
                self.mapView.hidden = true
        })
    }
    
    // MARK: Map Functions

    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            if status == CLAuthorizationStatus.AuthorizedWhenInUse {
                locationManager!.startUpdatingLocation()
            }
    }
    
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
            println(error)
    }

    @IBAction func showMap(sender: UIButton) {
        // animate mapView zoom
        configureMapView()
        let endRect = fullMapRect!
        mapView.frame = mapButton.frame
        mapView.hidden = false
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.mapView.frame = endRect
            }, completion: nil)
        var tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func configureMapView() {
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 10.0
        
        mapView.removeAnnotations(mapView.annotations)
        
        let eventCoordinate = CLLocationCoordinate2DMake(item!.venue!.latitude.doubleValue, item!.venue!.longitude.doubleValue)
        let annotation = MapPin.self.init(coordinate: eventCoordinate, title: item!.venue!.title, subtitle: item!.venue!.address)
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        let metersPerMile = 1609.344
        var distance = 0.2 * metersPerMile

        // set the region to show user and venue, if possible
        if let userLocation = mapView.userLocation.location {
            
            let eventLocation = CLLocation(latitude:item!.venue!.latitude.doubleValue, longitude: item!.venue!.longitude.doubleValue)

            distance = userLocation.distanceFromLocation(eventLocation)
            
            if distance > 0.5 * metersPerMile {
                distance = 0.2 * metersPerMile  // user is too far away to show both
            } else if distance < 0.05 * metersPerMile {  // 0.05 is our minimum
                distance = 0.1 * metersPerMile
            }
            else {  // between 0.05 and 0.5
                distance = 0.5 * metersPerMile
            }
        }
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(eventCoordinate, distance, distance);
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated:true)
    }
    
    // MARK: Share action
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBAction func shareAction(sender: UIBarButtonItem) {
        
        if let item: ScheduleItem = item {
            let event = item.event
            let venue = item.venue
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "H:mm a"
            let dateString = dateFormatter.stringFromDate(item.date)
            
            let headline = "PTFilmFest 2015 - \(event!.title)"
            let details = "\(item.day) \(dateString) at \(venue!.title)"
            let image = UIImage(data: event!.imageData)!
            let website = "\(event!.webSite)"
            
            let objectsToShare = [headline,details,website,image]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo]
            
            activityVC.popoverPresentationController?.barButtonItem = shareButton
            
            presentViewController(activityVC, animated: true, completion: nil)
            
        }
    }
    

}

