//
//  RestaurantDetailMapCell.swift
//  FoodPin
//
//  Created by Elias Myronidis on 27/6/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailMapCell: UITableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
