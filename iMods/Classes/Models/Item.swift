//
//  IMOItemModel.swift
//  iMods
//
//  Created by Brendon Roberto on 7/14/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

import Foundation

class Item {
    var categoryId: Int
    var authorId: Int
    var packageName: String
    var displayName: String
    var packageVersion: String
    var packageSignature: PackageSignature?
    var packagePath: NSURL
    var packageAssetsPath: NSURL
    var packageDependencies: String[]?
    var price: Float
    var summary: String
    var description: String
    var addDate: NSDate
    var lastUpdateDate: NSDate

    init(categoryId: Int, authorId: Int, packageName: String, displayName: String,
        packageVersion: String, packageSignature: PackageSignature?,
        packagePath: NSURL, packageAssetsPath: NSURL,
        packageDependencies: String[]?, price: Float, summary: String,
        description: String, addDate: NSDate, lastUpdateDate: NSDate) {
            self.categoryId = categoryId
            self.authorId = authorId
            self.packageName = packageName
            self.displayName = displayName
            self.packageVersion = packageVersion
            self.packageSignature = packageSignature
            self.packagePath = packagePath
            self.packageAssetsPath = packageAssetsPath
            self.packageDependencies = packageDependencies
            self.price = price
            self.summary = summary
            self.description = description
            self.addDate = addDate
            self.lastUpdateDate = lastUpdateDate
    }
}