//
//  ItemDetailViewController.swift
//  iMods
//
//  Created by Brendon Roberto on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemVersionLabel: UILabel!
    @IBOutlet weak var itemSummaryLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDetailLabel: UILabel!
    @IBOutlet weak var itemIconImage: UIImageView!
    @IBOutlet weak var buyButton: UIButton!

    var item: IMOItem?
    var managedObjectContext: NSManagedObjectContext?
    var managedItem: NSManagedObject?
    var entity: NSEntityDescription?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        self.entity = NSEntityDescription.entityForName("IMOInstalledItem", inManagedObjectContext: self.managedObjectContext!)
        
        if let item = self.item {
            itemTitleLabel.text = item.pkg_name
            itemVersionLabel.text = item.pkg_version
            itemSummaryLabel.text = item.summary
            itemPriceLabel.text = NSString(format: "$%.2f", item.price)
            itemDetailLabel.text = item.desc
            // TODO: Use actual pkg_assets_resolution
            itemIconImage.image = UIImage(named: item.pkg_assets_path)
            
            // Fetch installed package if it exists
            var request = NSFetchRequest()
            request.entity = entity
            request.predicate = NSPredicate(format: "id == %d", item.item_id)
            var error: NSError?
            
            var results = self.managedObjectContext?.executeFetchRequest(request, error: &error)
            
            if let r = results {
                if r.count > 0 {
                    self.managedItem = r[0] as? NSManagedObject
                    self.buyButton.enabled = false
                    self.buyButton.titleLabel.text = "Purchased"
                }
            }
        }
    }

    @IBAction func didTapBuyButton(sender: UIButton) {
        self.managedItem = NSManagedObject(entity: self.entity!, insertIntoManagedObjectContext: self.managedObjectContext!)
        self.managedItem!.setValue(self.item!.pkg_name, forKey: "name")
        self.managedItem!.setValue(self.item!.item_id, forKey: "id")
        self.managedItem!.setValue(self.item!.pkg_version, forKey: "version")
        var error: NSError?
        self.managedObjectContext!.save(&error)
        if let e = error {
            var alert = UIAlertController(title: "Application Error", message: "There was a problem with the application. Error: \(e.localizedDescription)", preferredStyle: .Alert)
            var action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.buyButton.enabled = false
            var alert = UIAlertController(title: "Purchased", message: "The package \(self.item!.pkg_name) was purchased!", preferredStyle: .Alert)
            var action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        itemIconImage = nil
        super.didReceiveMemoryWarning()
    }
}
