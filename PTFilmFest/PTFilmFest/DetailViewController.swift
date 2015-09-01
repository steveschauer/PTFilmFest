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

    var item: ScheduleItem?
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var locationManager: CLLocationManager? = nil
    var fullMapRect: CGRect? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var eventDetailsLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet var venueNameButton: UIButton!
    @IBOutlet weak var bodyTextLabel: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        mapView.hidden = true
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fullMapRect = mapView.frame
    }
    
//    override func viewWillLayoutSubviews() {
//        self.configureView()
//    }
    
    func configureView() {
        if let item = item, let event = item.event, let venue = item.venue {
            
            mapButton.layer.borderWidth=1.0
            mapButton.layer.borderColor=UIColor.lightGrayColor().CGColor
            mapButton.layer.cornerRadius = 4.0
            
            bodyTextLabel.layer.borderWidth=1.0
            bodyTextLabel.layer.borderColor=UIColor.lightGrayColor().CGColor
            bodyTextLabel.layer.cornerRadius = 4.0
            
            venueNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            venueNameButton.setTitle(venue.title, forState: UIControlState.Normal)
            
            title = event.title
            
            imageView.image = UIImage(data: event.imageData)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "H:mm a"
            let dateString = dateFormatter.stringFromDate(item.date)
            dateAndTimeLabel!.text = "\(item.day) \(dateString)"
            eventDetailsLabel!.text = "\(event.director)     \(event.country) \(event.year), \(event.runTime) minutes"
            
            bodyTextLabel!.text = event.bodyText
            
            otherShowings()
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
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.title = item!.event!.title
        }
        
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
            
            if CLAuthorizationStatus.AuthorizedWhenInUse == CLLocationManager.authorizationStatus() {
                println("we have status, so WTF?")
            }

            println(error)
    }

    func handleTapGesture(sender: UITapGestureRecognizer) {
        // animate mapView unZoom
        self.view.removeGestureRecognizer(sender)
        let endRect = mapButton.frame
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.mapView.frame = endRect
            }, completion:
            {
                (value: Bool) in
                self.mapView.hidden = true
            })
        
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
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 10.0
        
        mapView.removeAnnotations(mapView.annotations)
        
        let eventCoordinate = CLLocationCoordinate2DMake(item!.venue!.latitude.doubleValue, item!.venue!.longitude.doubleValue)
        let annotation = MapPin.self.init(coordinate: eventCoordinate, title: item!.venue!.title, subtitle: item!.venue!.address)
        
        //3D Camera
//        let mapCamera = MKMapCamera()
//        mapCamera.centerCoordinate = eventCoordinate
//        mapCamera.pitch = 45;
//        mapCamera.altitude = 500;
//        mapCamera.heading = 45;
//        
//        //Set MKmapView camera property
//        self.mapView.camera = mapCamera;
        
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
    
    func otherShowings() -> Array<ScheduleItem>? {
        
        let context = self.managedObjectContext!;
        
        var fetchRequest = NSFetchRequest(entityName: "ScheduleItem")
        fetchRequest.predicate = NSPredicate(format: "event == %@", self.item!.event!)
        
        let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [ScheduleItem]
        
        // filter self.item out, and then,
        return fetchResults;
    }
    
    // MARK: Share action
    
    @IBAction func shareAction(sender: UIBarButtonItem) {
        
        if let item: ScheduleItem = self.item {
            let event = self.item!.event
            let venue = self.item!.venue
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "H:mm a"
            let dateString = dateFormatter.stringFromDate(item.date)
            let textToShare = "\(event!.title) \(item.day) \(dateString)"
            if let myWebsite = NSURL(string: "http://www.ptfilmfest.com/Festival/Program.html#\(event!.name)")
            {
                let objectsToShare = [textToShare, myWebsite]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo]
                //
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
    }
    

}

