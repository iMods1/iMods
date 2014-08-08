//
//  iModsTests.swift
//  iModsTests
//
//  Created by Ryan Feng on 6/10/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

import XCTest
import iMods

class iModsTests: XCTestCase {
    
//#define wait(t) [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:t]]
    let session = IMOSessionManager.sharedSessionManager(NSURL(string:"http://192.168.96.1:8000/api/"))
    var infoDict:NSDictionary = NSDictionary()
    var build:NSString = ""
    var userEmail:NSString = ""
    var userFullName:NSString = ""
    
    func wait(interval:NSTimeInterval) {
        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow:interval))
    }
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
    
    func testExample() {
        // This is an example of a functional test case.
    }
    
    func testUserLogin() {
        var login:PMKPromise = session.userLogin("test@test.com", password:"test")
        var resolved = false
        login.finally()({() in
            NSLog("Request finished")
            XCTAssert(self.session.userLoggedIn, "Login failed")
            let user:IMOUser? = self.session.userProfile
            XCTAssertNotNil(user, "Response is nil")
            XCTAssert(user?.fullname == "admin" , "User fullname doesn't match")
            resolved = true
        })
        wait(0.5)
        XCTAssert(resolved, "Request is not resolved")
    }
    
    func testUserRegister() {
        let user = session.userRegister(userEmail, password: "password", fullname: userFullName, age: 10, author_id: "imods.testing")
        var resolved = false
        user.finally()({() in
            let response:IMOUser? = self.session.userProfile
            XCTAssertNotNil(response, "Response is nil")
            XCTAssert(response?.fullname.isEqual(self.userFullName), "User name doesn't match");
            resolved = true
        })
        wait(0.5)
        XCTAssert(resolved, "Request not resolved")
    }
    
    func testUserUpdate() {
        let newname = NSString(format:"testing_updated %@", build)
        let user = session.updateUserProfile(newname, age: 20)
        var resolved = false
        user.finally()({() in
            let response:IMOUser? = self.session.userProfile
            XCTAssertNotNil(response, "Response is nil")
            XCTAssert(response?.fullname.isEqual(newname), "User name doesn't match")
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
