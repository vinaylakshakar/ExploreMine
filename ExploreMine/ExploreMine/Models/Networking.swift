//
//  Networking.swift
//  ExploreMine
//
//  Created by Silstone on 01/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkApi: NSObject{
    
    //MARK: check session
    func checkSession(completion: @escaping (Bool) -> Void) {
        
        if let sessionId = UserDefaults.standard.value(forKey: kSessionId) {
            let header: HTTPHeaders = [
                "sessionid": sessionId as! String,
                "useremail": UserDefaults.standard.value(forKey: kUserEmail) as! String,
                "location": "",
                "developerid": kDeveloperId
            ]
            
            let originalString = "\(kBaseUrl)\(kSessions)"
            let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let serviceUrl = URL(string:urlString!)
            Alamofire.request(serviceUrl!, method: .head, encoding: JSONEncoding.default,headers: header).responseJSON { (response) in
                
                let statusCode = (response.response?.statusCode)!
                if (statusCode == 200) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func getSession(completion: @escaping (_ response: DataResponse<Any>) -> Void) {
        
        if let userEmail = UserDefaults.standard.value(forKey: kUserEmail), let userPassword = UserDefaults.standard.value(forKey: kUserPassword) {
            
            let header: HTTPHeaders = [
                "useremail": userEmail as! String,
                "password": userPassword as! String,
                "location": "",
                "developerid": kDeveloperId
            ]
            
            let originalString = "\(kBaseUrl)\(kSessions)"
            let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let serviceUrl = URL(string:urlString!)
            Alamofire.request(serviceUrl!, method: .get, encoding: JSONEncoding.default,headers: header).responseJSON { (response) in
                let dataDict = response.result.value as! NSDictionary
                if let val = dataDict["sessionid"] {
                    UserDefaults.standard.set(val, forKey: kSessionId)
                }
                completion(response)
            }
        }
    }
    
    
    //MARK: GET API
    func callGetApi(apiMethod:String, parameters:String, headers:HTTPHeaders, completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        let originalString = "\(kBaseUrl)\(apiMethod)"
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let serviceUrl = URL(string:urlString!) else { return }
        Alamofire.request(serviceUrl, method: .get, encoding: JSONEncoding.default,headers: headers).responseJSON { (response) in
            completionHandler(response)
        }
    }
    
    //MARK: GET
    func callGetBaseApi(apiMethod:String, parameters:String, headers:HTTPHeaders, completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        let originalString = "\(kServerUrl)\(apiMethod)"
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let serviceUrl = URL(string:urlString!) else { return }
        Alamofire.request(serviceUrl, method: .get, encoding: JSONEncoding.default,headers: headers).responseJSON { (response) in
            completionHandler(response)
        }
    }
    
    
    
    
    func callGetApiWithSession(apiMethod:String, parameters:String, headers:HTTPHeaders, completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        checkSession { (isSession) in
            if isSession {
                self.callGetApi(apiMethod: apiMethod, parameters: parameters, headers: headers) { (response) in
                    completionHandler(response)
                }
            } else {
                self.getSession() { (response) in
                    self.callGetApi(apiMethod: apiMethod, parameters: parameters, headers: headers) { (response) in
                        completionHandler(response)
                    }
                }
            }
        }
    }
    
    //MARK: Delete API
    func callDeleteApi(apiMethod:String, parameters:String, headers:HTTPHeaders, completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        
        checkSession { (isSession) in
            if isSession {
                let originalString = "\(kBaseUrl)\(apiMethod)"
                let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                guard let serviceUrl = URL(string:urlString!) else { return }
                Alamofire.request(serviceUrl, method: .delete, encoding: JSONEncoding.default,headers: headers).responseJSON { (response) in
                    completionHandler(response)
                }
            } else {
                self.getSession() { (response) in
                    
                    let originalString = "\(kBaseUrl)\(apiMethod)"
                    let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    guard let serviceUrl = URL(string:urlString!) else { return }
                    Alamofire.request(serviceUrl, method: .delete, encoding: JSONEncoding.default,headers: headers).responseJSON { (response) in
                        completionHandler(response)
                    }
                }
            }
        }
    }
    
    //MARK: POST API FOR MAKE UNFAVOURITE
    func callPostApi(headers:HTTPHeaders, apiMethod:String, params:[String : Any], completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        
        let originalString = "\(kBaseUrl)\(apiMethod)"
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let serviceUrl = URL(string:urlString!) else { return }
        Alamofire.request(serviceUrl,method: .post,parameters: params,encoding: JSONEncoding.default,headers: headers).responseJSON { (response)  in
            completionHandler(response)
        }
    }
    
    func callPostApiWithSession(headers:HTTPHeaders, apiMethod:String, params:[String : Any], completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        
        checkSession { (isSession) in
            if isSession {
                self.callPostApi(headers: headers, apiMethod: apiMethod, params: params) { (response) in
                    completionHandler(response)
                }
            } else {
                self.getSession() { (response) in
                    self.callPostApi(headers: headers, apiMethod: apiMethod, params: params) { (response) in
                        completionHandler(response)
                    }
                }
            }
        }
    }
    
    func requestWithMultipart(headers:HTTPHeaders, apiMethod:String, imageData: Data?, onCompletion: ((DataResponse<Any>) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let originalString = "\(kBaseUrl)\(apiMethod)"
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let serviceUrl = URL(string:urlString!) else { return }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                //                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: serviceUrl, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    onCompletion?(response)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
        
        
    func requestWithMultipartWithSession(headers:HTTPHeaders, apiMethod:String, imageData: Data?, onCompletion: ((DataResponse<Any>) -> Void)? = nil, onError: ((Error?) -> Void)? = nil) {
        
        checkSession { (isSession) in
            if isSession {
                self.requestWithMultipart(headers: headers, apiMethod: kFiles, imageData: imageData, onCompletion: { (response) in
                    onCompletion!(response)
                }) { (error) in
                    
                }
            } else {
                   self.getSession() { (response) in
                    self.requestWithMultipart(headers: headers, apiMethod: kFiles, imageData: imageData, onCompletion: { (response) in
                        onCompletion!(response)
                    }) { (error) in
                        
                    }
                }
            }
        }
    }
    
    //MARK: Google Directions API
    func callGetDirectionsApi(originPoint:String, destinationPoint:String, completionHandler: @escaping (_ response: DataResponse<Any>) -> Void)  {
        
        let originalString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originPoint)&destination=\(destinationPoint)&mode=driving&key=\(kGoogleApiKey)"
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let serviceUrl = URL(string:urlString!) else { return }
        Alamofire.request(serviceUrl, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            completionHandler(response)
        }
    }
}
