//
//  GeobotsViewController.swift
//  ExploreMine
//
//  Created by Silstone on 04/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class GeobotsViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: UIView!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    var dataArr = NSArray()
    var geoBotsMap: GMSMapView!
    var channelId = ""
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGeobots()
    }
    
    // MARK: - GoogleMaps initialization
    func initMap() {
        DispatchQueue.main.async {
                   CommonFunctions.sharedInstance.start()
               }
        let camera = GMSCameraPosition.camera(withLatitude: CommonFunctions.sharedInstance.CurrentUserlat, longitude: CommonFunctions.sharedInstance.CurrentUserlong, zoom: 10.0)
        let rect = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: mapView.frame.height+100))
        geoBotsMap = GMSMapView.map(withFrame: rect, camera: camera)
        mapView.addSubview(geoBotsMap)
        geoBotsMap.delegate = self
        geoBotsMap.mapType = GMSMapViewType(rawValue: 4)!
    }
    
    func addMarkers() {
        geoBotsMap.clear()
        for index in 0..<self.dataArr.count {
            let geobotDict = self.dataArr[index] as! NSDictionary
            let locationDict = geobotDict["location"] as? NSDictionary
            let location = CLLocationCoordinate2D(latitude: locationDict?["latitude"] as! Double, longitude: locationDict?["longitude"] as! Double)
            
            DispatchQueue.main.async(execute: {
                let marker = GMSMarker()
                marker.position = location
                marker.userData = index
                marker.title = "Get Directions"
                marker.snippet = geobotDict["name"] as? String
                marker.map = self.geoBotsMap
            })
        }
    }
    
    func setMapCenterPosition() {
        let geobotDict = self.dataArr[0] as! NSDictionary
        let locationDict = geobotDict["location"] as? NSDictionary
        let location = CLLocationCoordinate2D(latitude: locationDict?["latitude"] as! Double, longitude: locationDict?["longitude"] as! Double)
        let cameraPosition = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 14.0)
        geoBotsMap.animate(to: cameraPosition)
    }
    
    // MARK: - GoogleMaps Delegates
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let selectedPinIndex = marker.userData as! Int
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "GetDirectionVC") as? GetDirectionViewController
        vc?.geobotDetails = self.dataArr[selectedPinIndex] as! NSDictionary
        self.navigationController?.pushViewController(vc!, animated: true)
    }
     
    // MARK: - Api Calls
    func getGeobots() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let header: HTTPHeaders = [
            "channelid": channelId,
          //  "channelid": "505d0858-fbc9-11e9-8d0a-01fb630e1be6",
            "showhidden": "true",
            "location": "",
            "developerid": "test"
        ]
        netwoking.callGetApi(apiMethod: kGeobots, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                self.dataArr = response.result.value as! NSArray
                if (self.dataArr.count > 0) {
                    self.addMarkers()
                    self.setMapCenterPosition()
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
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addExpirence(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Experience name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter experience name"
        }
        let saveAction = UIAlertAction(title: "Next", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            if (textField.text!.count > 0) {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ARVC") as? ARViewController
                vc?.geobotName = textField.text!
                vc?.channelId = self.channelId
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                  self.commonFunctions.ShowAlert(title: kAppName, message: "Please enter experience name", in: self)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnRelocateUserPressed(_ sender: Any) {
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
            let cameraPosition = GMSCameraPosition.camera(withLatitude: CommonFunctions.sharedInstance.CurrentUserlat, longitude: CommonFunctions.sharedInstance.CurrentUserlong, zoom: 14.0)
            self.geoBotsMap.animate(to: cameraPosition)
        }
    }
}
