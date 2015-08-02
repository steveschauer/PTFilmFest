//
//  DetailViewController.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 6/29/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var testLabel: UILabel!

    var item: ScheduleItem? // {
//        didSet {
//            // Update the view.
//            self.configureView()
//        }
//    }

    var event: Event?
    var venue: Venue?
    
    func configureView() {
        if let item: ScheduleItem = self.item {
            event = self.item!.event
            venue = self.item!.venue
            self.title = self.item!.event.title
            self.testLabel.text = self.item!.event.title
            
            self.imageView.image = UIImage(named:"\(self.item!.event.name)_small")!
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.configureView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

