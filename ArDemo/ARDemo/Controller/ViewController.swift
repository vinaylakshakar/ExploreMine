//
//  ViewController.swift
//  ARDemo
//
//  Created by Silstone on 17/12/19.
//  Copyright © 2019 Silstone. All rights reserved.
//

import UIKit
import ARCoreLocation
import ARKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, ARLandmarkerDelegate {

      @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let landmarker = ARLandmarker(view: ARSKView(), scene: InteractiveScene(), locationManager: CLLocationManager())
        landmarker.view.frame = self.view.bounds
        landmarker.scene.size = self.view.bounds.size
        contentView.addSubview(landmarker.view)
        
        let landmarkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 20))
        landmarkLabel.text = "Statue of Liberty"
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 30.696928257426343, longitude: 76.720793091018109), altitude: 30, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        landmarker.addLandmark(view: landmarkLabel, at: location, completion: nil)
        
        landmarker.delegate = self
        
        
//        CurrentUserlat    CLLocationDegrees?    30.696928257426343
//        error: 'CurrentUserlat' is not a valid command.
//        (lldb) CurrentUserlong    CLLocationDegrees?    76.720793091018109
        
    }
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didTap landmark: ARLandmark) {
          
       }
       
       func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didFailWithError error: Error) -> Void {
          
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
