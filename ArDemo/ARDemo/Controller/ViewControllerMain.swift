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
import ARCoreLocation

class ViewControllerMain: UIViewController, ARSCNViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var btnReload: UIButton!
    @IBOutlet weak var btnClick: UIButton!
    
    // MARK: - variables declaration
    private let imageService = ImagePickerService()
    let imagePicker = UIImagePickerController()
    var updateSceneViewInfo: Timer?
//    var startPosition = CGPoint(x: 0, y: 0)
    var selectedNode: SCNNode!
    var zDepth: Float!
    var nodeAdded = Bool(false)
    var movingNode = Bool(false)
    
     // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        btnReload.isEnabled = false;
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

      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedNode = nil
      }

      override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedNode = nil
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
     //   plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode()
        planeNode.geometry = plane
    
        let cameraNod = sceneView.pointOfView
        planeNode.orientation = cameraNod!.orientation
        planeNode.position = SCNVector3(0, 0, -0.2)
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
                    self?.btnReload.isEnabled = true;
                    self?.btnClick.isEnabled = false;
                }
            }
//            let points = pointToAddNode()
//            if !(points.z == 0) {
//                let objImage = UIImage(named: "background.jpg")!
//                addPlaneNode(x: points.x, y: points.y, z: points.z, img: objImage)
//                btnReload.isEnabled = true;
//                btnClick.isEnabled = false;
//            }
        }
    }
}

extension float4x4 {
    var translation:  SIMD3<Float> {
        let translation = self.columns.3
        return  SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}

