//
//  FeaturedTableViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 7/14/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

import UIKit

class FeaturedTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    var dataSource: IMOItemDataSource

    init(coder aDecoder: NSCoder!) {
        self.dataSource = ThemesTestDataSource()
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
        var cell = dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        super.prepareForSegue(segue, sender: sender)

        if let identifier = segue.identifier {
            if identifier == "item_detail_push" {
                if let indexPath = self.tableView.indexPathForCell(sender as? UITableViewCell) {
                    var item = self.dataSource.retrieveItemForIndexPath(indexPath)
                    (segue.destinationViewController as ItemDetailViewController).item = item
                }
            }
        }
    }
}
