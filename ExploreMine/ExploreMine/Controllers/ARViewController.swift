//
//  ViewControllerMain.swift
//  ARDemo
//
//  Created by Silstone on 02/10/19.
//  Copyright © 2019 Silstone. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import QuartzCore
import Alamofire
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var btnReload: UIButton!
    @IBOutlet weak var btnClick: UIButton!
    @IBOutlet var lblHeader: UILabel!
    
    // MARK: - variables declaration
    private let imageService = ImagePickerService()
    let imagePicker = UIImagePickerController()
    var updateSceneViewInfo: Timer?
    //    var startPosition = CGPoint(x: 0, y: 0)
    var selectedNode: SCNNode!
    var zDepth: Float!
    var nodeAdded = Bool(false)
    var movingNode = Bool(false)
    var geobotName = ""
    var geobotId = ""
    var channelId = ""
    var selectedImage: UIImage!
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    
    let locationManager = CLLocationManager()
    var CurrentUserlat: CLLocationDegrees! = 0.0
    var CurrentUserlong: CLLocationDegrees! = 0.0
    var directionFloat: Double! = 0.0
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        btnReload.isEnabled = false;
        lblHeader.text = geobotName
        
        initLocation()
    }
    
    // MARK: - location initialization
    func initLocation() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Tap gesture to update node
    func addTapGestureToSceneView() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(adjustWindow))
        pinchGesture.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(pinchGesture)
    } 
    
    @objc func adjustWindow(_ gesture: UIGestureRecognizer) {
        // Fetch location for touch in sceneView
        let location: CGPoint = gesture.location(in: sceneView)
        // Fetch targets at the current location
        let hits = self.sceneView.hitTest(location, options: nil)
        // Check if it's a node and it's a window node that has been touched
        guard let node = hits.first?.node else {return}
        
        if gesture.numberOfTouches == 2, let pinchGesture = gesture as? UIPinchGestureRecognizer {
            switch pinchGesture.state {
            case .began:
                // Save start position, so that we can check how far the user have moved
                //  startPosition = location
                movingNode = true
            case .changed:
                let pinchScaleY: CGFloat = pinchGesture.scale * CGFloat((node.scale.y))
                let pinchScaleX: CGFloat = pinchGesture.scale * CGFloat((node.scale.x))
                node.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), node.scale.z)
                pinchGesture.scale = 1
                movingNode = false
            default:
                break
            }
        }
    }
    
    // MARK: - Touch delegates
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if let hit = sceneView.hitTest(touch.location(in: sceneView), options: nil).first {
            selectedNode = hit.node
            zDepth = sceneView.projectPoint(selectedNode.position).z
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingNode {
            guard selectedNode != nil else { return }
            let touch = touches.first!
            let touchPoint = touch.location(in: sceneView)
            selectedNode.position = sceneView.unprojectPoint(
                SCNVector3(x: Float(touchPoint.x),
                           y: Float(touchPoint.y),
                           z: zDepth))
        }
    }
    
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        selectedNode = nil
    //    }
    //
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        selectedNode = nil
    //    }
    
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
        //   plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode()
        planeNode.geometry = plane
        
        let cameraNod = sceneView.pointOfView
        planeNode.orientation = cameraNod!.orientation
        planeNode.position = SCNVector3(x, y, -0.2)
        planeNode.geometry?.firstMaterial?.diffuse.contents = img
        planeNode.opacity = 0.9
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        nodeAdded = true
    }
    
    func pointToAddNode() -> SCNVector3 {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let centerLocation = CGPoint(x: screenWidth/2, y: screenHeight/2)
        
        let hitTestResultsWithFeaturePoints : [ARHitTestResult] = sceneView.hitTest(centerLocation, types: .featurePoint)
        
        if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
            let finalTransform = hitTestResultWithFeaturePoints.worldTransform.translation
            let result = SCNVector3Make(finalTransform.x, finalTransform.y, finalTransform.z)
            return result
        } else {
            return SCNVector3Make(0, 0, 0)
        }
    }
    
    // MARK: - Api Calls
    func createGeobot() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
        }
        
        let header: HTTPHeaders = [
            "Content-Type" : "application/json",
            "developerid": "test",
            "channelid": channelId,
            "location": "",
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String
        ]
        let parameters: [String: AnyObject] = [
            "channelid": channelId,
            "ownerid": UserDefaults.standard.value(forKey: kUserId) as! String,
            "name": geobotName,
            "class":"com.imersia.default",
            "radius":0,
            "hidden": false,
            "location":[ "latitude": CommonFunctions.sharedInstance.CurrentUserlat ?? 0.0,
                         "longitude": CommonFunctions.sharedInstance.CurrentUserlong ?? 0.0,
                         "altitude": 0,
                         "geohash": ""
            ]
            ] as [String : AnyObject]
        
        
        netwoking.callPostApiWithSession(headers: header, apiMethod: kGeobots, params: parameters) { (response) in
            if response.result.value != nil {
                let dataDict = response.result.value as! NSDictionary
                self.geobotId = dataDict["geobotid"] as! String
                self .uploadMetaData()
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            }
        }
    }
    
    func uploadMetaData()  {
        
        if let node = selectedNode {
            selectedNode = node
        } else{
            let node = SCNNode()
            node.position =  SCNVector3(x: 0.0, y: 0.0, z: -2.0)
            node.scale =  SCNVector3(x: 0.0, y: 0.0, z: 0.0)
            selectedNode = node
        }
        
        let header: HTTPHeaders = [
            "geobotid": self.geobotId,
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String,
            "location": "",
            "developerid": "test",
            "Content-type": "application/json"
        ]
        
        let parameters: [String: AnyObject] = [
            "key": "data",
            "value":[
                [
                    "type": "position",
                    "values": [
                        "x": selectedNode.position.x,
                        "y": selectedNode.position.y,
                        "z": selectedNode.position.z
                    ]
                ],
                [
                    "type": "scale",
                    "values": [
                        "x": selectedNode.scale.x,
                        "y": selectedNode.scale.y,
                        "z": selectedNode.scale.z
                    ]
                ],
                [
                    "type": "direction",
                    "values": directionFloat!
                ]
            ]
            ] as [String : AnyObject]
        
        netwoking.callPostApiWithSession(headers: header, apiMethod: kMetaData, params: parameters) { (response) in
            if response.result.value != nil {
                self .uploadFile()
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            }
        }
    }
    
    func uploadFile() {
        guard let imgData = selectedImage.jpegData(compressionQuality: 0.2) else { return  }
        
        let header: HTTPHeaders = [
            "geobotid": self.geobotId,
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String,
            "location": "",
            "developerid": "test",
            "Content-type": "multipart/form-data"
        ]
        
        netwoking.requestWithMultipartWithSession(headers: header, apiMethod: kFiles, imageData: imgData as Data, onCompletion: { (response) in
            print("This is the files output: \(response.result.value as AnyObject)")
            self.commonFunctions.showAlertWithAction(title: kAppName, message: "Experience added successfully", controller: self, btnTitle: "Ok") {
                self.navigationController?.popViewController(animated: true)
            }
            ActivityLoader().hideActivityIndicator(uiView: self.view)
        }) { (error) in
            self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            ActivityLoader().hideActivityIndicator(uiView: self.view)
        }
    }
    
    // MARK: - IBActions
    @IBAction func btnReloadCicked(_ sender: Any) {
        //        sceneView.scene.rootNode.enumerateChildNodes {
        //            (node, stop) in
        //            node.removeFromParentNode()
        //        }
        //        nodeAdded = false
        //        btnClick.isEnabled = true;
        //        btnReload.isEnabled = false;
        //
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        nodeAdded = false
        btnClick.isEnabled = true;
        btnReload.isEnabled = false;
    }
    
    @IBAction func btnClickClicked(_ sender: Any) {
        if (!(nodeAdded)) {
            imageService.pickImage(from: self) {
                [weak self] image in
                
                let points = self?.pointToAddNode()
                if !(points!.z == 0) {
                    self?.addPlaneNode(x: points!.x, y: points!.y, z: points!.z, img: image)
                    self?.btnReload.isEnabled = true
                    self?.btnClick.isEnabled = false
                    self?.selectedImage = image
                    
                }
            }
            
            //            let points = pointToAddNode()
            //            if !(points.z == 0) {
            //                let objImage = UIImage(named: "background.jpg")!mainBg
            //                addPlaneNode(x: points.x, y: points.y, z: points.z, img: objImage)
            //                btnReload.isEnabled = true;
            //                btnClick.isEnabled = false;
            //            }
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        if (btnClick.isEnabled == false) {
            createGeobot()
        }
    }
    
    // MARK: - locationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        CurrentUserlat = (mostRecentLocation.coordinate.latitude) // get current location latitude
        CurrentUserlong = (mostRecentLocation.coordinate.longitude) //get current location longitude
       // locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
       
        directionFloat = newHeading.trueHeading.rounded(toPlaces: 0)
        
        print("heading----- \(String(describing: directionFloat))")
           
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
      //  locationManager.stopUpdatingLocation()
    }
    
}

extension float4x4 {
    var translation:  SIMD3<Float> {
        let translation = self.columns.3
        return  SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}

