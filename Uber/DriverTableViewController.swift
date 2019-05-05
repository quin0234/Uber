//
//  DriverTableViewController.swift
//  
//
//  Created by Paul Quinnell on 2019-05-04.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        Database.database().reference().child("RideRequests").observe(.childAdded)
            { (snapshot) in
                self.rideRequests.append(snapshot)
                self.tableView.reloadData()
            }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {(timer) in
            self.tableView.reloadData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }

    @IBAction func logoutTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
        try? Auth.auth().signOut()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let snapshot = rideRequests[indexPath.row]

        if let rideRequestDict = snapshot.value as? [String: AnyObject]{
            if let email = rideRequestDict["email"] as? String {
                if let lat = rideRequestDict["lat"] as? Double {
                    if let lon = rideRequestDict["lon"] as? Double {
                        
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let dist = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let rDist = round(dist * 100) / 100
                        
                        
                        cell.textLabel?.text = "\(email) - \(rDist)km away"
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDict = snapshot.value as? [String: AnyObject]{
                    if let email = rideRequestDict["email"] as? String {
                        if let lat = rideRequestDict["lat"] as? Double {
                            if let lon = rideRequestDict["lon"] as? Double {
                            acceptVC.requestEmail = email
                                
                            let location  = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                acceptVC.requestLocation = location
                                acceptVC.driverLocation = driverLocation
                            
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            
           
        }
    }


}
