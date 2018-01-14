//
//  IMOItemDetailViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOItemDetailViewController.h"
#import "AppDelegate.h"
#import "IMOItem.h"
#import <CoreData/CoreData.h>
#import <Stripe/Stripe.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>
#import "IMOSessionManager.h"
#import "IMOOrderManager.h"
#import "IMOOrder.h"
#import "IMOCardViewController.h"
#import "IMOInstallationViewController.h"
#import "IMODownloadManager.h"
#import "IMOWishlistManager.h"
#import "IMOReviewManager.h"
#import "IMOPackageManager.h"
#import "IMOScreenShotViewController.h"
#import "IMOYouTubeVideoPreviewViewController.h"
#import "GRMustache.h"
#import "UIColor+HTMLColors.h"
#import "IMOMoreByDevViewController.h"
#import "GUAAlertView.h"
#import "NSString+MD5.h"
#import "IMOItemManager.h"

@interface IMOItemDetailViewController ()<UIAlertViewDelegate>
@property (assign, nonatomic) BOOL isPurchased;
@property (assign, nonatomic) BOOL isInstalled;
@property (assign, nonatomic) BOOL isFree;
@property (assign, nonatomic) BOOL done;
@property (strong, nonatomic) IMOOrderManager *orderManager;
@property (strong, nonatomic) IMOWishListManager *wishlistManager;
@property (strong, nonatomic) IMOBillingInfoManager *billingManager;
@property (strong, nonatomic) IMOPackageManager* packageManager;
@property (strong, nonatomic) IMOSessionManager* sessionManager;
@property (strong, nonatomic) NSDictionary* itemAssets;
@property NSString *uninstallInvoker;

- (void)setupInstallButton;
- (void)checkInstallStatus;
- (void)checkPurchaseStatus;
//- (void)createPurchaseFromCard:(PTKCard *)card;
- (PMKPromise *)createPurchaseFromBillingInfo:(IMOBillingInfo *)billingInfo;
- (PMKPromise *)createFreePurchase;
//- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withCard:(PTKCard *)card;
- (void)cardControllerDidCancel:(IMOCardViewController *)cardController;

//- (PMKPromise *)billingInfo:(NSDictionary *)dict withCard:(PTKCard *)card;
- (PMKPromise *)order:(NSDictionary *)dict withBillingInfo:(IMOBillingInfo *) billingInfo;
- (PMKPromise *)order:(NSDictionary *)dict withBillingInfo:(IMOBillingInfo *)billingInfo withToken:(STPToken *)token;

@end

@implementation IMOItemDetailViewController
@synthesize item = _item;
@synthesize isPurchased = _isPurchased;
@synthesize isInstalled = _isInstalled;
@synthesize isFree = _isFree;

UIAlertView *av;

- (void) populateIMOItemWithId:(NSString *)pkg_name {
    IMOItemManager *itemManager = [[IMOItemManager alloc] init];
    [itemManager fetchItemByName:pkg_name].then(^(IMOItem *item) {
        self.item = item;
        if (self.done == YES) {
            [self viewDidLoad];
        }
    });
}

- (IBAction)addToWishlist:(id)sender {
    //self.navigationItem.rightBarButtonItem change to remove icon
    [self.wishlistManager addItemToWishList:self.item].then(^{
        NSString *msg = NSLocalizedStringFromTableInBundle(@"Added to wishlist!", nil, [self translationsBundle], nil);
        NSString *proceed = NSLocalizedStringFromTableInBundle(@"Proceed", nil, [self translationsBundle], nil);
        GUAAlertView *v = [GUAAlertView alertViewWithTitle:NSLocalizedStringFromTableInBundle(@"Success", nil, [self translationsBundle], nil)
            message:msg
            buttonTitle:proceed
           buttonTouchedAction:^{
               NSLog(@"button touched");
           } dismissAction:^{
               NSLog(@"dismiss");
           }
           buttons: NO];
    
        [v show];
    }).catch(^{
        NSString *title = NSLocalizedStringFromTableInBundle(@"Failure", nil, [self translationsBundle], nil);
        NSString *msg = NSLocalizedStringFromTableInBundle(@"Failed to add to wishlist!", nil, [self translationsBundle], nil);
        NSString *proceed = NSLocalizedStringFromTableInBundle(@"Proceed", nil, [self translationsBundle], nil);
        GUAAlertView *v = [GUAAlertView alertViewWithTitle:title
            message:msg
            buttonTitle:proceed
           buttonTouchedAction:^{
               NSLog(@"button touched");
           } dismissAction:^{
               NSLog(@"dismiss");
           }
           buttons: NO];
    
        [v show];
    });
}

