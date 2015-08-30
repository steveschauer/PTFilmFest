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

    var managedObjectContext: NSManagedObjectContext? = nil
    var locationManager: CLLocationManager? = nil
    var mapRect: CGRect? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var eventDetailsLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet var venueNameButton: UIButton!
    @IBOutlet weak var bodyTextLabel: UITextView!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var likeButton: LikeButton!
    @IBAction func likeButtonPressed(sender: LikeButton) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(1 * Double(NSEC_PER_SEC)))
        if likeButton.likeButtonState == LikeState.NotLiked {
            likeButton.likeButtonState = LikeState.Liking
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.likeButton.likeButtonState = LikeState.Liked
            }
        } else {
            likeButton.likeButtonState = LikeState.Unliking
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.likeButton.likeButtonState = LikeState.NotLiked
            }
        }
    }
    
    var item: ScheduleItem? // {
//        didSet {
//            // Update the view.
//            self.configureView()
//        }
//    }

    var event: Event?
    var venue: Venue?

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
//        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mapRect = mapView.frame
//        configureView()
    }
    
//    override func viewWillLayoutSubviews() {
//        self.configureView()
//    }
    
    func configureView() {
        event = item!.event
        venue = item!.venue
        
        mapButton.layer.borderWidth=1.0
        mapButton.layer.borderColor=UIColor.lightGrayColor().CGColor
        mapButton.layer.cornerRadius = 4.0
        
        venueNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        venueNameButton.titleLabel!.text = venue!.title
        
        title = event!.title
        
        imageView.image = UIImage(named:"\(event!.name)_small")!
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm a"
        let dateString = dateFormatter.stringFromDate(item!.date)
        dateAndTimeLabel!.text = "\(item!.day) \(dateString)"
        eventDetailsLabel!.text = "\(event!.director)"
        
        bodyTextLabel!.text = event!.bodyText
        
        if event!.type == "1" {
            println("Hey")
        }
        
        otherShowings()
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
        configureMapView()
        let endRect = mapRect!
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
        
        let eventCoordinate = CLLocationCoordinate2DMake(venue!.latitude.doubleValue, venue!.longitude.doubleValue)
        let annotation = MapPin.self.init(coordinate: eventCoordinate, title: venue!.title, subtitle: venue!.address)
        
        //3D Camera
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = eventCoordinate
        mapCamera.pitch = 45;
        mapCamera.altitude = 500;
        mapCamera.heading = 45;
        
        //Set MKmapView camera property
        self.mapView.camera = mapCamera;
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        let metersPerMile = 1609.344
        var distance = 0.2 * metersPerMile

        // set the region to show user and venue, if possible
        if let userLocation = mapView.userLocation.location {
            
            let eventLocation = CLLocation(latitude:venue!.latitude.doubleValue, longitude: venue!.longitude.doubleValue)

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
        fetchRequest.predicate = NSPredicate(format: "event == %@", self.item!.event)
        
        let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [ScheduleItem]
        
        // filter self.item out, and then,
        return fetchResults;
    }
    
    func eventForName(name:String) -> Event {
        let context = self.managedObjectContext!;
        
        var fetchRequest = NSFetchRequest(entityName: "Event")
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", name)
        
        let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [Event]
        return fetchResults![0];
    }
    
    // MARK: Share action
    
    @IBAction func shareAction(sender: UIBarButtonItem) {
        
        if let item: ScheduleItem = self.item {
            event = self.item!.event
            venue = self.item!.venue
            
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

