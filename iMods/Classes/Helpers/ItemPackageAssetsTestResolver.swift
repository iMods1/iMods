//
//  ItemPackageAssetsTestResolver.swift
//  iMods
//
//  Created by Brendon Roberto on 8/16/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

class ItemPackageAssetsTestResolver: NSObject, ItemPackageAssetsResolver {
    var baseURL: NSURL;
    
    required init(URL url : NSURL) {
        baseURL = url
    }
    
    func bannerImage() -> UIImage {
        return UIImage(named: "banner-default")
    }
    
    func fullImage() -> UIImage {
        return UIImage(named: "full-default")
    }
    
    func screenshots() -> [UIImage] {
        return [UIImage(named: "screenshot-default")]
    }
    
    func thumbnailImage() -> UIImage {
        return UIImage(named: "thumbnail-default")
    }
}
