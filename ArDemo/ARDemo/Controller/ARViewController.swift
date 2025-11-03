//
//  ARViewController.swift
//  ARDemo
//
//  Created by Silstone on 18/12/19.
//  Copyright © 2019 Silstone. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import GLKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var augmentedRealityView: ARSCNView!
    
    let augmentedRealitySession = ARSession()
    let configuration = ARWorldTrackingConfiguration()
    var nodeWeCanChange: SCNNode?
    var updatedTransation : SCNVector3 = SCNVector3()
 
    var movingNode = Bool(false)
       
        var selectedNode: SCNNode!
       
        var zDepth: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        augmentedRealityView.session.delegate = self
         augmentedRealityView.session.run(configuration)
        

    
        
         addTapGestureToSceneView()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let extent = planeAnchor.extent
        let center = planeAnchor.center
        // planeAnchor.transform not used, because ARSCNView automatically applies it
        // to the container node, and we make a child of the container node

        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = .pi / 2
        planeNode.simdPosition = center
        node.addChildNode(planeNode)
    }
    
    // MARK: - Tap gesture to update node
         func addTapGestureToSceneView() {
             let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(adjustWindow))
             pinchGesture.cancelsTouchesInView = false
             augmentedRealityView.addGestureRecognizer(pinchGesture)
         }
         
         @objc func adjustWindow(_ gesture: UIGestureRecognizer) {
             // Fetch location for touch in sceneView
             let location: CGPoint = gesture.location(in: augmentedRealityView)
             // Fetch targets at the current location
             let hits = self.augmentedRealityView.hitTest(location, options: nil)
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
             if let hit = augmentedRealityView.hitTest(touch.location(in: augmentedRealityView), options: nil).first {
               selectedNode = hit.node
               zDepth = augmentedRealityView.projectPoint(selectedNode.position).z
             }
           }
           
           override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
               if !movingNode {
                   guard selectedNode != nil else { return }
                   let touch = touches.first!
                   let touchPoint = touch.location(in: augmentedRealityView)
                   selectedNode.position = augmentedRealityView.unprojectPoint(
                       SCNVector3(x: Float(touchPoint.x),
                                  y: Float(touchPoint.y),
                                  z: zDepth))
               }
           }

//           override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//             selectedNode = nil
//           }
//
//           override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//             selectedNode = nil
//           }
    
    func setupCamera() {
           guard let camera = augmentedRealityView.pointOfView?.camera else {
               fatalError("Expected a valid `pointOfView` from the scene.")
           }
           /*
            Enable HDR camera settings for the most realistic appearance
            with environmental lighting and physically based materials.
            */
           camera.wantsHDR = true
           camera.exposureOffset = -1
           camera.minimumExposure = -1
           camera.maximumExposure = 3
       }
    
    func createObject(at position : SCNVector3) -> SCNNode {
        let sphere = SCNPlane(width: 0.1, height: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "pin")
        sphere.firstMaterial = material
        let node = SCNNode(geometry: sphere)
        node.position = position
        return node
    }
    
    struct PlaneInfo { // something to save and restore ARPlaneAnchor data
        let transform: float4x4
        let center: float3
        let extent: float3
    }
    func makePlane(from planeInfo: PlaneInfo) { // call this when you place content
        let extent = planeInfo.extent
        let center = float4(planeInfo.center, 1) * planeInfo.transform
        // we're positioning content in world space, so center is now
        // an offset relative to transform

        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = .pi / 2
        planeNode.simdPosition = center.xyz
        augmentedRealityView.scene.rootNode.addChildNode(planeNode)
    }
    
    @IBAction func btnClickClicked(_ sender: Any) {
        
        augmentedRealityView.session.pause()
        augmentedRealityView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        augmentedRealityView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        setupCamera()
        var object = SCNNode()
     //   let position = updatedTransation
        let position = SCNVector3(0, 0, -0.6)
        object = createObject(at: position)
        
        
        
        augmentedRealityView.scene.rootNode.addChildNode(object)
    }
    
    @IBAction func btnReloadCicked(_ sender: Any) {
        
        augmentedRealityView.session.pause()
        augmentedRealityView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        augmentedRealityView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        nodeAdded = false
//        btnClick.isEnabled = true;
//        btnReload.isEnabled = false;
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
        let currentTransform = frame.camera.transform
        updatedTransation = currentTransform.position()
      
    }
    
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//
//        //1. If We Havent Create Our Interactive Node Then Proceed
//        if nodeWeCanChange == nil{
//
//            //a. Check We Have Detected An ARPlaneAnchor
//            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//            //b. Get The Size Of The ARPlaneAnchor
//            let width = CGFloat(planeAnchor.extent.x)
//            let height = CGFloat(planeAnchor.extent.z)
//
//            //c. Create An SCNPlane Which Matches The Size Of The ARPlaneAnchor
//            nodeWeCanChange = SCNNode(geometry: SCNPlane(width: width, height: height))
//
//            //d. Rotate It
//            nodeWeCanChange?.eulerAngles.x = -.pi/2
//
//            //e. Set It's Colour To Red
//            nodeWeCanChange?.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//
//            //f. Add It To Our Node & Thus The Hiearchy
//            node.addChildNode(nodeWeCanChange!)
//        }
//
//    }
    
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}

// convenience vector-width conversions used above
extension float4 {
    init(_ xyz: float3, _ w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, 1)
    }
    var xyz: float3 {
        return float3(self.x, self.y, self.z)
    }
}

