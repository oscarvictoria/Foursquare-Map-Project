//
//  ResultCell.swift
//  Foursquare-Map-Project
//
//  Created by Matthew Ramos on 2/26/20.
//  Copyright © 2020 Oscar Victoria Gonzalez . All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
 
    @IBOutlet weak var venueImageView: UIImageView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    func configureCell(venue: SavedVenue) {
        venueNameLabel.text = venue.name
        categoryLabel.text = "\(venue.categoryName) , \(venue.address)"
        venueImageView.image = UIImage(data: venue.imageData)
    }
}