- (void)errorAlert:(NSString*)title message:(NSString*)message {
    NSString *okBtn = NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle: okBtn

                                           otherButtonTitles:nil];
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated {
    self.webView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    UIView *viewToRemove = [self.navigationController.navigationBar viewWithTag:4];
    [viewToRemove removeFromSuperview];
}

- (void)viewDidLoad {
    self.done = YES;
    [super viewDidLoad];

    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"BEBEBE"];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"C3C6CB"]}];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"616E7B"];
    
    CGRect bounds = self.navigationController.navigationBar.bounds;
    bounds.size.height = bounds.size.height + 20;
    bounds.origin.y = -20;

    UIView* view1 = [[UIView alloc] initWithFrame:bounds];    
    view1.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    view1.userInteractionEnabled = false;

    view1.tag = 4;
    [self.navigationController.navigationBar insertSubview:view1 atIndex:0];


    //self.navigationItem.backBarButtonItem
    //[self.navigationController.navigationBar bringSubviewToFront:self.navigationItem.view];

    /*[self.view insertSubview:view1 belowSubview:self.navigationBar]*/

    self.automaticallyAdjustsScrollViewInsets = NO;
    IMOSessionManager *manager = [IMOSessionManager sharedSessionManager];
    self.sessionManager = manager;
    self.orderManager = [[IMOOrderManager alloc] init];
    self.billingManager = manager.billingManager;
    
    IMOPackageManager *packageManager = [IMOPackageManager sharedPackageManager];
    self.packageManager = packageManager;
    [[self findHairlineImageViewUnder:self.navigationController.navigationBar] setHidden:YES];
    
    self.wishlistManager = [[IMOWishListManager alloc] init];
    
    // Set up Core Data objects
    
    self.isFree = (self.item.price <= 0);
    
    [self setupItem:self.item];
}

