//
//  ChannelsViewController.swift
//  ExploreMine
//
//  Created by Silstone on 01/11/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //    @IBOutlet weak var channelCollectionView: UICollectionView!
    @IBOutlet weak var channelsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var netwoking = NetworkApi()
    var commonFunctions = CommonFunctions()
    let reuseIdentifier = "channelsCell"
    //   var dataArr = [NSDictionary]()
    var dataDict =  [NSDictionary]()
    var filteredDataDict =  [NSDictionary]()
    var rowsCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(false)
           // check the permission status
           getChannels(initCall: true)
    }
    
    func initUI() {
        searchBar.searchTextField.backgroundColor = CommonFunctions().hexStringToUIColor(hex: "#F0F0F0")
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.font = UIFont(name:"Avenir Book",size:16)
    }
    
    // MARK: - Api Calls
    func createChannel(channelName:String) {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        
        DispatchQueue.main.async {
            CommonFunctions.sharedInstance.start()
        }
        
        let header: HTTPHeaders = [
            "Content-Type" : "application/json",
            "developerid": "test",
            "location": "",
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String
        ]
        let parameters: [String: AnyObject] = [
            "ownerid": UserDefaults.standard.value(forKey: kUserId) as! String,
            "name": channelName,
            "class":"com.imersia.default",
            "radius":0,
            "hidden": false
            ] as [String : AnyObject]
        
        netwoking.callPostApiWithSession(headers: header, apiMethod: kChannels, params: parameters) { (response) in
            if response.result.value != nil {
                self.getChannels(initCall: false)
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            }
        }
    }
    
    func getChannels(initCall:Bool) {
        if initCall {
            ActivityLoader().showActivityIndicator(uiView: self.view)
        }
        let header: HTTPHeaders = [
            //   "userid": "044b4686-4e9b-11e9-aa9d-3fc5e851dce7",
            "userid": UserDefaults.standard.value(forKey: kUserId) as! String,
            "showhidden": "true",
            "location": "",
            "developerid": "test"
        ]
        netwoking.callGetApi(apiMethod: kChannels, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                
                self.dataDict.removeAll()
                self.filteredDataDict.removeAll()
                var dataArr =  [NSDictionary]()
                dataArr = response.result.value as! [NSDictionary]
                
                for item in dataArr {
                    
                    var arrItem = [String:AnyObject]()
                    let modifiedDate = item["modified"] as? String
                    let channelid = item["channelid"] as AnyObject
                    let imageurl = item["imageurl"] as AnyObject
                    let name = item["name"] as AnyObject
                    let ownerid = item["ownerid"] as AnyObject
                    let modified = item["modified"] as AnyObject
                    
                    let dateFormatter = ISO8601DateFormatter()
                    let date: NSDate? = dateFormatter.date(from: modifiedDate!) as NSDate?
                    let timeStamp = date!.timeIntervalSince1970 as AnyObject
                    arrItem.updateValue(timeStamp , forKey: "timeStamp")
                    
                    arrItem.updateValue(channelid, forKey: "channelid")
                    arrItem.updateValue(imageurl, forKey: "imageurl")
                    arrItem.updateValue(name, forKey: "name")
                    arrItem.updateValue(ownerid, forKey: "ownerid")
                    arrItem.updateValue(modified, forKey: "modified")
                    
                    self.dataDict.append(arrItem as NSDictionary)
                }
                
                self.dataDict.sort(by: { $0["timeStamp"] as! Double > $1["timeStamp"] as! Double})
                
                if self.dataDict.count > 0 {
                    self.filteredDataDict = self.dataDict
                    self.rowsCount = self.filteredDataDict.count + 1
                } else {
                    self.rowsCount = 1
                }
                 self.channelsTableView.reloadData()
                ActivityLoader().hideActivityIndicator(uiView: self.view)
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    
    func deleteChannels(channelId:String) {
        ActivityLoader().showActivityIndicator(uiView: self.view)
        let header: HTTPHeaders = [
            "channelid": channelId ,
            "sessionid": UserDefaults.standard.value(forKey: kSessionId) as! String,
            "location": "",
            "developerid": "test"
        ]
        netwoking.callDeleteApi(apiMethod: kChannels, parameters: "", headers: header) { (response) in
            if response.result.value != nil {
                self.getChannels(initCall: false)
            } else {
                ActivityLoader().hideActivityIndicator(uiView: self.view)
                self.commonFunctions.ShowAlert(title: kAppName, message: "Could't connect to server", in: self)
            }
        }
    }
    
    func dateConversion(objDate:NSDate) -> String {
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.dateFormat = "MMM"
        
        let dateFormatterYear = DateFormatter()
        dateFormatterYear.dateFormat = "yyyy"
        
        let strMonth = dateFormatterMonth.string(from: objDate as Date)
        let strYear = dateFormatterYear.string(from: objDate as Date)
        
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: objDate as Date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return strMonth + " " + day + " " + strYear
    }
    
    func addChannelClicked()  {
        
        let alertController = UIAlertController(title: "Channel name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter channel name"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            self.searchBar.text = ""
            if (textField.text!.count > 0) {
                self.createChannel(channelName: textField.text!)
            } else {
                self.commonFunctions.ShowAlert(title: kAppName, message: "Please enter channel name", in: self)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelsCell", for: indexPath) as! ChannelsCell
        
        if indexPath.row == 0 {
            cell.viewLineUp.isHidden = true
            cell.imgViewChannel.backgroundColor = CommonFunctions().hexStringToUIColor(hex: "#181D4A")
            cell.lblNoExpirence.isHidden = true
            cell.lblNameTopConstant.constant = 32
            cell.btnDelete.isHidden = true
            cell.lblName.text = "New Folder"
            cell.lblDate.text = dateConversion(objDate: Date() as NSDate)
        } else {
            cell.lblAdd.isHidden = true
            let dataDict = self.filteredDataDict[indexPath.row - 1]
            
            let dateFormatterGet = ISO8601DateFormatter()
            let modifiedDate = dataDict["modified"] as? String
            let date: NSDate? = dateFormatterGet.date(from: modifiedDate!) as NSDate?
            cell.lblDate.text = dateConversion(objDate: date!)
            
            let fileUrl = dataDict["imageurl"] as? String
            if (fileUrl != nil) {
                var imageUrl = "\(kServerUrl)\(fileUrl!)"
                imageUrl = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                cell.imgViewChannel.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "defaultChannel"))
            }
            
            cell.lblName.text = dataDict["name"] as? String
            
            cell.btnDelete.tag = indexPath.row - 1
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteSelected), for: .touchUpInside)
        }
        
        if indexPath.row == rowsCount - 1 {
            cell.viewLinedown.isHidden = true
        } else {
            cell.viewLinedown.isHidden = false
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if(indexPath.row==0) {
            addChannelClicked()
        } else {
            let dataDict = self.filteredDataDict[indexPath.row - 1]
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "geobotsVC") as? GeobotsViewController
            vc?.channelId = dataDict["channelid"] as? String ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    // MARK: - UISearchBar Delegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       //    shouldShowSearchResults = false
           searchBar.text = ""
           filteredDataDict = dataDict
           rowsCount = self.filteredDataDict.count + 1
           channelsTableView.reloadData()
       }
      
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if !shouldShowSearchResults {
//            shouldShowSearchResults = true
//            tableView.reloadData()
//        }
        searchBar.resignFirstResponder()
    }
    
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       //    shouldShowSearchResults = true
           
           if searchText == ""{
               filteredDataDict = dataDict
           }else{
               let searchPredicate = NSPredicate(format: "name CONTAINS[C] %@", searchText)
               filteredDataDict = (dataDict as NSArray).filtered(using: searchPredicate) as! [NSDictionary]
           }
           rowsCount = self.filteredDataDict.count + 1
           channelsTableView.reloadData()
       }
    
    // MARK: - IBActions
    
    @objc func btnDeleteSelected(sender: UIButton){
        commonFunctions.showAlertWithMutipleActions(message: "Are you sure to delete this channel ?", title: kAppName, controller: self, firstBtnTitle: "Yes", secondBtnTitle: "No") { (optionIndex) in
            if (optionIndex == 1) {
                let dataDict = self.dataDict[sender.tag]
                let selectedChannelId = dataDict["channelid"] as? String
                self.deleteChannels(channelId: selectedChannelId!)
            }
        }
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

