//
//  iModsTests_Objc.m
//  iMods
//
//  Created by Ryan Feng on 8/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "IMOCategory.h"
#import "IMOCategoryManager.h"
#import "IMOItem.h"
#import "IMOItemManager.h"

@interface iModsTestCase: XCTestCase

@property IMOSessionManager* sessionManager;

@end

@implementation iModsTestCase

- (void)setUp {
    [super setUp];
    self.sessionManager = [IMOSessionManager sharedSessionManager:[NSURL URLWithString:@"http://192.168.119.1:8000/api/"]];
}

- (void)tearDown {
    [super tearDown];
}

- (void) waitFor:(double)interval {
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end

@interface CategorySessionTest: iModsTestCase
@end

@implementation CategorySessionTest

IMOCategoryManager* categoryManager = nil;

- (void)setUp {
    [super setUp];
    categoryManager = [[IMOCategoryManager alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFeatured{
    __block BOOL resolved = NO;
    PMKPromise* request = [categoryManager fetchFeatured];
    XCTAssertNotNil(request);
    request.then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error, @"Error occurred during request");
        IMOCategory* featured = response.result;
        XCTAssertNotNil(featured);
    })
    .finally(^(){
        resolved = YES;
    });
    [self waitFor: 0.1];
    XCTAssertTrue(resolved);
}

- (void)testFetchCategoryByName{
    __block BOOL resovled = NO;
    [categoryManager fetchCategoriesByName:@"featured"]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        NSArray* cat_list = response.result;
        XCTAssertNotNil(cat_list);
        IMOCategory* featured = [cat_list objectAtIndex:0];
        XCTAssert([featured.name isEqualToString:@"featured"]);
        resovled = YES;
    });
    [self waitFor:0.1];
    XCTAssert(resovled);
}

- (void)testFetchCategoryByID{
    __block BOOL resolved = NO;
    [categoryManager fetchCategoriesByID:@1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        IMOCategory* featured = response.result;
        XCTAssertNotNil(featured);
        XCTAssert([featured.name isEqualToString:@"featured"]);
        resolved = YES;
    });
    [self waitFor:0.1];
    XCTAssert(resolved);
}

@end

@interface ItemTest : iModsTestCase

@end

@implementation ItemTest

IMOItemManager* itemManager = nil;

- (void)setUp {
    [super setUp];
    itemManager = [[IMOItemManager alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testItemFetch {
    __block BOOL resolved = NO;
    [itemManager fetchItem:1].then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        IMOItem* item = response.result;
        XCTAssert([item isKindOfClass:[IMOItem class]]);
        XCTAssert(item.pkg_name);
        XCTAssert(item.item_id == 1);
        resolved = YES;
    });
    [self waitFor:0.1];
    XCTAssert(resolved);
}

@end
