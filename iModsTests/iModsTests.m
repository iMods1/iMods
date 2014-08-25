//
//  iModsTests_Objc.m
//  iMods
//
//  Created by Ryan Feng on 8/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "IMOUserManager.h"
#import "IMOCategory.h"
#import "IMOCategoryManager.h"
#import "IMOItem.h"
#import "IMOItemManager.h"
#import "IMOBillingInfoManager.h"
#import "IMOOrderManager.h"
#import "IMODeviceManager.h"
#import "IMOReviewManager.h"
#import "IMOWishListManager.h"

#pragma mark -
#pragma mark Base test case class

@interface iModsTestCase: XCTestCase

@property (readonly) IMOSessionManager* sessionManager;
@property (readonly) NSString* build;

@property (readonly) NSString* userFullName;
@property (readonly) NSString* userEmail;
@property (readonly) IMOUserManager* userManager;
@property (readonly) IMOCategoryManager* categoryManager;
@property (readonly) IMOItemManager* itemManager;
@property (readonly) IMOBillingInfoManager* billingManager;
@property (readonly) IMOOrderManager* orderManager;
@property (readonly) IMODeviceManager* deviceManager;
@property (readonly) IMOReviewManager* reviewManager;
@property (readonly) IMOWishListManager* wishlistManager;

@end

@implementation iModsTestCase

- (void)setUp{
    [super setUp];
    
    self->_build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*) kCFBundleVersionKey];
    self->_userFullName = [NSString stringWithFormat:@"test-%@@imods.com", self.build];
    self->_userEmail = [NSString stringWithFormat:@"testing-%@", self.build];
    
    if (!self.sessionManager) {
        self->_sessionManager = [IMOSessionManager sharedSessionManager:[NSURL URLWithString:@"http://192.168.119.1:8000/api/"]];
    }
    if (!self.userManager) {
        self->_userManager = [IMOUserManager sharedUserManager];
    }
    if (!self.itemManager) {
        self->_itemManager = [[IMOItemManager alloc] init];
    }
    if(!self.billingManager){
        self->_billingManager = [[IMOBillingInfoManager alloc] init];
    }
    if(!self.orderManager){
        self->_orderManager = [[IMOOrderManager alloc] init];
    }
    if(!self.deviceManager){
        self->_deviceManager = [[IMODeviceManager alloc] init];
    }
    if(!self.categoryManager){
        self->_categoryManager = [[IMOCategoryManager alloc] init];
    }
    if(!self.reviewManager) {
        self->_reviewManager = [[IMOReviewManager alloc] init];
    }
    if(!self.wishlistManager) {
        self->_wishlistManager = [[IMOWishListManager alloc] init];
    }
}

- (void)tearDown {
    [self logout];
    [super tearDown];
}

- (void) login:(NSString*)email password:(NSString*)password {
    [self.userManager userLogin:email password:password]
    .then(^(OVCResponse* response, NSError* error){
        if (error) {
            XCTFail(@"User login failed");
        }
    });
}

- (void) logout {
    [self.userManager userLogout];
}

- (void) waitFor:(double)interval {
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end

#pragma mark -
#pragma mark Category testing

@interface CategorySessionTest: iModsTestCase
@end

@implementation CategorySessionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFeatured{
    __block BOOL resolved = NO;
    PMKPromise* request = [self.categoryManager fetchFeatured];
    XCTAssertNotNil(request);
    request.then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error, @"Error occurred during request");
        IMOCategory* featured = response.result;
        XCTAssertNotNil(featured);
    })
    .finally(^(){
        resolved = YES;
    });
    [self waitFor: 0.2];
    XCTAssertTrue(resolved);
}

- (void)testFetchCategoryByName{
    __block BOOL resovled = NO;
    [self.categoryManager fetchCategoriesByName:@"featured"]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        NSArray* cat_list = response.result;
        XCTAssertNotNil(cat_list);
        IMOCategory* featured = [cat_list objectAtIndex:0];
        XCTAssert([featured.name isEqualToString:@"featured"]);
        resovled = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resovled);
}