- (void)setupItem:(IMOItem*)item {
    if (!item) {
        return;
    }
    self.item = item;
    
    [self setupInstallButton];
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"package" ofType:@"template"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *renderedTemplate = [GRMustacheTemplate renderObject:@{
         @"author_id": self.item.author_id ? self.item.author_id : @"",
         @"pkg_name": self.item.pkg_name ? self.item.pkg_name : @"",
         @"pkg_version": self.item.pkg_version ? self.item.pkg_version : @"",
         @"display_name": self.item.display_name ? self.item.display_name : @"",
         @"price": self.item.price ? [[NSNumber numberWithFloat:self.item.price] stringValue] : @"",
         @"desc": self.item.desc ? self.item.desc : @"",
         @"icon": @"",
         @"type": self.item.type
    } fromString:content error:NULL];
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.webView loadHTMLString:renderedTemplate baseURL:baseURL];
    // TODO: add promise, .catch, load default icon
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //navigationType == UIWebViewNavigationTypeLinkClicked &&
    if ([[request.URL absoluteString] hasPrefix:@"imods://"]){
        NSURL *url = [NSURL URLWithString:[request.URL absoluteString]];
        
        if ([[url host] isEqualToString:@"install"]) {
            [self didTapInstallButton];
        } else if ([[url host] isEqualToString:@"remove"]) {
            self.uninstallInvoker = [url pathComponents][1];
            [self performSegueWithIdentifier:@"uninstall_segue" sender:self];
        } else if ([[url host] isEqualToString:@"screenshots"]) {
            [self performSegueWithIdentifier:@"screenshot_page_view_controller_modal" sender:self];
        } else if ([[url host] isEqualToString:@"video"]) {
            [self performSegueWithIdentifier:@"youtube_video_player_view_controller_modal" sender:self];
        } else if ([[url host] isEqualToString:@"dev"]) {
            [self performSegueWithIdentifier:@"more_by_dev_modal" sender:self];
        } else if ([[url host] isEqualToString:@"ratingChange"]) {
            [self ratingChanged:[[url pathComponents][1] intValue]];
        }
        
        NSLog(@"query: %@", [url query]);
        return NO;
    }
    
    return YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //self.isInstalled = YES;//remove
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"installed(%s, %s)", self.isInstalled ? "true" : "false", self.isFree || self.isPurchased ? "false" : "true"]];
    IMODownloadManager *manager = [IMODownloadManager sharedDownloadManager];
    [manager download:Assets item:self.item].then(^(NSDictionary *results) {
        self.itemAssets = results;
        UIImage *icon = [results valueForKey:@"icon"];
        NSString *iconS = [NSString stringWithFormat:@"data:image/png;base64,%@", [UIImagePNGRepresentation(icon) base64EncodedStringWithOptions:0]];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"icon('%@')", iconS]];
    });
    [self setupRating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"item_detail_installation_modal"]) {
        ((IMOInstallationViewController *)segue.destinationViewController).delegate = self;
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
            ((IMOInstallationViewController *)segue.destinationViewController).modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            ((IMOInstallationViewController *)segue.destinationViewController).modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        //((IMOInstallationViewController *)segue.destinationViewController).modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    if ([segue.identifier isEqualToString:@"screenshot_page_view_controller_modal"]) {
        ((IMOScreenShotViewController*) segue.destinationViewController).item = self.item;
        ((IMOScreenShotViewController*) segue.destinationViewController).assets = self.itemAssets;
    }
    if ([segue.identifier isEqualToString:@"more_by_dev_modal"]) {
        ((IMOMoreByDevViewController*) segue.destinationViewController).item = self.item;
    }
    if ([segue.identifier isEqualToString:@"youtube_video_player_view_controller_modal"]) {
        NSArray* videos = [self.itemAssets valueForKey:@"videos"];
        NSString* youtube_video_id = [[videos firstObject] valueForKey:@"youtube_id"];
        ((IMOYouTubeVideoPreviewViewController*) segue.destinationViewController).youtubeVideoID = youtube_video_id;
    }
    if ([segue.identifier isEqualToString:@"uninstall_segue"]) {
        IMOUninstallationViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.pkg_name = self.uninstallInvoker;
    }
}

#pragma mark - Misc

