//
//  UpdateViewController.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 8/31/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var mainImage: UIImageView!
    var startTime:NSDate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            switch UIDevice.currentDevice().orientation{
            case .Portrait:
                mainImage.image = UIImage(named:"Born_to_the_West_(1937)_Portrait.jpg")
            case .PortraitUpsideDown:
                mainImage.image = UIImage(named:"Born_to_the_West_(1937)_Portrait.jpg")
            case .LandscapeLeft:
                mainImage.image = UIImage(named:"Born_to_the_West_(1937).jpg")
            case .LandscapeRight:
                mainImage.image = UIImage(named:"Born_to_the_West_(1937).jpg")
            default:
                mainImage.image = UIImage(named:"Born_to_the_West_(1937).jpg")
            }

        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startTime = NSDate()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        activityView.startAnimating()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCompleted:", name:"updateTableView", object: nil)
        appDelegate.getFestivalData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        activityView.stopAnimating()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCompleted(notification: NSNotification) {
        // make the view stay up for a minimum amount of time
        var now = NSDate()
        var elapsedTime = now.timeIntervalSinceDate(startTime!)
        if elapsedTime < 3 {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            self.activityView.stopAnimating()
            NSNotificationCenter.defaultCenter().removeObserver(self)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
