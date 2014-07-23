//
//  FeaturedTableViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 7/14/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

import UIKit

class FeaturedTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataSource: IMOItemTestDataSource

    init(coder aDecoder: NSCoder!) {
        self.dataSource = IMOItemTestDataSource()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var imageView = UIImageView(image: UIImage(named: "imods-assets-featured-tableview-background.png"))
        self.tableView.backgroundView = imageView
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int  {
        return self.dataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}
