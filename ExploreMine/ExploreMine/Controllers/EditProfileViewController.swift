//
//  EditProfileViewController.swift
//  ExploreMine
//
//  Created by Silstone on 03/02/20.
//  Copyright © 2020 SilstoneGroup. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    var passwordVisible = false
    @IBOutlet weak var circelView: UIView!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var imgUser: UIImageView!
    
    // MARK: - variables declaration
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        circelView.setBorder(radius: 60, color: commonFunctions.hexStringToUIColor(hex: "#30FF30"))
        circelView.layer.borderWidth = 2
    }
    
    // MARK: - IBActions
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnViewPasswordPressed(_ sender: Any) {
        if(passwordVisible) {
            txtFieldPassword.isSecureTextEntry = true
        } else {
            txtFieldPassword.isSecureTextEntry = false
        }
        passwordVisible = !passwordVisible
    }
    
    @IBAction func btnSelectPhotoPressed(_ sender: Any) {
        
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
    }
    
}
