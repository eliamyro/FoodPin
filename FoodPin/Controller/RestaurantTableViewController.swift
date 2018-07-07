//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Elias Myronidis on 12/6/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var emptyRestaurantView: UIView!
    private var restaurants:[RestaurantMO] = []
    private var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    private var searchController: UISearchController?
    private var searchResults: [RestaurantMO] = []
    private let HAS_VIEWED_WALKTHROUGH = "hasViewedWalkthrough"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = true
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // NavigationController
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedStringKey.font: customFont]
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Search controller
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        
        // Search bar in tableview header
//        tableView.tableHeaderView = searchController?.searchBar
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search restaurants..."
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.backgroundImage = UIImage()
        searchController?.searchBar.tintColor = UIColor(red: 231, green: 76, blue: 60)
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    restaurants = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: HAS_VIEWED_WALKTHROUGH) {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource protocol

    override func numberOfSections(in tableView: UITableView) -> Int {
        if restaurants.count > 0 {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController?.isActive)! {
           return searchResults.count
        } else {
            return restaurants.count
        }
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
        
        // Determine if we get the restaurant from search result or the original array
        let restaurant = (searchController?.isActive)! ? searchResults[indexPath.row] : restaurants[indexPath.row]
        
        cell.nameLabel?.text = restaurant.name
        if let restaurantImage = restaurant.image {
            cell.thumbnailImageView?.image = UIImage(data: restaurantImage as Data)
        }
        cell.locationLabel.text = restaurant.location
        cell.typeLabel.text = restaurant.type
        
        cell.heartImageView.isHidden =  restaurant.isVisited ? false : true
        return cell
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
//        
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
//        
//        if let popoverController = optionMenu.popoverPresentationController {
//                popoverController.sourceView = cell
//                popoverController.sourceRect = cell.bounds
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        optionMenu.addAction(cancelAction)
//        
//        let callAction = UIAlertAction(title: "Call 123-000 \(indexPath.row)", style: .default) {
//            (action) in
//            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .alert)
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertMessage, animated: true, completion: nil)
//        }
//        optionMenu.addAction(callAction)
//        
//        if restaurantIsVisited[indexPath.row] {
//            let undoCheckAction = UIAlertAction(title: "Undo Check in", style: .default) {
//                (action) in
//                self.restaurantIsVisited[indexPath.row] = false
//                cell.heartImageView.isHidden = true
//            }
//            
//            optionMenu.addAction(undoCheckAction)
//        } else {
//            let checkInHandler = {
//                (action: UIAlertAction) in
//                self.restaurantIsVisited[indexPath.row] = true
//                cell.heartImageView.isHidden = false
//            }
//            
//            let checkInAction = UIAlertAction(title: "Check in", style: .default, handler: checkInHandler)
//            optionMenu.addAction(checkInAction)
//        }
//        
//        present(optionMenu, animated: true, completion: nil)
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
//    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(restaurantToDelete)
                appDelegate.saveContext()
            }
            
            // Call completion handler to dismiss the action button
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(red: 231, green: 76, blue: 60)
        deleteAction.image = UIImage(named: "delete")
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            let defaultText = "Just checking in at \(self.restaurants[indexPath.row].name!)"
            let activityController: UIActivityViewController
            
            if let restaurantImage = self.restaurants[indexPath.row].image,
                let imageToShare = UIImage(data: restaurantImage as Data) {
               activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else {
               activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        shareAction.backgroundColor = UIColor(red: 254, green: 149, blue: 38)
        shareAction.image = UIImage(named: "share")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkInAction = UIContextualAction(style: .normal, title: "Check-in") { (action, sourceView, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
            self.restaurants[indexPath.row].isVisited = (self.restaurants[indexPath.row].isVisited) ? false : true
            cell.heartImageView.isHidden = self.restaurants[indexPath.row].isVisited ? false : true
            
            completionHandler(true)
        }
        
        // Customize the action button
        checkInAction.backgroundColor = UIColor(red: 39, green: 174, blue: 96)
        checkInAction.image = self.restaurants[indexPath.row].isVisited ? UIImage(named: "undo") : UIImage(named: "tick")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
        
        return swipeConfiguration
    }
    
    // Disable share and delete buttons when in search mode
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (searchController?.isActive)! {
            return false
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = (searchController?.isActive)! ? searchResults[indexPath.row] : restaurants[indexPath.row]
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            restaurants = fetchedObjects as! [RestaurantMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    private func filterContent(for searchText: String) {
        searchResults = restaurants.filter({ (restaurant) -> Bool in
            
            if let name = restaurant.name, let location = restaurant.location {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || location.localizedStandardContains(searchText)
                return isMatch
            }
            
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }

}
