//
//  IMOItemTestDataSource.swift
//  iMods
//
//  Created by Brendon Roberto on 7/21/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class IMOItemTestDataSource: NSObject, UITableViewDataSource {
    var items: [IMOItem]
    
    init() {
        items = []
        let testDict1 = [
            "item_id": 1,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "tstpkg1",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "http://i.imgur.com/SrwZy.jpg",
            "pkg_dependencies": "",
            "display_name": "Test Package 1",
            "price": 0.99,
            "summary": "This is a test package.",
            "desc": "This is a description of a test package with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: 0.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary
        
        let testDict2 = [
            "item_id": 2,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "tstpkg2",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "http://i.imgur.com/SrwZy.jpg",
            "pkg_dependencies": "",
            "display_name": "Test Package 2",
            "price": 0.99,
            "summary": "This is another test package.",
            "desc": "This is a description of a test package with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: -10.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary
        
        var error: NSError?
        
        let item1 = IMOItem.modelWithDictionary(testDict1, error: &error) as IMOItem
        let item2 = IMOItem.modelWithDictionary(testDict2, error: &error) as IMOItem
        
        if let e = error {
            println("Something went wrong initializing models")
        } else {
            items.append(item1)
            items.append(item2)
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!)
        -> UITableViewCell! {
        
        if indexPath.row < items.count {
            let item = items[indexPath.row]
            var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            
            cell.detailTextLabel!.text = item.desc
            cell.textLabel!.text = item.display_name
            
            return cell
        } else {
            return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
    }
}
