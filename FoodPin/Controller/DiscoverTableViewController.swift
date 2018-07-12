//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by Elias Myronidis on 11/7/18.
//  Copyright © 2018 Elias Myronidis. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    private var restaurants: [CKRecord] = []
    private var spinner = UIActivityIndicatorView()
    private var imageCache = NSCache<CKRecordID, NSURL>()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedStringKey.font: customFont]
        }
        
        spinner.activityIndicatorViewStyle = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        // Define layout constraints for spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
                                     spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        spinner.startAnimating()
        
        // Pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: .valueChanged)
        
        fetchRecordsFromCloud()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath)

        // Configure the cell...
        let restaurant = restaurants[indexPath.row]
        
        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
        cell.imageView?.image = UIImage(named: "photo")
        
        // Check if the image is stored in cache
        if let imageFileUrl = imageCache.object(forKey: restaurant.recordID) {
            // Fetch image from cache
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileUrl as URL) {
                cell.imageView?.image = UIImage(data: imageData)
            }
        } else {
            // Fetch image from Cloud in background
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            fetchRecordsImageOperation.perRecordCompletionBlock = {
                (record, recordId, error) -> Void in
                if let error = error {
                    print("Failed to get restaurant image \(error.localizedDescription)")
                    return
                }
                
                if let restaurantRecord = record, let image = restaurantRecord.object(forKey: "image"), let imageAsset = image as? CKAsset {
                    if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                        // Replace the placeholder image with the restaurant image
                        DispatchQueue.main.async {
                            cell.imageView?.image = UIImage(data: imageData)
                            cell.setNeedsLayout()
                        }
                        
                        // Add the image url to cache
                        self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: restaurant.recordID)
                    }
                }
            }
            publicDatabase.add(fetchRecordsImageOperation)
        }
        
        return cell
    }
    
//    private func fetchRecordsFromCloud() {
//        // Fetch data using Convenience API
//
//        let cloudContainer = CKContainer.default()
//        let publicDatabase = cloudContainer.publicCloudDatabase
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
//
//        publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//
//            if let results = results {
//                print("Completed the download of Restaurant data")
//                self.restaurants = results
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }

    @objc private func fetchRecordsFromCloud() {
        restaurants.removeAll()
        tableView.reloadData()
        
        // Fetch data using Operational API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)

        // Create the query operation with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50

        queryOperation.recordFetchedBlock = {
            (record) -> Void in
            self.restaurants.append(record)
        }

        queryOperation.queryCompletionBlock = {
            (cursros, error) -> Void in
            
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }

        // Execute the query
        publicDatabase.add(queryOperation)
    }
}
