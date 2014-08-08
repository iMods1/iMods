//
//  TweaksTestDataSource.swift
//  iMods
//
//  Created by Brendon Roberto on 8/7/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class TweaksTestDataSource: NSObject, UITableViewDataSource {
    var items: [IMOItem]

    init() {
        items = []

        let testDict1 = [
            "item_id": 1,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "brrl",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-barrel-icon.png",
            "pkg_dependencies": "",
            "display_name": "Barrel",
            "price": 0.99,
            "summary": "Awesome transitions for your springboard",
            "desc": "This is a description of a test tweak with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: 0.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        let testDict2 = [
            "item_id": 2,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "prwdgt",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-prowidgets-icon.png",
            "pkg_dependencies": "",
            "display_name": "Pro Widgets",
            "price": 0.99,
            "summary": "Your tasks, completely redesigned",
            "desc": "This is a description of a test tweak with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: -10.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        let testDict3 = [
            "item_id": 3,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "zppln",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-zeppelin-icon.png",
            "pkg_dependencies": "",
            "display_name": "Zeppelin",
            "price": 0.99,
            "summary": "Redesign your status bar Carrier logos",
            "desc": "This is a description of a test tweak with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
            "add_date": NSDate(timeIntervalSinceNow: -10.0),
            "last_update_date": NSDate(timeIntervalSinceNow: -1.0)] as NSDictionary

        let testDict4 = [
            "item_id": 4,
            "category_id": 1,
            "author_id": 1,
            "pkg_name": "cllbr",
            "pkg_version": "0.0.1",
            "pkg_assets_path": "imods-assets-callbar-icon.png",
            "pkg_dependencies": "",
            "display_name": "Callbar",
            "price": 0.99,
            "summary": "Answer your phone calls like never before",
            "desc": "This is a description of a test tweak with Lorem Ipsum text. Lorem ipsum dolor amet sit.",
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
}
