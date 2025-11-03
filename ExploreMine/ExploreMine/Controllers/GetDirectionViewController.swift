//
//  GetDirectionViewController.swift
//  ExploreMine
//
//  Created by Silstone on 05/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import CoreLocation
import Foundation
//import SwiftyJSON

class GetDirectionViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: UIView!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    var geobotDetails = NSDictionary()
    var googleMaps: GMSMapView!
    var viaExploreScreen = Bool(false)
    let locationManager = CLLocationManager()
    var CurrentUserlat: CLLocationDegrees! = 0.0
    var CurrentUserlong: CLLocationDegrees! = 0.0
    var firstTime = Bool(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTime = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // check the permission status
        initMap()
    }
    
    // MARK: - GoogleMaps initialization
    
    func initMap() {
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
        
        if !(firstTime) {
            checkAuthorization()
        }
        
        firstTime = false
    }
    
    func checkAuthorization() {
        // initialise a pop up for using later
        let alertController = UIAlertController(title: "Location permissions", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        // check the permission status
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorize.")
        // get the user location
        case .notDetermined, .restricted, .denied:
            // redirect the users to settings
            self.present(alertController, animated: true, completion: nil)
        @unknown default:
            fatalError()
        }
    }
    
    func setMap() {
        let camera = GMSCameraPosition.camera(withLatitude: CurrentUserlat, longitude: CurrentUserlong, zoom: 18.0)
        let rect = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: mapView.frame.height+100))
        googleMaps = GMSMapView.map(withFrame: rect, camera: camera)
        googleMaps.isMyLocationEnabled = true
        mapView.addSubview(googleMaps)
        googleMaps.delegate = self
        googleMaps.mapType = GMSMapViewType(rawValue: 4)!
        googleMaps.clear()
        let location = destinationCLLocation()
        let name = destinationName()
        CommonFunctions().addMarker(lat: location.latitude, long: location.longitude, map: googleMaps, info: "", pinTitle: name, description:"Tap to open")
        if calculateDistance() > 50 {
            drawRoutePath()
        }
    }
    
    func drawRoutePath() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let origin = "\(CommonFunctions.sharedInstance.CurrentUserlat!),\( CommonFunctions.sharedInstance.CurrentUserlong!)"
        netwoking.callGetDirectionsApi(originPoint: origin, destinationPoint: destinationLatLong()) { (response) in
            if let result = response.result.value {
                
                let jsonData = result as! NSDictionary
                let routes = jsonData["routes"] as! [NSDictionary]
                
                for route in routes {
                    let routeOverviewPolyline = route["overview_polyline"] as! NSDictionary
                    let points = routeOverviewPolyline["points"] as! String
                    let path = GMSPath.init(fromEncodedPath: points)
                    
                    let polyline = GMSPolyline(path: path)
                    //                    polyline.strokeColor = CommonFunctions().hexStringToUIColor(hex: "30FF30")
                    polyline.strokeColor = .green
                    polyline.strokeWidth = 5.0
                    polyline.map = self.googleMaps
                }
            }
            ActivityLoader().hideActivityIndicator(uiView: self.view)
        }
    }
    
    func destinationLatLong() -> String {
        var locationDict = NSDictionary()
        if viaExploreScreen {
            let propertiesDict = geobotDetails["properties"] as! NSDictionary
            locationDict = (propertiesDict["location"] as? NSDictionary)!
        } else {
            locationDict = (geobotDetails["location"] as? NSDictionary)!
        }
        let destinationLocation = CLLocationCoordinate2D(latitude: locationDict["latitude"] as! Double, longitude: locationDict["longitude"] as! Double)
        let destination = "\(String(describing: destinationLocation.latitude)),\(String(describing: destinationLocation.longitude))"
        return destination
    }
    
    func destinationCLLocation() -> CLLocationCoordinate2D {
        
        var locationDict = NSDictionary()
        if viaExploreScreen {
            let propertiesDict = geobotDetails["properties"] as! NSDictionary
            locationDict = (propertiesDict["location"] as? NSDictionary)!
        } else {
            locationDict = (geobotDetails["location"] as? NSDictionary)!
        }
        let destinationLocation = CLLocationCoordinate2D(latitude: locationDict["latitude"] as! Double, longitude: locationDict["longitude"] as! Double)
        return destinationLocation
    }
    
    func destinationName() -> String {
        var locationDict: String
        if viaExploreScreen {
            let propertiesDict = geobotDetails["properties"] as! NSDictionary
            locationDict = (propertiesDict["name"] as? String)!
        } else {
            locationDict = (geobotDetails["name"] as? String)!
        }
        return locationDict
    }
    
    func calculateDistance() -> Float {
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
        }
        let myLocation = CLLocation(latitude: CommonFunctions.sharedInstance.CurrentUserlat, longitude: CommonFunctions.sharedInstance.CurrentUserlong)
        let location = destinationCLLocation()
        let destinationLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distance = myLocation.distance(from: destinationLocation)
        return Float(distance)
    }
    
    // MARK: - GoogleMaps Delegates
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if calculateDistance() < 50 {
            
            var geobotId = String()
            if viaExploreScreen {
                let propertiesDict = geobotDetails["properties"] as! NSDictionary
                geobotId = (propertiesDict["geobotid"] as? String)!
            } else {
                geobotId = (geobotDetails["geobotid"] as? String)!
            }
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GeobotARVC") as? GeobotARViewController
            vc?.geobotId = geobotId
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            commonFunctions.ShowAlert(title: kAppName, message: "Can't open expirence, \n you are away from it's location !", in: self)
        }
    }
    
    // MARK: - locationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        CurrentUserlat = (mostRecentLocation.coordinate.latitude) // get current location latitude
        CurrentUserlong = (mostRecentLocation.coordinate.longitude) //get current location longitude
        setMap()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Api Calls
    func deleteGeobot() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        var geobotId = String()
        if viaExploreScreen {
            let propertiesDict = geobotDetails["properties"] as! NSDictionary
            geobotId = (propertiesDict["geobotid"] as? String)!
        } else {
            geobotId = (geobotDetails["geobotid"] as? String)!
        }
        let header: HTTPHeaders = [
            "geobotid": geobotId ,
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String,
            "location": "",
            "developerid": "test"
        ]
        netwoking.callDeleteApi(apiMethod: kGeobots, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.navigationController?.popViewController(animated: true)
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        commonFunctions.showAlertWithMutipleActions(message: "Are you sure to delete this experience ?", title: kAppName, controller: self, firstBtnTitle: "Yes", secondBtnTitle: "No") { (optionIndex) in
            if (optionIndex == 1) {
                self.deleteGeobot()
            }
        }
    }
    
    @IBAction func btnRelocateUserPressed(_ sender: Any) {
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
            let cameraPosition = GMSCameraPosition.camera(withLatitude: CommonFunctions.sharedInstance.CurrentUserlat, longitude: CommonFunctions.sharedInstance.CurrentUserlong, zoom: 14.0)
            self.googleMaps.animate(to: cameraPosition)
        }
    }
}
