//
//  ItemDetailViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    @IBOutlet var itemTitleLabel: UILabel!
    @IBOutlet var itemVersionLabel: UILabel!
    @IBOutlet var itemSummaryLabel: UILabel!
    @IBOutlet var itemPriceLabel: UILabel!
    @IBOutlet var itemDetailLabel: UILabel!
    @IBOutlet var itemIconImage: UIImageView!
    var item: IMOItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = self.item {
            itemTitleLabel.text = item.pkg_name
            itemVersionLabel.text = item.pkg_version
            itemSummaryLabel.text = item.summary
            itemPriceLabel.text = NSString(format: "$%.2f", item.price)
            itemDetailLabel.text = item.desc
            // TODO: Use actual pkg_assets_resolution
            itemIconImage.image = UIImage(named: item.pkg_assets_path)
        }
    }

    override func didReceiveMemoryWarning() {
        itemIconImage = nil
        super.didReceiveMemoryWarning()
    }
}
