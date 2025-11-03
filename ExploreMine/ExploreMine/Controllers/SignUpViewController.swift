//
//  SignUpViewController.swift
//  ExploreMine
//
//  Created by Silstone on 28/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import CoreLocation

class SignUpViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var txtFieldLocation: UITextField!
    @IBOutlet weak var txtFieldAge: UITextField!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    let locationManager = CLLocationManager()
    var userlat: CLLocationDegrees! = 0.0
    var userlong: CLLocationDegrees! = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.initLocationManager()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - GoogleMaps initialization
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - locationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        userlat = (mostRecentLocation.coordinate.latitude) // get current location latitude
        userlong = (mostRecentLocation.coordinate.longitude) //get current location longitude
        
        CLGeocoder().reverseGeocodeLocation(mostRecentLocation) { (placemark, error) in
            if error != nil {
                print("THERE WAS AN ERROR")
            } else {
                if let place = placemark?[0] {
                    if place.location != nil {
                        self.lblLocation.text = "\(place.locality!), \(place.country!)"
                        manager.stopUpdatingLocation()
                    }
                }
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if textField == txtFieldName {
            txtFieldEmail.becomeFirstResponder()
        } else if textField == txtFieldEmail {
            txtFieldPassword.becomeFirstResponder()
        } else if textField == txtFieldPassword {
            txtFieldConfirmPassword.becomeFirstResponder()
        } else if textField == txtFieldConfirmPassword {
            txtFieldLocation.becomeFirstResponder()
        } else if textField == txtFieldLocation {
            txtFieldAge.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    // MARK: - IBActions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUpPressed(_ sender: Any) {
        if txtFieldName.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter name", in: self)
        } else if txtFieldEmail.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter email address", in: self)
        } else if !(commonFunctions.isValidEmail(testStr: txtFieldEmail.text!)) {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter valid email address", in: self)
        } else if txtFieldPassword.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter password", in: self)
        } else if txtFieldConfirmPassword.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter confirm password", in: self)
        } else if (txtFieldPassword.text! != txtFieldConfirmPassword.text!) {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Password not matched !", in: self)
        } else if lblLocation.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Select location", in: self)
        } else if txtFieldAge.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter age", in: self)
        } else {
            signUpUser()
        }
    }
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        let vc = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController)!
        self.navigationController?.popPushToVC(ofKind: LoginViewController.self, pushController: vc)
    }
    
    @IBAction func btnLocationPressed(_ sender: Any) {
        let vc = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchLocation") as? SearchLocation)!
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Api Calls
    
    func signUpUser() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
        }
        
        let header: HTTPHeaders = [
            "Content-Type" : "application/json",
            "developerid": "test",
            "location": "",
            "sessionid": "",
            "userid": ""
        ]
        let parameters: [String: AnyObject] = [
            "useremail": txtFieldEmail.text!,
            "password": txtFieldPassword.text!,
            "passcode": "",
            "details":[ "firstname": txtFieldName.text!,
                        "surname": "",
                        "nickname": "",
                        "imageurl": ""
            ],
            "location":[ "latitude": userlat ?? 0.0,
                         "longitude": userlong ?? 0.0,
                         "altitude": 0,
                         "geohash": ""
            ]
            ] as [String : AnyObject]
        
        
        netwoking.callPostApi(headers: header, apiMethod: kUser, params: parameters) { (response) in
            if response.result.value != nil {
                let dataDict = response.result.value as! NSDictionary
                
                if let val = dataDict["userid"]  {
                    UserDefaults.standard.set(val, forKey: kUserId)
                    UserDefaults.standard.set(self.txtFieldEmail.text, forKey: kUserEmail)
                    UserDefaults.standard.set(self.txtFieldPassword.text, forKey:kUserPassword)
                    self.netwoking.getSession { (response) in
                        self.uploadUserMetaData()
                    }
                } else if let val = dataDict["error"] {
                    if (val as! String == "useremail") {
                        self.commonFunctions.ShowAlertWithoutTittle(message: "Email already used", in: self)
                    }
                    ActivityLoader().hideActivityIndicator(uiView: self.view)
                }
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            }
        }
    }
    
    func uploadUserMetaData()  {
        let header: HTTPHeaders = [
            "userid": UserDefaults.standard.value(forKey: kUserId) as! String,
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String,
            "location": "",
            "developerid": "test",
            "Content-type": "application/json"
        ]
        
        let parameters: [String: AnyObject] = [
            "key": "userInfo",
            "value":[
                [
                    "locationName": self.lblLocation.text
                ]
            ]
            ] as [String : AnyObject]
        
        netwoking.callPostApiWithSession(headers: header, apiMethod: kMetaData, params: parameters) { (response) in
            ActivityLoader().hideActivityIndicator(uiView: self.view)
            if response.result.value != nil {
                
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }
        }
    }
    
}

@available(iOS 13.0, *)
extension SignUpViewController: Passdata{
    
    func passdata(str: String) {
        self.lblLocation.text = str
    }
    func latitude(lats: Double) {
        userlat = lats
    }
    func longitude(long: Double) {
        userlong = long
    }
}
