//
//  SearchLocation.swift
//  ExploreMine
//
//  Created by Silstone on 30/01/20.
//  Copyright © 2019 Silstone Group. All rights reserved.
//

import UIKit
import MapKit

protocol Passdata {
  func passdata(str: String)
  func latitude(lats: Double)
  func longitude(long: Double)
}

@available(iOS 13.0, *)
class SearchLocation: UIViewController,UISearchBarDelegate {

    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var text:String = ""
    var mainViewController:SignUpViewController?
    let data = ""
    var commonFunctions = CommonFunctions()
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: Passdata!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self
        searchCompleter.delegate = self
        searchResultsTableView.isHidden = true
        searchBar.becomeFirstResponder()
    }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        searchResultsTableView.isHidden = false
        searchResultsTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = true
        searchResultsTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.reloadData()
    }
   
   
    @IBAction func backbtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

@available(iOS 13.0, *)
extension SearchLocation: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
}

@available(iOS 13.0, *)
extension SearchLocation: UITableViewDataSource,UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
     
        return cell
    }

   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let completion = searchResults[indexPath.row]

        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let latitude  = response?.mapItems[0].placemark.coordinate.latitude
            let longitude  = response?.mapItems[0].placemark.coordinate.longitude
          
            let placeName = response?.mapItems[0].placemark.name
            
            self.searchResultsTableView.isHidden = true
            
            self.delegate.passdata(str: "\(placeName!)")
            self.delegate.latitude(lats: latitude!)
            self.delegate.longitude(long: longitude!)
            self.navigationController?.popViewController(animated: true)
        }
    }
}



