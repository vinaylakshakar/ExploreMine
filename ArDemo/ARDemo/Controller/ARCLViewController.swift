//
//  ARCLViewController.swift
//  ARDemo
//
//  Created by Silstone on 17/12/19.
//  Copyright © 2019 Silstone. All rights reserved.
//

import UIKit
import ARCL
import ARKit
import SceneKit
//import MapKit

class ARCLViewController: UIViewController {

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet weak var nodePositionLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    let sceneLocationView = SceneLocationView()
    
//    var userAnnotation: MKPointAnnotation?
//    var locationEstimateAnnotation: MKPointAnnotation?
    
 //   var updateUserLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?
    
//    let adjustNorthByTappingSidesOfScreen = true
    //     let addNodeByTappingScreen = true
    //     let displayDebugging = true
    
  //  var routes: [MKRoute]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                                     object: nil,
                                                     queue: nil) { [weak self] _ in
                                                      self?.pauseAnimation()
              }
              // swiftlint:disable:next discarded_notification_center_observer
              NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                     object: nil,
                                                     queue: nil) { [weak self] _ in
                                                      self?.restartAnimation()
              }
        

        updateInfoLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateInfoLabel()
        }
        
          // Set to true to display an arrow which points north.
                // Checkout the comments in the property description and on the readme on this.
        //        sceneLocationView.orientToTrueNorth = false
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly

                sceneLocationView.showAxesNode = true
        //        sceneLocationView.showFeaturePoints = displayDebugging
               sceneLocationView.locationNodeTouchDelegate = self
        //        sceneLocationView.delegate = self // Causes an assertionFailure - use the `arViewDelegate` instead:
                sceneLocationView.arViewDelegate = self
               sceneLocationView.locationNodeTouchDelegate = self

                // Now add the route or location annotations as appropriate
             //   addSceneModels()

                contentView.addSubview(sceneLocationView)
                sceneLocationView.frame = contentView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        restartAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           print(#function)
           pauseAnimation()
        
           super.viewWillDisappear(animated)
       }

       func pauseAnimation() {
           print("pause")
           sceneLocationView.pause()
       }

       func restartAnimation() {
           print("run")
            sceneLocationView.run()
       }
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           sceneLocationView.frame = contentView.bounds
       }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        guard let touch = touches.first,
//            let view = touch.view else { return }
//
//
//            let location = touch.location(in: self.view)
//
//            if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
//                print("left side of the screen")
//                sceneLocationView.moveSceneHeadingAntiClockwise()
//            } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
//                print("right side of the screen")
//                sceneLocationView.moveSceneHeadingClockwise()
//            } else if addNodeByTappingScreen {
//                let image = UIImage(named: "pin")!
//                let annotationNode = LocationAnnotationNode(location: nil, image: image)
//                annotationNode.scaleRelativeToDistance = false
//                annotationNode.scalingScheme = .normal
//                annotationNode.position = SCNVector3(0, 0, -0.2)
//                DispatchQueue.main.async {
//                    // If we're using the touch delegate, adding a new node in the touch handler sometimes causes a freeze.
//                    // So defer to next pass.
//                    self.sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
//                }
//            }
//    }
    
        /// Adds the appropriate ARKit models to the scene.  Note: that this won't
        /// do anything until the scene has a `currentLocation`.  It "polls" on that
        /// and when a location is finally discovered, the models are added.
//        func addSceneModels() {
//            // 1. Don't try to add the models to the scene until we have a current location
//            guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//                    self?.addSceneModels()
//                }
//                return
//            }
//
//            let box = SCNBox(width: 1, height: 0.2, length: 5, chamferRadius: 0.25)
//            box.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
//
//            // 2. If there is a route, show that
//            if let routes = routes {
//                sceneLocationView.addRoutes(routes: routes) { distance -> SCNBox in
//                    let box = SCNBox(width: 1.75, height: 0.5, length: distance, chamferRadius: 0.25)
//
//    //                // Option 1: An absolutely terrible box material set (that demonstrates what you can do):
//    //                box.materials = ["box0", "box1", "box2", "box3", "box4", "box5"].map {
//    //                    let material = SCNMaterial()
//    //                    material.diffuse.contents = UIImage(named: $0)
//    //                    return material
//    //                }
//
//                    // Option 2: Something more typical
//                    box.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
//                    return box
//                }
//            } else {
//                // 3. If not, then show the
//                buildDemoData().forEach {
//                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
//                }
//            }
//
//            // There are many different ways to add lighting to a scene, but even this mechanism (the absolute simplest)
//            // keeps 3D objects fron looking flat
//            sceneLocationView.autoenablesDefaultLighting = true
//
//        }
    
    /// Builds the location annotations for a few random objects, scattered across the country
      ///
      /// - Returns: an array of annotation nodes.