- (void)testFetchCategoryByID{
    __block BOOL resolved = NO;
    [self.categoryManager fetchCategoriesByID:@1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        IMOCategory* featured = response.result;
        XCTAssertNotNil(featured);
        XCTAssert([featured.name isEqualToString:@"featured"]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

@end

#pragma mark -
#pragma mark Item testing

@interface ItemTest : iModsTestCase

@end

@implementation ItemTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testItemFetch {
    __block BOOL resolved = NO;
    [self.itemManager fetchItemByID:1].then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        IMOItem* item = response.result;
        XCTAssert([item isKindOfClass:[IMOItem class]]);
        XCTAssert(item.pkg_name);
        XCTAssert(item.item_id == 1);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

@end

#pragma mark -
#pragma mark User testing

@interface UserManagerTest: iModsTestCase

@end

@implementation UserManagerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_01_UserLogin {
    PMKPromise* request = [self.userManager userLogin:@"test@test.com" password:@"test"];
    __block BOOL resolved = NO;
    request.finally(^{
        XCTAssert(self.userManager.userLoggedIn);
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void)test_02_UserLogout {
    [self.userManager userLogout];
    XCTAssert(self.userManager.userLoggedIn == NO);
    [self login:@"test@test.com" password:@"test"];
}

- (void) test_03_UserRegister {
    PMKPromise* request = [self.userManager userRegister:self.userEmail password:@"password" fullname:self.userFullName age:@10 author_id:@"imods.testing"];
    __block BOOL resolved = NO;
    request.finally(^{
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        XCTAssert([user.fullname isEqualToString:self.userFullName]);
        XCTAssert([user.email isEqualToString:self.userEmail]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    [self logout];
    PMKPromise* login = [self.userManager userLogin:self.userEmail password:@"password"];
    login.finally(^{
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        resolved = YES;
    });
    [self waitFor:0.2];
    [self logout];
    XCTAssert(resolved);
}

- (void) test_04_UserUpdate {
    NSString* newname = [NSString stringWithFormat:@"testing_update %@", self.build];
    __block BOOL resolved = NO;
    PMKPromise* request = [self.userManager updateUserProfile:newname age:@(self.userManager.userProfile.age+1)];
    request.finally(^{
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        XCTAssert([user.fullname isEqualToString:newname]);
        resolved = YES;
    });
    [self waitFor:0.2];
    [self logout];
    XCTAssert(resolved);
}
@end

#pragma mark -
#pragma mark BillingInfo testing

@interface BillingInfoTest : iModsTestCase

@end

@implementation BillingInfoTest

- (void) setUp {
    [super setUp];
    [super login:@"test@test.com" password:@"test"];
    [self waitFor:0.2];
}

- (void) tearDown {
    [super tearDown];
}

- (void) test_05_BillingMethodAdd {
    NSDictionary* billing = @{
                              @"address": [NSString stringWithFormat:@"address-%@", self.build],
                              @"zipcode": @12345,
                              @"city": @"kent",
                              @"state": @"ohio",
                              @"country": @"USA",
                              @"type_": @"creditcard",
                              @"cc_name": @"Ryan Feng",
                              @"cc_no": @"1234567890",
                              @"cc_expr": @"09/17",
                              @"cc_cvv":@123
                            };
    NSError* error = nil;
    IMOBillingInfo* billingInfo = [MTLJSONAdapter modelOfClass:IMOBillingInfo.class fromJSONDictionary:billing error:&error];
    XCTAssertNil(error);
    
    __block BOOL resolved = NO;
    // Add first billing info
    [self.billingManager addNewBillingMethod:billingInfo]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOBillingInfo* billing = [self.billingManager.billingMethods lastObject];
        XCTAssertNotNil(billing);
        // Integrity check
        XCTAssert(billing.zipcode == 12345);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    // Add second billing info
    resolved = NO;
    [self.billingManager addNewBillingMethod:billingInfo]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOBillingInfo* billing = [self.billingManager.billingMethods lastObject];
        XCTAssertNotNil(billing);
        // Integrity check
        XCTAssert(billing.zipcode == 12345);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_06_BillingMethodUpdate {
    [self.billingManager refreshBillingMethods];
    [self waitFor:0.2];
    
    IMOBillingInfo* lastBilling = [self.billingManager.billingMethods lastObject];
    NSDictionary* newbilling = @{
                              @"bid": @(lastBilling.bid),
                              @"uid": @(lastBilling.uid),
                              @"address": [NSString stringWithFormat:@"newaddress-%@", self.build],
                              @"zipcode": @54321,
                              @"city": @"newkent",
                              @"state": @"newohio",
                              @"country": @"newUSA",
                              @"type_": @"paypal",
                              @"cc_name": @"New Ryan Feng",
                              @"cc_no": @"0987654321",
                              @"cc_cvv": @123,
                              @"cc_expr": @"01/23"
    };
    NSError* error = nil;
    IMOBillingInfo* newBillingInfo = [MTLJSONAdapter modelOfClass:IMOBillingInfo.class fromJSONDictionary:newbilling error:&error];
    XCTAssertNil(error);
    
    __block BOOL resolved = NO;
    [self.billingManager updateBillingMethod:newBillingInfo]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOBillingInfo* billing = [self.billingManager.billingMethods lastObject];
        XCTAssertNotNil(billing);
        // Integrity check
        XCTAssert(billing.zipcode == 54321);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_07_BillingMethodRemove {
    [self.billingManager refreshBillingMethods];
    [self waitFor:0.2];
    IMOBillingInfo* billing = [self.billingManager.billingMethods lastObject];
    NSUInteger billingCount = [self.billingManager.billingMethods count];
    XCTAssertNotNil(billing);
    XCTAssert(billingCount > 0);
    
    __block BOOL resolved = NO;
    [self.billingManager removeBillingMethod:billing]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssert(self.billingManager.billingMethods.count == billingCount - 1);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    [self.billingManager removeBillingMethodAtIndex:[self.billingManager.billingMethods count]-1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssert(self.billingManager.billingMethods.count == billingCount - 2);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}
@end

#pragma mark -
#pragma mark Order testing

@interface OrderTest : iModsTestCase

@end

@implementation OrderTest

IMOOrderManager* orderManager = nil;

- (void)setUp {
    [super setUp];
    [self login:@"test@test.com" password:@"test"];
    [self waitFor:0.2];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_01_PlaceNewOrder {
    // Fetch item and billing info
    __block IMOBillingInfo* billing = nil;
    [self.billingManager refreshBillingMethods]
    .then(^{
        billing = [self.billingManager.billingMethods lastObject];
    });
    [self waitFor:0.2];
    XCTAssertNotNil(billing);
    
    __block IMOItem* item = nil;
    __block BOOL resolved = NO;
    [self.itemManager fetchItemByID:1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        item = response.result;
        XCTAssertNotNil(item);
        resolved = YES;
    });
    [self waitFor:0.2];
    
    NSDictionary* jsonData = @{
                               @"billing_id": @(billing.bid),
                               @"item_id": @(item.item_id),
                               @"pkg_name": item.pkg_name,
                               @"total_price": @0.99,
                               @"total_charged": @1.99
                               };
    NSError * error = nil;
    // Create new order
    IMOOrder* order = [MTLJSONAdapter modelOfClass:IMOOrder.class fromJSONDictionary:jsonData error:&error];
    XCTAssertNil(error);
    order.item = item;
    order.billingInfo = billing;
    resolved = NO;
    // Send request
    [self.orderManager placeNewOrder:order]
    .then(^{
        IMOOrder* lastOrder = [self.orderManager.orders lastObject];
        XCTAssertNotNil(lastOrder);
        XCTAssert([lastOrder.item isEqual:item]);
        XCTAssert([lastOrder.billingInfo isEqual:billing]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_02_RefreshOrder {
    __block BOOL resolved = NO;
    [self.orderManager refreshOrders]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssertNotNil(self.orderManager.orders);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_03_CancelOrder {
    if(!self.orderManager.orders){
        [self test_02_RefreshOrder];
        [self waitFor:0.2];
    }
    __block BOOL resolved = NO;
    [self.orderManager cancelOrder:[self.orderManager.orders lastObject]]
    .finally(^{
        IMOOrder* lastOrder = [self.orderManager.orders lastObject];
        XCTAssert(lastOrder.status == OrderCancelled);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

@end

#pragma mark -
#pragma mark Device testing

@interface DeviceTest : iModsTestCase

@end

@implementation DeviceTest

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}

@end

#pragma mark -
#pragma ReviewTest

@interface ReviewTest : iModsTestCase

@end

#pragma mark -
#pragma mark Review testing

@implementation ReviewTest

- (void) setUp {
    [super setUp];
    [self login:@"test@test.com" password:@"test"];
    [self waitFor:0.2];
}

- (void) tearDown {
    [super tearDown];
}

- (void) test_01_AddReview {
    __block BOOL resolved = NO;
    __block IMOItem* item = nil;
    [self.itemManager fetchItemByID:1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        item = response.result;
        XCTAssertNotNil(item);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    NSDictionary* reviewJSON = @{
                                 @"iid": @(item.item_id),
                                 @"rating": @10,
                                 @"content": @"this is a review of an item",
                                 @"title": @"title!title here"
                                 };
    NSError* error = nil;
    IMOReview* review = [MTLJSONAdapter modelOfClass:IMOReview.class fromJSONDictionary:reviewJSON error:&error];
    XCTAssertNil(error);
    [self.reviewManager addReviewForItem:item review:review]
    .then(^{
        IMOReview* newReview = [item.reviews lastObject];
        XCTAssertNotNil(newReview);
        XCTAssert([[newReview valueForKey:@"title"] isEqualToString:[review valueForKey:@"title"]]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_02_RefreshReview {
    __block BOOL resolved = NO;
    __block IMOItem* item = nil;
    [self.itemManager fetchItemByID:1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        item = response.result;
        XCTAssertNotNil(item);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    NSDictionary* reviewJSON = @{
                                 @"iid": @(item.item_id),
                                 @"rating": @10,
                                 @"content": @"this is a review of an item",
                                 @"title": @"title!title here"
                                 };
    NSError* error = nil;
    IMOReview* review = [MTLJSONAdapter modelOfClass:IMOReview.class fromJSONDictionary:reviewJSON error:&error];
    XCTAssertNil(error);
    [self.reviewManager addReviewForItem:item review:review]
    .then(^{
        IMOReview* newReview = [item.reviews lastObject];
        XCTAssertNotNil(newReview);
        XCTAssert([[newReview valueForKey:@"title"] isEqualToString:[review valueForKey:@"title"]]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    [self.reviewManager getReviewsByItem:item]
    .then(^{
        XCTAssert([item.reviews count] > 0);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    [self.reviewManager getReviewsByUser:self.userManager.userProfile]
    .then(^(NSArray* reviews){
        XCTAssertNotNil(reviews);
        XCTAssert([reviews count] > 0);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_03_DeleteReview {
    __block BOOL resolved = NO;
    __block IMOReview* review = nil;
    __block NSUInteger reviewCount = 0;
    [self.reviewManager getReviewsByUser:self.userManager.userProfile]
    .then(^(NSArray* reviews){
        XCTAssert([reviews count] > 0);
        review = [reviews lastObject];
        reviewCount = [reviews count];
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    XCTAssertNotNil(review);

    resolved = NO;
    [self.reviewManager removeReview:review]
    .then(^{
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    [self.reviewManager getReviewsByUser:self.userManager.userProfile]
    .then(^(NSArray* reviews){
        NSUInteger rcount = [reviews count];
        XCTAssert((rcount == 0 && reviewCount == 0) || rcount == reviewCount - 1);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    XCTAssertNotNil(review);
}

@end

#pragma mark -
#pragma WishListTest

@interface WishListTest : iModsTestCase

@end

@implementation WishListTest

- (void)setUp {
    [super setUp];
    [self login:@"test@test.com" password:@"test"];
    [self waitFor:0.3];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testWishList{
    __block BOOL resolved = NO;
    __block IMOItem* item = nil;
    [self.itemManager fetchItemByID:1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        item = response.result;
        XCTAssertNotNil(item);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);

    // Add item
    resolved = NO;
    [self.wishlistManager addItemToWishList:item]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOItem* newitem = [self.userManager.userProfile.wishlist lastObject];
        XCTAssert([newitem isEqual:item]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    // Removew item
    resolved = NO;
    [self.wishlistManager removeItemFromWishListByItem:item]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssert(NSNotFound == [self.userManager.userProfile.wishlist indexOfObject:item]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    // Add item again
    resolved = NO;
    [self.wishlistManager addItemToWishList:item]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOItem* newitem = [self.userManager.userProfile.wishlist lastObject];
        XCTAssert([newitem isEqual:item]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    // Clear wishlist
    resolved = NO;
    [self.wishlistManager clearWishList]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssert([self.userManager.userProfile.wishlist count] == 0);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    // Check if wishlist is empty
    resolved = YES;
    [self.wishlistManager refreshWishList]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        NSArray* wishlist = self.userManager.userProfile.wishlist;
        XCTAssert(wishlist == nil || [wishlist count] == 0);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

@end