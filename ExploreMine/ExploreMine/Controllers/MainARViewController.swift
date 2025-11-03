//
//  MainARViewController.swift
//  ExploreMine
//
//  Created by Silstone on 11/12/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import QuartzCore

class MainARViewController: UIViewController {

      @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .vertical
                sceneView.session.run(configuration)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnClickClicked(_ sender: Any) {
    
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//         super.viewWillAppear(animated)
//
//     }
//
//    override func viewWillDisappear(_ animated: Bool) {
//          super.viewWillDisappear(animated)
//          sceneView.session.pause()
//      }
//

}