- (void)didTapInstallButton {
    if (self.isPurchased) {
        if (self.isInstalled) {
            // Bail - this case should never be reached
            return;
        } else {
            // Handle tap on Install button.
            [self performSegueWithIdentifier:@"item_detail_installation_modal" sender:self];
        }
    } else {
        // Handle tap on "Buy/Free" button
        if (self.isFree) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDate *last = [defaults objectForKey:@"lastProperLogin"];
            NSTimeInterval secs = [last timeIntervalSinceDate:[NSDate date]];
            if (secs <= 900) {
                [self createFreePurchase];
            }
            else {
                BOOL hasTouchID = NO;
                // if the LAContext class is available
                if ([LAContext class]) {
                    LAContext *context = [LAContext new];
                    NSError *error = nil;
                    hasTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
                }
                if (hasTouchID) {
                    LAContext *myContext = [[LAContext alloc] init];
                    NSError *authError = nil;
                    NSString *myLocalizedReasonString = NSLocalizedStringFromTableInBundle(@"Please login to purchase", nil, [self translationsBundle], nil);
                    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
                        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                  localizedReason:myLocalizedReasonString
                                            reply:^(BOOL success, NSError *error) {
                                                if (success) {
                                                    [self createFreePurchase];
                                                } else {
                                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                    NSString *email = [defaults stringForKey:@"email"];
                                                    
                                                    NSString *message = [[[NSLocalizedStringFromTableInBundle(@"Enter the password for", nil, [self translationsBundle], nil) stringByAppendingString:@"\""] stringByAppendingString:email] stringByAppendingString:@"\""];
                                                    av = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTableInBundle(@"Sign in to iMods", nil, [self translationsBundle], nil) message:message delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil), nil];
                                                    av.alertViewStyle = UIAlertViewStyleSecureTextInput;
                                                    [av textFieldAtIndex:0].delegate = self;
                                                    
                                                    [av show];
                                                }
                                            }];
                    } else {
                        // Could not evaluate policy; look at authError and present an appropriate message to user
                    }
                    
                }
                else {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString *email = [defaults stringForKey:@"email"];
                    
                    NSString *message = [[[NSLocalizedStringFromTableInBundle(@"Enter the password for", nil, [self translationsBundle], nil) stringByAppendingString:@"\""] stringByAppendingString:email] stringByAppendingString:@"\""];
                    av = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTableInBundle(@"Sign in to iMods", nil, [self translationsBundle], nil) message:message delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil), nil];
                    av.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    [av textFieldAtIndex:0].delegate = self;
                    
                    [av show];
                }
            }
        } else {
            GUAAlertView *v = [GUAAlertView alertViewWithTitle:@"Attention"
                message:@"Purchases are not available in the beta."
                buttonTitle:@"Ok"
               buttonTouchedAction:^{
                   NSLog(@"button touched");
               } dismissAction:^{
                   NSLog(@"dismiss");
               }
               buttons: NO];
        
            [v show];
            /*BOOL hasTouchID = NO;
            // if the LAContext class is available
            if ([LAContext class]) {
                LAContext *context = [LAContext new];
                NSError *error = nil;
                hasTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            }
            if (hasTouchID) {
                LAContext *myContext = [[LAContext alloc] init];
                NSError *authError = nil;
                NSString *myLocalizedReasonString = NSLocalizedStringFromTableInBundle(@"Please login to purchase", nil, [self translationsBundle], nil);
                if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
                    [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                              localizedReason:myLocalizedReasonString
                                        reply:^(BOOL success, NSError *error) {
                                            if (success) {
                                                [self.billingManager refreshBillingMethods].then(^{
                                                    BOOL shouldSegueToWallet = (self.billingManager.billingMethods.count <= 0) || !self.billingManager.isBillingMethodSelected;
                                                    
                                                    if (shouldSegueToWallet) {
                                                        [self performSegueWithIdentifier:@"item_detail_wallet_push" sender:self];
                                                    } else {
                                                        IMOBillingInfo *billingInfo = [[self.billingManager.billingMethods objectAtIndex:self.billingManager.selectedBillingMethod] copy];
                                                        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                                        activityIndicator.center = self.view.center;
                                                        [self.view addSubview:activityIndicator];
                                                        [activityIndicator startAnimating];
                                                        
                                                        [self createPurchaseFromBillingInfo: billingInfo].finally(^{
                                                            [activityIndicator stopAnimating];
                                                            [activityIndicator removeFromSuperview];
                                                        });
                                                    }
                                                });
                                            } else {
                                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                NSString *email = [defaults stringForKey:@"email"];
                                                NSString *message = [[[NSLocalizedStringFromTableInBundle(@"Enter the password for", nil, [self translationsBundle], nil) stringByAppendingString:@"\""] stringByAppendingString:email] stringByAppendingString:@"\""];
                                                av = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTableInBundle(@"Sign in to iMods", nil, [self translationsBundle], nil) message:message delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil), nil];
                                                av.alertViewStyle = UIAlertViewStyleSecureTextInput;
                                                [av textFieldAtIndex:0].delegate = self;
                                                
                                                [av show];
                                            }
                                        }];
                } else {
                    // Could not evaluate policy; look at authError and present an appropriate message to user
                }
                
            }
            else {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *email = [defaults stringForKey:@"email"];
                NSString *message = [[[NSLocalizedStringFromTableInBundle(@"Enter the password for", nil, [self translationsBundle], nil) stringByAppendingString:@"\""] stringByAppendingString:email] stringByAppendingString:@"\""];
                av = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTableInBundle(@"Sign in to iMods", nil, [self translationsBundle], nil) message:message delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil), nil];
                av.alertViewStyle = UIAlertViewStyleSecureTextInput;
                [av textFieldAtIndex:0].delegate = self;
                
                [av show];
            }*/

        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [av dismissWithClickedButtonIndex:-1 animated:YES];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults stringForKey:@"email"];
    NSString *password = textField.text;
    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/AccountsDaemon.framework/"];
    BOOL successful = [bundle load];
    if (successful) {
        self.pass = [IMOKeychainManager passwordForUser:email];
    }
    if ([password isEqualToString:self.pass]) {
        if (self.isFree) {
            [self createFreePurchase];
        }
        else {
            [self.billingManager refreshBillingMethods].then(^{
                BOOL shouldSegueToWallet = (self.billingManager.billingMethods.count <= 0) || !self.billingManager.isBillingMethodSelected;
                
                if (shouldSegueToWallet) {
                    [self performSegueWithIdentifier:@"item_detail_wallet_push" sender:self];
                } else {
                    IMOBillingInfo *billingInfo = [[self.billingManager.billingMethods objectAtIndex:self.billingManager.selectedBillingMethod] copy];
                    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.center = self.view.center;
                    [self.view addSubview:activityIndicator];
                    [activityIndicator startAnimating];
                    
                    [self createPurchaseFromBillingInfo: billingInfo].finally(^{
                        [activityIndicator stopAnimating];
                        [activityIndicator removeFromSuperview];
                    });
                }
            });
        }
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *email = [defaults stringForKey:@"email"];
        NSString *message = [[[NSLocalizedStringFromTableInBundle(@"Enter the password for", nil, [self translationsBundle], nil) stringByAppendingString:@"\""] stringByAppendingString:email] stringByAppendingString:@"\""];
        av = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTableInBundle(@"Sign in to iMods", nil, [self translationsBundle], nil) message:message delegate:self cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil) otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil), nil];
        av.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [av textFieldAtIndex:0].delegate = self;
        [av show];
    }
}

