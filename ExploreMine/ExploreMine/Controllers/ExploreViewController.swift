//
//  ExploreViewController.swift
//  ExploreMine
//
//  Created by Silstone on 11/12/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import CoreLocation

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: Int!
  var snippet: String!

  init(position: CLLocationCoordinate2D, name: Int, snippet: String) {
    self.position = position
    self.name = name
    self.snippet = snippet
  }
}

class ExploreViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: UIView!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    private var clusterManager: GMUClusterManager!
    let locationManager = CLLocationManager()
    var CurrentUserlat: CLLocationDegrees! = 0.0
    var CurrentUserlong: CLLocationDegrees! = 0.0
    var commonFunctions = CommonFunctions()
    var dataDict =  [NSDictionary]()
    var geoBotsMap: GMSMapView!
    var geoHash : String = ""
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
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500
            locationManager.requestWhenInUseAuthorization()
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
        let camera = GMSCameraPosition.camera(withLatitude: CurrentUserlat, longitude: CurrentUserlong, zoom: 14.0)
        let rect = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: mapView.frame.height+100))
        geoBotsMap = GMSMapView.map(withFrame: rect, camera: camera)
        mapView.addSubview(geoBotsMap)
        geoBotsMap.delegate = self
        geoBotsMap.mapType = GMSMapViewType(rawValue: 4)!
        geoHash = Geohash.encode(latitude: CurrentUserlat, longitude: CurrentUserlong, length: 9)
        getExpirences()
    }
    
    func addMarkers() {
        geoBotsMap.clear()
        for index in 0..<self.dataDict.count {
            let geobotDict = self.dataDict[index]
            let propertiesDict = geobotDict["properties"] as! NSDictionary
            
            let locationDict = propertiesDict["location"] as? NSDictionary
            
            let location = CLLocationCoordinate2D(latitude: locationDict?["latitude"] as! Double, longitude: locationDict?["longitude"] as! Double)
            
            DispatchQueue.main.async(execute: {
                let marker = GMSMarker()
                marker.position = location
                marker.userData = index
                marker.title = "Get Directions"
                marker.snippet = propertiesDict["name"] as? String
                marker.map = self.geoBotsMap
            })
        }
    }
    
    func setMapCenterPosition() {
        let geobotDict = self.dataDict[0]
        let propertiesDict = geobotDict["properties"] as! NSDictionary
        
        let locationDict = propertiesDict["location"] as? NSDictionary
        let location = CLLocationCoordinate2D(latitude: locationDict?["latitude"] as! Double, longitude: locationDict?["longitude"] as! Double)
        let cameraPosition = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 14.0)
        geoBotsMap.animate(to: cameraPosition)
    }
    
    func setupClustering() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: geoBotsMap,
                                    clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: geoBotsMap, algorithm: algorithm,
                                                          renderer: renderer)

        // Generate and add random items to the cluster manager.
        generateClusterItems()

        // Call cluster() after items have been added to perform the clustering
        // and rendering on map.
        clusterManager.cluster()
    }
    
    private func generateClusterItems() {
       
        for index in 0..<self.dataDict.count {
            let geobotDict = self.dataDict[index]
            let propertiesDict = geobotDict["properties"] as! NSDictionary
            
            let locationDict = propertiesDict["location"] as? NSDictionary
            
            
          //   let location = CLLocationCoordinate2D(latitude: locationDict?["latitude"] as! Double, longitude: locationDict?["longitude"] as! Double)
            
        //    let vehicleDict = self.LiveTrackingArray[index]
            let lat = locationDict?["latitude"] as! Double
            let lng = locationDict?["longitude"] as! Double
            let name = index
            let snippet = (propertiesDict["name"] as? String)!
            let item =
                POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name, snippet: snippet )
            clusterManager.add(item)
        }
    }
    
//    private func randomScale() -> Double {
//         return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
//       }
    
    // MARK: - GoogleMaps Delegates
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        var selectedPinIndex: Int
        if let poiItem = marker.userData as? POIItem {
            selectedPinIndex = poiItem.name
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GetDirectionVC") as? GetDirectionViewController
            vc?.geobotDetails = self.dataDict[selectedPinIndex]
            vc?.viaExploreScreen = true
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        //        else {
        //            selectedPinIndex = marker.userData as! Int
        //        }
        
    }
    
    // tap map marker
       func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
           print("didTap marker \(String(describing: marker.userData))")

           if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(String(describing: poiItem.name))")
           } else {
             NSLog("Did tap a normal marker")
           }
          
          return false
       }
    
//    private func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
//          let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
//          zoom: geoBotsMap.camera.zoom + 1)
//        let update = GMSCameraUpdate.setCamera(newCamera)
//        geoBotsMap.moveCamera(update)
//    }
    
//    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
//        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
//                                                 zoom: geoBotsMap.camera.zoom + 1)
//        let update = GMSCameraUpdate.setCamera(newCamera)
//      //  mapView.moveCamera(update)
//
//        return false
//    }
    
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
    func getExpirences() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        
        let header: HTTPHeaders = [
            "location": geoHash,
            "radius": "10000",
        ]
        netwoking.callGetBaseApi(apiMethod: kGeojson, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                
                self.dataDict.removeAll()
                let dataArr = response.result.value as! NSDictionary
                let featuresArr = dataArr["features"] as! [NSDictionary]
                for item in featuresArr {
                    self.dataDict.append(item)
                }
                
                if (self.dataDict.count > 0) {
                   // self.addMarkers()
                    self.setupClustering()
                    //self.setMapCenterPosition()
                } else {
                    self.geoBotsMap.clear()
                }
                
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func btnRelocateUserPressed(_ sender: Any) {
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
            let cameraPosition = GMSCameraPosition.camera(withLatitude: CommonFunctions.sharedInstance.CurrentUserlat, longitude: CommonFunctions.sharedInstance.CurrentUserlong, zoom: 14.0)
            self.geoBotsMap.animate(to: cameraPosition)
        }
    }
    
}
