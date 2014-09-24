//
//  IMOFeaturedViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 7/14/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

import UIKit


class FeaturedViewController: UIViewController {

    @IBOutlet var themesButton: UIButton!
    @IBOutlet var tweaksButton: UIButton!
    var featuredTableViewController: FeaturedTableViewController?
    let tweaksDataSource = TweaksTestDataSource()
    let themesDataSource = ThemesTestDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        themesButton.selected = true
        tweaksButton.selected = false
    }

    @IBAction func themesButtonWasTouched(sender: UIButton) {
        sender.selected = true
        tweaksButton.selected = false

        featuredTableViewController!.dataSource = themesDataSource
        (featuredTableViewController!.view as UITableView).reloadData()
    }

    @IBAction func tweaksButtonWasTouched(sender: UIButton) {
        sender.selected = true
        themesButton.selected = false

        featuredTableViewController!.dataSource = tweaksDataSource
        (featuredTableViewController!.view as UITableView).reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        super.prepareForSegue(segue, sender: sender)
        if sender == nil {
            return
        }
        // Store the contained ViewController for later use
        let identifier = segue.identifier
        if identifier == "featured_tableview_embed" {
            self.featuredTableViewController = segue.destinationViewController as? FeaturedTableViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}