//
//  ItemPackageAssetsResolver.swift
//  iMods
//
//  Created by Brendon Roberto on 8/16/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

protocol ItemPackageAssetsResolver: NSObjectProtocol {
    init(URL: NSURL)
    /* Will return default assets if assets are not found on assets server */
    func thumbnailImage() -> UIImage
    func fullImage() -> UIImage
    func screenshots() -> [UIImage]
    func bannerImage() -> UIImage
}
