//
//  IMOSearchViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 7/14/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {

    let reuseIdentifier = "SearchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController!) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func searchDisplayControllerWillEndSearch(controller: UISearchDisplayController!) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        // TODO: Implement
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        // TODO: Implement
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
}
