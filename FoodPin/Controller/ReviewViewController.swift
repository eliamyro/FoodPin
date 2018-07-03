//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Elias Myronidis on 28/6/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var rateButtons: [UIButton]!
    @IBOutlet weak var closeButton: UIButton!
    
    var restaurant = RestaurantMO()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restaurantImage = restaurant.image {
            backgroundImageView.image = UIImage(data: restaurantImage as Data)
        }
        
        
        // Applying the blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        // Move close button to top outside of the screen
        let moveTopTransform = CGAffineTransform(translationX: 0.0, y: -100.0)
        closeButton.transform = moveTopTransform
        
        // Move the rate buttons outside of the screen
        let moveRightTransform = CGAffineTransform(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        
        for rateButton in rateButtons {
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0.0
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0.4, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: []
            , animations: {
                self.closeButton.transform = .identity
        }, completion: nil)
        
        var delayMs = 0.1
        for rateButton in rateButtons {
            UIView.animate(withDuration: 0.4, delay: delayMs, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
                rateButton.alpha = 1.0
                rateButton.transform = .identity
            }, completion: nil)
            delayMs += 0.05
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
