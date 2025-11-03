//
//  LoginViewController.swift
//  ExploreMine
//
//  Created by Silstone on 19/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLoginPressed(_ sender: Any) {
        if txtFieldEmail.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter email address", in: self)
        } else if !(commonFunctions.isValidEmail(testStr: txtFieldEmail.text!)) {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter valid email address", in: self)
        } else if txtFieldPassword.text!.count == 0 {
            self.commonFunctions.ShowAlertWithoutTittle(message: "Enter password", in: self)
        } else {
            loginUser()
        }
    }
    
    @IBAction func btnSignUpPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if textField == txtFieldEmail {
            txtFieldPassword.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    // MARK: - Api Calls
    func loginUser() {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let header: HTTPHeaders = [
            "useremail": txtFieldEmail.text!,
            "password": txtFieldPassword.text!,
            "location": "",
            "developerid": "test"
        ]
        netwoking.callGetApi(apiMethod: kSessions, parameters: "", headers: header) { (response) in
          
            if response.result.value != nil {
                let dataDict = response.result.value as! NSDictionary
                
                if let val = dataDict["sessionid"] {
                    UserDefaults.standard.set(val, forKey: kSessionId)
                    UserDefaults.standard.set(self.txtFieldEmail.text, forKey: kUserEmail)
                    UserDefaults.standard.set(self.txtFieldPassword.text, forKey: kUserPassword)
                    self.getUserDetails()
                  
                    //  UserDefaults.standard.removeObject(forKey:kSessionId)
                } else if let val = dataDict["error"] {
                    if (val as! String == "password") {
                        self.commonFunctions.ShowAlertWithoutTittle(message: "Incorrect password", in: self)
                    } else  if (val as! String == "useremail" ) {
                        self.commonFunctions.ShowAlertWithoutTittle(message: "Incorrect email address", in: self)
                    }
                  ActivityLoader().hideActivityIndicator(uiView: self.view)
                }
            } else {
                  ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    func getUserDetails() {
        let header: HTTPHeaders = [
            "useremail": txtFieldEmail.text!,
            "password": txtFieldPassword.text!,
            "location": "",
            "developerid": "test",
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String
        ]
        netwoking.callGetApiWithSession(apiMethod: kUser, parameters: "", headers: header) { (response) in
            ActivityLoader().hideActivityIndicator(uiView: self.view)
            if response.result.value != nil {
                let dataDict = response.result.value as! NSDictionary
                if let val = dataDict["userid"] {
                    UserDefaults.standard.set(val, forKey: kUserId)
//                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "channelsVC") as? ChannelsViewController
                      let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            } else {
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
            
        }
    }
}