- (void)setupInstallButton {
    [self checkPurchaseStatus];
    [self checkInstallStatus];
}

- (void)checkInstallStatus {
    self.isInstalled = NO;
    NSMutableArray *installedItems = self.sessionManager.userManager.installedItems;
    for (NSMutableDictionary *package in installedItems) {
        if ([[package objectForKey:@"pkg_name"] isEqualToString:self.item.pkg_name]) {
            self.isInstalled = YES;
            break;
        }
    }
}

- (void) setupRating {
    IMOUserManager* userManager = [IMOSessionManager sharedSessionManager].userManager;
    
    __block BOOL alreadyRatedByCurrentUser = NO;
    void (^updateRating)(NSArray* reviews) = ^(NSArray* reviews) {
        NSUInteger totalRating = 0;
        for(IMOReview* rev in reviews) {
            totalRating += rev.rating;
            if (rev.uid == userManager.userProfile.uid) {
                alreadyRatedByCurrentUser = YES;
            }
        }
        NSUInteger count = reviews.count;
        if (count == 0) {
            count = 1;
        }
        float finalRating = (float)totalRating/count;
        if (alreadyRatedByCurrentUser) {
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"rating(%0.1f, false, false, true)", finalRating]];
        } else {
            [self.webView stringByEvaluatingJavaScriptFromString:@"rating(undefined, true, true, false)"];
        }
    };
    
    IMOReviewManager* reviewManager = [[IMOReviewManager alloc] init];
    [reviewManager getReviewsByItem:self.item].then(updateRating);
}

- (void) ratingChanged:(int)ratingval {
    IMOUserManager* userManager = [IMOSessionManager sharedSessionManager].userManager;
    
    if(!userManager.userLoggedIn) {
        GUAAlertView *errorAlert = [GUAAlertView alertViewWithTitle:NSLocalizedStringFromTableInBundle(@"Login", nil, [self translationsBundle], nil)
            message:NSLocalizedStringFromTableInBundle(@"Please login to rate this item.", nil, [self translationsBundle], nil)
            buttonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil)
           buttonTouchedAction:^{
               NSLog(@"button touched");
           } dismissAction:^{
               NSLog(@"dismiss");
           }
           buttons: NO];
            [errorAlert show];
        return;
    }
    
    IMOReviewManager* reviewManager = [[IMOReviewManager alloc] init];
    NSError* error = nil;
    float rating = (float) ratingval;
    NSDictionary* reviewDict = @{
                                 @"uid":@(userManager.userProfile.uid),
                                 @"iid":@(self.item.item_id),
                                 @"rating":@(rating),
                                 @"content":@"Review for item.",
                                 @"title":@"Review for item."
                                 };
    IMOReview* review = [MTLJSONAdapter modelOfClass:IMOReview.class
                                  fromJSONDictionary:reviewDict
                                               error:&error];
    [reviewManager addReviewForItem:self.item review:review]
    .then(^(NSArray* reviews) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"rating(%0.1f, false, false, true)", rating]];
    });
}

