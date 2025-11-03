//
//  geobotARViewController.swift
//  ExploreMine
//
//  Created by Silstone on 06/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import Alamofire
import ARKit
import SceneKit
import QuartzCore
import CoreLocation
import CoreMotion

class GeobotARViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    var geobotId = ""
    var geobotPosition:SCNVector3?
    var geobotScale:SCNVector3?
    var detectedDirectionFloat: Double! = 0.0
    var directionFloat: Double! = 0.0
    var matchDirectionTimer: Timer?
    var imageNodeAdded = Bool(false)
    
    var cameraNod : SCNNode!
    var expirenceImage:UIImage? = nil
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        getMetadata()
        initLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !imageNodeAdded{
            let touch = touches.first!
            if let hitNode = sceneView.hitTest(touch.location(in: sceneView), options: nil).first {
                let position =  hitNode.node.position
                hitNode.node.removeFromParentNode()
                self.addImageNodeWith(position: position)
            }
        }
    }
    
    // MARK: - location initialization
    func initLocation() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingHeading()
        }
    }
    
    // MARK: - Api Calls
    
    func getMetadata() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let header: HTTPHeaders = [
            "geobotid": geobotId,
            "location": "",
            "developerid": kDeveloperId
        ]
        netwoking.callGetApi(apiMethod: kMetaData, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                print("This is the files output: \(response.result.value as AnyObject)")
                let dataDict = response.result.value as! [NSDictionary]
                
                let dataValue = dataDict[0]["value"] as! [NSDictionary]
                
                for item in dataValue {
                    if (item["type"] as! String == "position") {
                        let dataArr = item["values"] as! NSDictionary
                        let x = dataArr["x"] as! NSNumber
                        let y = dataArr["y"] as! NSNumber
                        let z = dataArr["z"] as! NSNumber
                        self.geobotPosition = SCNVector3Make(Float(truncating: x), Float(truncating: y), Float(truncating: z))
                    } else  if (item["type"] as! String == "scale") {
                        let dataArr = item["values"] as! NSDictionary
                        let x = dataArr["x"] as! NSNumber
                        let y = dataArr["y"] as! NSNumber
                        let z = dataArr["z"] as! NSNumber
                        self.geobotScale = SCNVector3Make(Float(truncating: x), Float(truncating: y), Float(truncating: z))
                        //                         self.geobotScale = SCNVector3Make(Float(truncating: NSNumber(value: Int(truncating: x)/2)), Float(truncating: NSNumber(value: Int(truncating: y)/2)), Float(truncating: NSNumber(value: Int(truncating: z)/2)))
                    } else  if (item["type"] as! String == "direction") {
                        
                        self.detectedDirectionFloat = (item["values"] as! double_t)
                        
                    }
                }
                self.getFiles()
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    func getFiles() {
        let header: HTTPHeaders = [
            "geobotid": geobotId,
            "location": "",
            "developerid": kDeveloperId
        ]
        netwoking.callGetApi(apiMethod: kFiles, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                print("This is the files output: \(response.result.value as AnyObject)")
                let dataArr = response.result.value as? NSDictionary
                let files = dataArr!["fileurls"] as? NSArray
                if (files!.count > 0) {
                    var imageUrlString = "\(kServerUrl)\(files![0])"
                    imageUrlString = imageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let imageUrl = URL(string: imageUrlString)!
                    let imageData = try! Data(contentsOf: imageUrl)
                    let image = UIImage(data: imageData)
                    if (image != nil) {
                        self.expirenceImage = image
                    }
                }
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    // MARK: - Add Plane SCNNode
    func addPlaneNode(x: Float = 0, y: Float = 0, z: Float = -0.2, img:UIImage) {
        
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        let plane = SCNPlane (width: 0.1, height: 0.1)
        plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode()
        planeNode.geometry = plane
        
        let cameraNod = sceneView.pointOfView
        planeNode.orientation = cameraNod!.orientation
        planeNode.position = SCNVector3(0, 0, -0.2)
        planeNode.geometry?.firstMaterial?.diffuse.contents = img
        planeNode.opacity = 0.9
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    func addImageNodeWith(position:SCNVector3) {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let plane = SCNPlane (width: 0.1, height: 0.1)
        plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode()
        planeNode.geometry = plane
        planeNode.position = position
        planeNode.scale = self.geobotScale!
        planeNode.orientation = cameraNod.orientation
        planeNode.geometry?.firstMaterial?.diffuse.contents = self.expirenceImage!
        planeNode.opacity = 0.95
        sceneView.scene.rootNode.addChildNode(planeNode)
        imageNodeAdded = true
        ActivityLoader().hideActivityIndicator(uiView: self.view)
    }
    
    func addPointNode() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let sphere = SCNSphere(radius: 0.01)
        sphere.firstMaterial?.isDoubleSided = true
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = cameraNod.position
        sphereNode.orientation = cameraNod.orientation
        sceneView.scene.rootNode.addChildNode(sphereNode)
        ActivityLoader().hideActivityIndicator(uiView: self.view)
    }
    
    func pointToAddNode() -> SCNVector3 {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let centerLocation = CGPoint(x: screenWidth/2, y: screenHeight/2)
        
        //     pointOfView
        let hitTestResultsWithFeaturePoints : [ARHitTestResult] = sceneView.hitTest(centerLocation, types: .featurePoint)
        
        if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
            let finalTransform = hitTestResultWithFeaturePoints.worldTransform.translation
            let result = SCNVector3Make(finalTransform.x, finalTransform.y, finalTransform.z)
            return result
        } else {
            return SCNVector3Make(0, 0, 0)
        }
    }
    
    // MARK: - IBActions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - locationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        directionFloat = newHeading.trueHeading.rounded(toPlaces: 0)
        
        if detectedDirectionFloat == directionFloat && expirenceImage != nil {
            cameraNod = sceneView.pointOfView
            DispatchQueue.main.async {
                //    self.addPlaneNodeWith(img:  self.expirenceImage!, imageNode: true)
                self.addPointNode()
            }
            
            locationManager.stopUpdatingHeading()
        }
    }
    
}
