//
//  IMOItemDataSource.swift
//  iMods
//
//  Created by Brendon Roberto on 8/8/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

protocol IMOItemDataSource: UITableViewDataSource {
    func retrieveItemForIndexPath(NSIndexPath) -> IMOItem?
}