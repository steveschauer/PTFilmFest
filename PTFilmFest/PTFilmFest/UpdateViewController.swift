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
        startTime = NSDate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        activityView.startAnimating()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCompleted:", name:"updateFestivalDataComplete", object: nil)
        appDelegate.getFestivalData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCompleted(notification: NSNotification) {
        var now = NSDate()
        var elapsedTime = now.timeIntervalSinceDate(startTime!)
        while elapsedTime < 3.0 {
            now = NSDate()
            elapsedTime = now.timeIntervalSinceDate(startTime!)
        }
        activityView.stopAnimating()
        NSNotificationCenter.defaultCenter().removeObserver(self) // Remove from all notifications being observed
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