- (void)checkPurchaseStatus {

    NSUInteger itemId = self.item.item_id;

    [self.orderManager fetchOrderByUserItem: itemId].then(^(OVCResponse *response, NSError *error) {
        self.isPurchased = ([response.result count] > 0);
    }).catch(^(NSError *error) {
        NSLog(@"No order found for current user for item: %@", self.item);
        self.isPurchased = NO;
    });
}

/*- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withCard:(PTKCard *)card {
    [self dismissViewControllerAnimated: YES completion: ^{
        [self createPurchaseFromCard: card];
    }];
}*/

- (void)cardControllerDidCancel:(IMOCardViewController *)cardController {
    [self dismissViewControllerAnimated: YES completion: nil];
}

/*- (void)createPurchaseFromCard:(PTKCard *) card {
    if ([IMOUserManager sharedUserManager].userLoggedIn) {
        // Build order dictionary from user data
        
        IMOUser *user = [IMOUserManager sharedUserManager].userProfile;
        
        // TODO: Collect user address information somewhere
        
        NSDictionary *billingInfoDict = @{
                                          @"uid": @(user.uid),
                                          @"address": @"Placeholder Value",
                                          @"zipcode": @"Placeholder Value",
                                          @"city": @"Placeholder Value",
                                          @"state": @"Placeholder Value",
                                          @"country": @"Placeholder Value",
                                          @"paymentType": @(0)
                                          };
        
        [self billingInfo:billingInfoDict withCard:card].then(^(IMOBillingInfo *response) {
//            NSLog(@"Result from billingInfo:withCard: %@", response);
            [self createPurchaseFromBillingInfo: response];
        }).catch(^(NSError *error) {
            NSLog(@"Error creating billing info.");
            // TODO: Gracefully handle error
        });
    }
}*/

- (PMKPromise *)createPurchaseFromBillingInfo:(IMOBillingInfo *)billingInfo {
    NSDictionary *orderDict = @{
                                @"item_id": @(self.item.item_id),
                                @"pkg_name": self.item.pkg_name,
                                @"totalPrice": @(self.item.price),
                                @"totalCharged": @(self.item.price),
                                @"quantity": @(1),
                                @"orderDate": [NSDate date]
                                };
    
    return [self order:orderDict withBillingInfo:billingInfo].then(^{
        self.isPurchased = YES;
    }).catch(^(NSError *error) {
        NSString* errMsg = [NSString stringWithFormat:@"An error occurred on the server: %@", error.localizedDescription];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errMsg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"Error with backend %@", error.localizedDescription);
    });
}

- (PMKPromise *)createFreePurchase {
    NSDictionary *orderDict = @{
                                @"item_id": @(self.item.item_id),
                                @"pkg_name": self.item.pkg_name,
                                @"totalPrice": @(0),
                                @"totalCharged": @(0),
                                @"quantity": @(1),
                                @"orderDate": [NSDate date]
                                };
    
    NSError *error = nil;
    
    IMOOrder *order = [[IMOOrder alloc] initWithDictionary:orderDict error:&error];
    
    if (error) {
        NSLog(@"Error creating free order: %@", error.localizedDescription);
        [self errorAlert:NSLocalizedStringFromTableInBundle(@"Error", nil, [self translationsBundle], nil) message:NSLocalizedStringFromTableInBundle(@"Error creating order", nil, [self translationsBundle], nil)];
        return nil;
    } else {
        return [self.orderManager placeNewOrder:order].then(^{
            self.isPurchased = YES;
        }).catch(^{
            NSLog(@"Error with backend %@", error.localizedDescription);
        });
    }
}


/*- (PMKPromise *)billingInfo:(NSDictionary *)dict withCard:(PTKCard *)card {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"];
    dateFormatter.dateFormat = @"MM/yy";
    
    NSDictionary *cardDict = @{
                               @"creditcardNumber": card.number,
                               @"creditcardCVV": card.cvc,
                               @"creditcardName": [IMOUserManager sharedUserManager].userProfile.fullname,
                               @"creditcardExpiration": [dateFormatter dateFromString: [NSString stringWithFormat: @"%02lu/%02lu", (unsigned long)card.expMonth, (unsigned long)card.expYear]]
                               };
    
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    
    [mutableDict addEntriesFromDictionary: cardDict];
    
//    NSLog(@"Billing Info Dictionary: %@", mutableDict);
    
    NSError *error = nil;
    IMOBillingInfo *billingInfo = [[IMOBillingInfo alloc] initWithDictionary: mutableDict error: &error];
    
    if (error) {
        NSLog(@"Error creating billing info: %@", error.localizedDescription);
        return nil;
    } else {
        return [self.billingManager addNewBillingMethod: billingInfo];
    }
}*/

