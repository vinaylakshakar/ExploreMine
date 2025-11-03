//
//  CommonFunctions.swift
//  ExploreMine
//
//  Created by Silstone on 01/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

class CommonFunctions: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = CommonFunctions()
    
    let locationManager : CLLocationManager
    var CurrentUserlat: CLLocationDegrees! = 0.0
    var CurrentUserlong: CLLocationDegrees! = 0.0
    
    override init() {
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        locationManager.delegate = self
        // do initial setup or establish an initial connection
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = kEmailValidation
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func ShowAlert(title: String, message: String, in vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func ShowAlertWithoutTittle(message: String, in vc: UIViewController) {
           let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
           alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
           vc.present(alert, animated: true, completion: nil)
       }
    
    func showAlertWithAction(title:String, message:String, controller:UIViewController, btnTitle:String, completionHandler: @escaping () -> ()) {
         
          let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
          
          let action = UIAlertAction(title: btnTitle, style: .default, handler:
          {(alert: UIAlertAction!) in
              completionHandler()
          })
          alertController.addAction(action)

          controller.present(alertController, animated: true, completion: nil)
      }
    
    func showAlertWithMutipleActions(message:String, title:String, controller:UIViewController, firstBtnTitle:String, secondBtnTitle:String, completionHandler: @escaping (_ ActionNo:Int) -> ()) {
        var _btnActionNo : Int = 0
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let Action_1 = UIAlertAction(title: firstBtnTitle, style: .default, handler:
        {(alert: UIAlertAction!) in
            _btnActionNo = 1
            completionHandler(_btnActionNo)
        })
        alertController.addAction(Action_1)
        
        if(secondBtnTitle != "")
        {
            let Action_2 = UIAlertAction(title: secondBtnTitle, style: .default, handler:
            {(alert: UIAlertAction!) in
                _btnActionNo = 2
                completionHandler(_btnActionNo)
            })
            alertController.addAction(Action_2)
        }
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func start() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 500
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        CurrentUserlat = (mostRecentLocation.coordinate.latitude) // get current location latitude
        CurrentUserlong = (mostRecentLocation.coordinate.longitude) //get current location longitude
        print("current locations: \(CurrentUserlat!), \(CurrentUserlong!)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationManager.stopUpdatingLocation()
    }
    
    func addMarker(lat:Double, long:Double, map:GMSMapView, info:String, pinTitle:String, description:String) {
        
         let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
         let marker = GMSMarker()
         marker.position = location
         marker.userData = info
         marker.title = description
         marker.snippet = pinTitle
         marker.map = map
     }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImage {
  class func outlinedEllipse(size: CGSize, color: UIColor, lineWidth: CGFloat = 1.0) -> UIImage? {
      UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
      guard let context = UIGraphicsGetCurrentContext() else {
          return nil
      }

      context.setStrokeColor(color.cgColor)
      context.setLineWidth(lineWidth)
      let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
      context.addEllipse(in: rect)
      context.strokePath()

      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image
  }
}

extension UINavigationController {

    func containsViewController(ofKind kind: AnyClass) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }

    func popPushToVC(ofKind kind: AnyClass, pushController: UIViewController) {
        if containsViewController(ofKind: kind) {
            for controller in self.viewControllers {
                if controller.isKind(of: kind) {
                    popToViewController(controller, animated: true)
                    break
                }
            }
        } else {
            pushViewController(pushController, animated: true)
        }
    }
}

extension UIView{

    func setBorder(radius:CGFloat, color:UIColor = UIColor.clear) {
        let roundView:UIView = self
        roundView.layer.cornerRadius = CGFloat(radius)
        roundView.layer.borderWidth = 1
        roundView.layer.borderColor = color.cgColor
        roundView.clipsToBounds = true
    }
}

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

