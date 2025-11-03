//
//  ProfileViewController.swift
//  ExploreMine
//
//  Created by Silstone on 11/12/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var profileBgView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserLocation: UILabel!
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    // MARK: - variables declaration
    var commonFunctions = CommonFunctions()
    var netwoking = NetworkApi()
    let reuseIdentifier = "postsCell"
    var userInfo = NSDictionary()
    var userLocation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // check the permission status
        getUserDetails()
    }
    
    func initUI() {
        profileBgView.setBorder(radius: profileBgView.frame.standardized.size.width/2, color: commonFunctions.hexStringToUIColor(hex: "30FF30"))
        profileImgView.layer.cornerRadius = profileImgView.frame.standardized.size.width/2
    }
    
    func updateUI() {
        let detailsDict = userInfo["details"] as! NSDictionary
        lblUserName.text = detailsDict["firstname"] as? String
        lblUserLocation.text = self.userLocation
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    // MARK: - Api Calls
    
    func getUserDetails() {
        let header: HTTPHeaders = [
            "userid": UserDefaults.standard.value(forKey: kUserId) as! String,
            "location": "",
            "developerid": "test",
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String
        ]
        netwoking.callGetApiWithSession(apiMethod: kUser, parameters: "", headers: header) { (response) in
            ActivityLoader().hideActivityIndicator(uiView: self.view)
            if response.result.value != nil {
                self.userInfo = response.result.value as! NSDictionary
                self.getUserMetadata()
                
            } else {
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    func getUserMetadata() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let header: HTTPHeaders = [
            "userid": UserDefaults.standard.value(forKey: kUserId) as! String,
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String,
            "location": "",
            "developerid": kDeveloperId
        ]
        netwoking.callGetApi(apiMethod: kMetaData, parameters: "", headers: header) { (response) in
            ActivityLoader().hideActivityIndicator(uiView: self.view)
            if response.result.value != nil {
                print("This is the files output: \(response.result.value as AnyObject)")
                let dataDict = response.result.value as! [NSDictionary]
                let dataValue = dataDict[0]["value"] as! [NSDictionary]
                self.userLocation = (dataValue[0]["locationName"] as? String)!
                self.updateUI()
                
                //                   for item in dataValue {
                //                       if (item["type"] as! String == "position") {
                //                           let dataArr = item["values"] as! NSDictionary
                //                           let x = dataArr["x"] as! NSNumber
                //                           let y = dataArr["y"] as! NSNumber
                //                           let z = dataArr["z"] as! NSNumber
                //                           self.geobotPosition = SCNVector3Make(Float(truncating: x), Float(truncating: y), Float(truncating: z))
                //                       } else  if (item["type"] as! String == "scale") {
                //                           let dataArr = item["values"] as! NSDictionary
                //                           let x = dataArr["x"] as! NSNumber
                //                           let y = dataArr["y"] as! NSNumber
                //                           let z = dataArr["z"] as! NSNumber
                //                           self.geobotScale = SCNVector3Make(Float(truncating: x), Float(truncating: y), Float(truncating: z))
                //                           //                         self.geobotScale = SCNVector3Make(Float(truncating: NSNumber(value: Int(truncating: x)/2)), Float(truncating: NSNumber(value: Int(truncating: y)/2)), Float(truncating: NSNumber(value: Int(truncating: z)/2)))
                //                       } else  if (item["type"] as! String == "direction") {
                //
                //                           self.detectedDirectionFloat = (item["values"] as! double_t)
                //
                //                       }
                //                   }
                
            } else {
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostsCollectionViewCell
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        //        print("You selected cell #\(indexPath.item)!")
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: 144, height: 144)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func btnEditProfilePressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func btnLogoutPressed(_ sender: Any) {
        commonFunctions.showAlertWithMutipleActions(message: "Are you sure to Log Out ?", title: kAppName, controller: self, firstBtnTitle: "Yes", secondBtnTitle: "No") { (optionIndex) in
            if (optionIndex == 1) {
                self.logoutUser()
            }
        }
    }
    
    func logoutUser()  {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(true, forKey: kTutorialViewed)
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let ViewController = mainStoryBoard.instantiateViewController(withIdentifier: "loginNavigation")
        UIApplication.shared.windows.first?.rootViewController = ViewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
}
