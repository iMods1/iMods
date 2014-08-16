//
//  Testing.swift
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import UIKit

struct SharedObjects {
    static private var _session = IMOSessionManager.sharedSessionManager(NSURL(string:"http://192.168.96.1:8000/api/"))
}

func sharedTestingSession() -> IMOSessionManager {
    return SharedObjects._session
}

func wait(interval:NSTimeInterval) {
    NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow:interval))
}