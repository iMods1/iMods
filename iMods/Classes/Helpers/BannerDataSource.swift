//
//  BannerDataSource.swift
//  iMods
//
//  Created by Brendon Roberto on 8/14/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import Foundation

protocol BannerDataSource {
    func dataForBanner(#tag: String) -> IMOItem
}
