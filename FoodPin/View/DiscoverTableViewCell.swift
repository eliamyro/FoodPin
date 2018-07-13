//
//  DiscoverImageTableViewCell.swift
//  FoodPin
//
//  Created by Elias Myronidis on 13/7/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {
    
    @IBOutlet weak var restaurantImage: UIImageView! {
        didSet {
            restaurantImage.contentMode = .scaleAspectFill
            restaurantImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var locationLabel: UILabel! {
        didSet {
            locationLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