- (PMKPromise *)order:(NSDictionary *)dict withBillingInfo:(IMOBillingInfo *)billingInfo {
    NSDictionary *billingInfoDict = @{
                                      @"billing_id": @(billingInfo.bid),
                                      @"billingInfo": billingInfo
                                      };
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    
    if (billingInfo.paymentType == Paypal) {
        [mutableDict setValue:[PayPalMobile clientMetadataID] forKey:@"client_metadata_id"];
    }
    
    [mutableDict addEntriesFromDictionary:billingInfoDict];
    
    NSError *error = nil;
    IMOOrder *order = [[IMOOrder alloc] initWithDictionary:mutableDict error:&error];
    
    if (error) {
        NSLog(@"Error creating order: %@", error.localizedDescription);
        return nil;
    } else {
        return [self.orderManager placeNewOrder:order];
    }
}

- (PMKPromise *)order:(NSDictionary *)dict withBillingInfo:(IMOBillingInfo *)billingInfo withToken:(STPToken *)token {
    
    NSDictionary *billingInfoDict = @{
                                      @"billing_id": @(billingInfo.bid),
                                      @"billingInfo": billingInfo
                                      };
    
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    
    [mutableDict addEntriesFromDictionary:billingInfoDict];
    
    NSError *error = nil;
    IMOOrder *order = [[IMOOrder alloc] initWithDictionary:mutableDict error:&error];
    
    if (error) {
        NSLog(@"Error creating order: %@", error.localizedDescription);
        return nil;
    } else {
        return [self.orderManager placeNewOrder: order withToken: token.tokenId];
    }
}

#pragma mark - IMOInstallationDelegate

- (void)installationDidFinish:(IMOInstallationViewController *)installationViewController {
    [self checkInstallStatus];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"installed(%s, %s)", self.isInstalled ? "true" : "false", self.isFree || self.isPurchased ? "false" : "true"]];
    if (self.packageManager.lastInstallNeedsRespring) {
        UIAlertView* respringAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Respring needed", nil, [self translationsBundle], nil)
                                                                message:NSLocalizedStringFromTableInBundle(@"You installed new tweaks, do you want to respring now?", nil, [self translationsBundle], nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil)
                                                      otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil), nil];
        [respringAlert show];
    }
    else {
        [self.packageManager respring]; //This doesn't actually respring, it kills the target bundle
    }
}

- (void)removalDidFinish:(IMOUninstallationViewController *)uninstallationViewController {
    [self setupItem:self.item];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:NSLocalizedStringFromTableInBundle(@"Sign in to iMods", nil, [self translationsBundle], nil)]) {
    }
    else {
        // Handle respring
        if (buttonIndex == [alertView firstOtherButtonIndex]) {
            [self.packageManager respring]; //Here it does respring though
        }
        else if (buttonIndex == [alertView cancelButtonIndex]) {
            UIAlertView* respringAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Respring needed", nil, [self translationsBundle], nil) message:NSLocalizedStringFromTableInBundle(@"The respring will be performed automatically when you close the app.", nil, [self translationsBundle], nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil) otherButtonTitles:nil];
            [respringAlert show];
        }
    }
}

- (IBAction)unwindToItemDetailViewController:(UIStoryboardSegue *)sender {
    // stub
}

- (void)didTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)setUpNavigationBarItemsForCategory:(NSString*)categoryName icon:(UIImage*)categoryIcon {
    /*self.navigationItem.title = categoryName;
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 23)];
    [backButton setImage:categoryIcon forState:UIControlStateNormal];
    //switch to down arrow
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];*/

    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close", nil, [self translationsBundle], nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapBackButton:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (void)setupNavigationBarItemsForSearchResult{
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close", nil, [self translationsBundle], nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapBackButton:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view { // This is a hack, but it works.
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
