//
//  iModsTests.swift
//  iModsTests
//
//  Created by Ryan Feng on 6/10/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import XCTest
import iMods

struct SharedObjects {
    static private var _session = IMOSessionManager.sharedSessionManager(NSURL(string:"http://192.168.119.1:8000/api/"))
}

func sharedTestingSession() -> IMOSessionManager {
    return SharedObjects._session
}

func wait(interval:NSTimeInterval) {
    NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow:interval))
}

class UserSessionTests: XCTestCase {
    
    var session = sharedTestingSession()
    var userManager = IMOUserManager()
    var infoDict:NSDictionary = NSDictionary()
    var build:NSString = NSString()
    var userEmail:NSString = NSString()
    var userFullName = ""
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        infoDict = NSBundle.mainBundle().infoDictionary
        build = infoDict[kCFBundleVersionKey] as NSString
        userEmail = NSString(format: "test%@@imods.com", build)
        userFullName = NSString(format: "testing%@", build)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUserLogin() {
        var login:PMKPromise = userManager.userLogin("test@test.com", password:"test")
        var resolved = false
        login.finally()({() in
            NSLog("Request finished")
            XCTAssert(self.userManager.userLoggedIn, "Login failed")
            let user:IMOUser? = self.userManager.userProfile
            XCTAssertNotNil(user, "Response is nil")
            XCTAssert(user?.fullname == "admin" , "User fullname doesn't match")
            resolved = true
        })
        wait(0.5)
        XCTAssert(resolved, "Request is not resolved")
    }
    
    func testUserRegister() {
        let user = userManager.userRegister(userEmail, password: "password", fullname: userFullName, age: 10, author_id: "imods.testing")
        var resolved = false
        user.finally()({() in
            let response:IMOUser? = self.userManager.userProfile
            XCTAssertNotNil(response, "Response is nil")
            XCTAssert(response?.fullname == self.userFullName, "User name doesn't match");
            resolved = true
        })
        wait(0.5)
        XCTAssert(resolved, "Request not resolved")
    }
    
    func testUserUpdate() {
        let newname = String(format:"testing_updated %@", build)
        let user = userManager.updateUserProfile(newname, age: 20)
        var resolved = false
        user.finally()({() in
            let response:IMOUser? = self.userManager.userProfile
            XCTAssertNotNil(response, "Response is nil")
            XCTAssert(response?.fullname == newname, "User name doesn't match")
            resolved = true
        })
        wait(0.5)
        XCTAssert(resolved, "Request not resolved")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class CategorySessionTests: XCTestCase {
    let session = sharedTestingSession()
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFeatured() {
    }
}