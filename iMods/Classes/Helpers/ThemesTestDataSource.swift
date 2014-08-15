//
//  ThemesTestDataSource.swift
//  iMods
//
//  Created by Brendon Roberto on 8/7/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class ThemesTestDataSource: NSObject, IMOItemDataSource {
    var items: [IMOItem]

    override init() {
        items = []

        let testDict1 = [
            "item_id": 1,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "ultra",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-ultraflat-icon.png",
            "pkg_dependencies": "",
            "display_name": "UltraFlat",
            "price": 1.99,
            "summary": "Flatten your experience to the extreme",
            "desc": "This is a description of a test theme with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: 0.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        let testDict2 = [
            "item_id": 2,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "mojo",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-mojo-icon.png",
            "pkg_dependencies": "",
            "display_name": "Mojo",
            "price": 0.99,
            "summary": "Candies for your springboard. Yum",
            "desc": "This is a description of a test theme with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: -10.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        let testDict3 = [
            "item_id": 3,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "ayeris",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-ayeris-icon.png",
            "pkg_dependencies": "",
            "display_name": "Ayeris",
            "price": 0.99,
            "summary": "This is how iOS 7 should be",
            "desc": "This is a description of a test theme with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: -10.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        let testDict4 = [
            "item_id": 4,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "aura",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-aura-icon.png",
            "pkg_dependencies": "",
            "display_name": "Aura",
            "price": 1.99,
            "summary": "Take a different approach on style",
            "desc": "This is a description of a test theme with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: -10.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        var error: NSError?

        let item1 = IMOItem.modelWithDictionary(testDict1, error: &error) as IMOItem
        let item2 = IMOItem.modelWithDictionary(testDict2, error: &error) as IMOItem
        let item3 = IMOItem.modelWithDictionary(testDict3, error: &error) as IMOItem
        let item4 = IMOItem.modelWithDictionary(testDict4, error: &error) as IMOItem

        if let e = error {
            println("Something went wrong initializing models")
        } else {
            items.append(item1)
            items.append(item2)
            items.append(item3)
            items.append(item4)
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

            cell.imageView!.image = UIImage(named: item.pkg_assets_path)
            cell.detailTextLabel!.text = item.summary
            cell.textLabel!.text = item.display_name

            return cell
        } else {
            return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
    }

    func retrieveItemForIndexPath(path: NSIndexPath) -> IMOItem? {
        if path.row < countElements(items) {
            return items[path.row]
        } else {
            return nil
        }
    }
}
