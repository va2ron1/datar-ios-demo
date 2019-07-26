//
//  SecondViewController.swift
//  datar
//
//  Created by va2ron1 on 7/25/19.
//  Copyright © 2019 va2ron1. All rights reserved.
//

import UIKit

struct SearchResponseData: Codable {
    let status: String
    let message: String?
    let data: [ResultData]
}

struct ResultData: Codable {
    let data: String
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var noContentLabel: UILabel!
    @IBOutlet var loading: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var items: [ResultData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the Search Controller
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Type to search"
        navigationItem.searchController = self.searchController
        definesPresentationContext = true
        self.searchController.searchBar.delegate = self
        (self.searchController.searchBar.value(forKey: "_searchField") as? UITextField)?.clearButtonMode = .whileEditing

        self.noContentLabel.center = self.view.center
        self.loading.center = self.view.center
        
        self.showNoContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.searchController.isActive {
            self.searchController.isActive = true
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.hideNoContent()
        return self.loading.isHidden
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.items.count == 0 {
            self.showNoContent()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // If there're text, then search
        if searchBar.text!.count > 0 {
            self.showLoading()
            self.searchData(text: searchBar.text!)
        }
    }
    
    func showNoContent() {
        self.loading.isHidden = true
        self.noContentLabel.isHidden = false
        self.tableView.separatorStyle = .none
    }
    
    func hideNoContent() {
        self.noContentLabel.isHidden = true
    }
    
    func showLoading() {
        self.hideNoContent()
        self.loading.isHidden = false
    }
    
    func hideLoading() {
        self.loading.isHidden = true
        if self.items.count > 0 {
            self.tableView.separatorStyle = .singleLine
        } else {
            self.showNoContent()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row].data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showData",
            let destination = segue.destination as? DataViewController,
            let dataIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.dataText = self.items[dataIndex].data
        }
    }
    
    func searchData(text: String) {
        var components = URLComponents(string: "https://api.datar.online/v1/data")!
        components.queryItems = [
            URLQueryItem(name: "auth_key", value: Bundle.main.object(forInfoDictionaryKey: "DATAR_API_KEY") as? String),
            URLQueryItem(name: "search", value: text)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Unknown Error
            } else {
                let decoder = JSONDecoder()
                let data = try! decoder.decode(SearchResponseData.self, from: data!)
                let response = response as? HTTPURLResponse
                if response?.statusCode == 400 {
                    self.items = []
                } else {
                    self.items = data.data
                }
                
            }
            DispatchQueue.main.async {
                self.hideLoading()
                self.tableView.reloadData()
            }
        }
        task.resume()
    }

}