//      func buildDemoData() -> [LocationAnnotationNode] {
//          var nodes: [LocationAnnotationNode] = []
//
//          let spaceNeedle = buildNode(latitude: 47.6205, longitude: -122.3493, altitude: 225, imageName: "pin")
//          nodes.append(spaceNeedle)
//
//          let empireStateBuilding = buildNode(latitude: 40.7484, longitude: -73.9857, altitude: 14.3, imageName: "pin")
//          nodes.append(empireStateBuilding)
//
//          let canaryWharf = buildNode(latitude: 51.504607, longitude: -0.019592, altitude: 236, imageName: "pin")
//          nodes.append(canaryWharf)
//
//          let applePark = buildViewNode(latitude: 37.334807, longitude: -122.009076, altitude: 100, text: "Apple Park")
//          nodes.append(applePark)
//
//          let theAlamo = buildViewNode(latitude: 29.4259671, longitude: -98.4861419, altitude: 300, text: "The Alamo")
//          nodes.append(theAlamo)
//
//          let pikesPeakLayer = CATextLayer()
//          pikesPeakLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//          pikesPeakLayer.cornerRadius = 4
//          pikesPeakLayer.fontSize = 14
//          pikesPeakLayer.alignmentMode = .center
//          pikesPeakLayer.foregroundColor = UIColor.black.cgColor
//          pikesPeakLayer.backgroundColor = UIColor.white.cgColor
//
//          // This demo uses a simple periodic timer to showcase dynamic text in a node.  In your implementation,
//          // the view's content will probably be changed as the result of a network fetch or some other asynchronous event.
//
//          _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//              pikesPeakLayer.string = "Pike's Peak\n" + Date().description
//          }
//
//          let pikesPeak = buildLayerNode(latitude: 38.8405322, longitude: -105.0442048, altitude: 4705, layer: pikesPeakLayer)
//          nodes.append(pikesPeak)
//
//          return nodes
//      }
//
//    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
//                      altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
//           let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//           let location = CLLocation(coordinate: coordinate, altitude: altitude)
//           let image = UIImage(named: imageName)!
//           return LocationAnnotationNode(location: location, image: image)
//       }
//
//       func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
//                          altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
//           let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//           let location = CLLocation(coordinate: coordinate, altitude: altitude)
//           let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//           label.text = text
//           label.backgroundColor = .green
//           label.textAlignment = .center
//           return LocationAnnotationNode(location: location, view: label)
//       }
//
//       func buildLayerNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
//                           altitude: CLLocationDistance, layer: CALayer) -> LocationAnnotationNode {
//           let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//           let location = CLLocation(coordinate: coordinate, altitude: altitude)
//           return LocationAnnotationNode(location: location, layer: layer)
//       }

    @objc
    func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition {
            infoLabel.text = " x: \(position.x.short), y: \(position.y.short), z: \(position.z.short)\n"
        }

        if let eulerAngles = sceneLocationView.currentEulerAngles {
            infoLabel.text!.append(" Euler x: \(eulerAngles.x.short), y: \(eulerAngles.y.short), z: \(eulerAngles.z.short)\n")
        }

        if let eulerAngles = sceneLocationView.currentEulerAngles,
            let heading = sceneLocationView.sceneLocationManager.locationManager.heading,
            let headingAccuracy = sceneLocationView.sceneLocationManager.locationManager.headingAccuracy {
            let yDegrees = (((0 - eulerAngles.y.radiansToDegrees) + 360).truncatingRemainder(dividingBy: 360) ).short
            infoLabel.text!.append(" Heading: \(yDegrees)° • \(Float(heading).short)° • \(headingAccuracy)°\n")
        }

        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: Date())
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            let nodeCount = "\(sceneLocationView.sceneNode?.childNodes.count.description ?? "n/a") ARKit Nodes"
            infoLabel.text!.append(" \(hour.short):\(minute.short):\(second.short):\(nanosecond.short3) • \(nodeCount)")
        }
    }
    
    
      // MARK: - IBActions
    
    @IBAction func btnClickClicked(_ sender: Any) {
        
        let image = UIImage(named: "pin")!
        let annotationNode = LocationAnnotationNode(location: nil, image: image)
        annotationNode.scaleRelativeToDistance = true
        annotationNode.scalingScheme = .normal
        annotationNode.tag = "\(sceneLocationView.sceneNode?.childNodes.count.description ?? "not defined")"
        DispatchQueue.main.async {
            // If we're using the touch delegate, adding a new node in the touch handler sometimes causes a freeze.
            // So defer to next pass.
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        }
        
    }
    
      
    @IBAction func btnReloadCicked(_ sender: Any) {
        
        self.sceneLocationView.removeAllNodes()
        
        pauseAnimation()
        restartAnimation()
    }

}

// MARK: - LNTouchDelegate
@available(iOS 11.0, *)
extension ARCLViewController: LNTouchDelegate {

    func annotationNodeTouched(node: AnnotationNode) {
        if let node = node.parent as? LocationNode {
            let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
            let altitude = "\(node.location.altitude.short)m"
            let tag = node.tag ?? ""
            nodePositionLabel.text = " Annotation node at \(coords), \(altitude) - \(tag)"
        }
    }

    func locationNodeTouched(node: LocationNode) {
        print("Location node touched - tag: \(node.tag ?? "")")
        let coords = "\(node.location.coordinate.latitude.short)° \(node.location.coordinate.longitude.short)°"
        let altitude = "\(node.location.altitude.short)m"
        let tag = node.tag ?? ""
        nodePositionLabel.text = " Location node at \(coords), \(altitude) - \(tag)"
    }

}
