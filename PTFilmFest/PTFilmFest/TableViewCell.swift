//
//  TableViewCell.swift
//  PTFilmFest
//
//  Created by Steve Schauer on 7/6/15.
//  Copyright (c) 2015 Steve Schauer. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewForCell: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var timeAndVenueLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
