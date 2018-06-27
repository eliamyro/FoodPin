//
//  MapViewController.swift
//  FoodPin
//
//  Created by Elias Myronidis on 27/6/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var restaurant = Restaurant()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        showRestaurantOnMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showRestaurantOnMap() {
        let geocoder = CLGeocoder()
        
        print(restaurant.location)
        geocoder.geocodeAddressString(restaurant.location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let placemarks = placemarks {
                // Get the first placemark
                let placemark = placemarks[0]
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = self.restaurant.name
                annotation.subtitle = self.restaurant.type
                
                if let location = placemark.location {
                    // Display the annotation
                    annotation.coordinate = location.coordinate
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
}
