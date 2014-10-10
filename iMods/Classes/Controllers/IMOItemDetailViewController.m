//
//  IMOItemDetailViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOItemDetailViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <Stripe/Stripe.h>
#import "IMOUserManager.h"
#import "IMOItem.h"
#import "IMOBillingInfoManager.h"
#import "IMOBillingInfo.h"
#import "IMOOrderManager.h"
#import "IMOOrder.h"
#import "IMOCardViewController.h"

@interface IMOItemDetailViewController ()<IMOCardDelegate>
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObject *managedItem;
@property (strong, nonatomic) NSEntityDescription *entity;
@property (assign, nonatomic) BOOL isPurchased;
@property (assign, nonatomic) BOOL isInstalled;
@property (strong, nonatomic) IMOOrderManager *orderManager;
@property (strong, nonatomic) IMOBillingInfoManager *billingManager;

- (void)setupItemLabels;
- (void)setupInstallButton;
- (void)checkInstallStatus;
- (void)checkPurchaseStatus;
- (void)createPurchaseFromCard:(PTKCard *)card;
- (void)createPurchaseFromBillingInfo:(IMOBillingInfo *)billingInfo;
- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withCard:(PTKCard *)card;

- (PMKPromise *)billingInfo:(NSDictionary *)dict withCard:(PTKCard *)card;
- (PMKPromise *)order:(NSDictionary *)dict withBillingInfo:(IMOBillingInfo *)billingInfo
          withToken:(STPToken *)token;

@end

@implementation IMOItemDetailViewController

@synthesize item = _item;
@synthesize isPurchased = _isPurchased;

- (void)setIsPurchased:(BOOL)isPurchased {
    _isPurchased = isPurchased;
    if (isPurchased) {
        [self.installButton setTitle: @"Install" forState:UIControlStateNormal];
        [self.installButton setTitle: @"Installing" forState:UIControlStateDisabled];
        if (self.isInstalled) {
            [self.installButton setTitle: @"Installed" forState: UIControlStateDisabled];
            self.installButton.enabled = NO;
        }
        self.installButton.enabled = !self.isInstalled;
    } else {
        [self.installButton setTitle:@"Buy" forState:UIControlStateNormal];
        self.installButton.enabled = YES;
    }

}

@synthesize isInstalled = _isInstalled;
- (void)setIsInstalled:(BOOL)isInstalled {
    _isInstalled = isInstalled;
    if (self.isPurchased) {
        [self.installButton setTitle: @"Install" forState:UIControlStateNormal];
        [self.installButton setTitle: @"Installing" forState:UIControlStateDisabled];
        if (isInstalled) {
            [self.installButton setTitle: @"Installed" forState: UIControlStateDisabled];
            self.installButton.enabled = NO;
        }
        self.installButton.enabled = !self.isInstalled;
    } else {
        [self.installButton setTitle:@"Buy" forState:UIControlStateNormal];
        self.installButton.enabled = YES;
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Set Billing and Order managers
    self.orderManager = [[IMOOrderManager alloc] init];
    self.billingManager = [[IMOBillingInfoManager alloc] init];
    
    // Set up Core Data objects
    self.managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
    self.entity = [NSEntityDescription entityForName:@"IMOInstalledItem" inManagedObjectContext:self.managedObjectContext];
    
    [self setupItemLabels];

    [self setupInstallButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupInstallButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"item_detail_card_modal"]) {
        ((IMOCardViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - Misc

- (IBAction)didTapInstallButton:(UIButton *)sender {
    if (self.isPurchased) {
        if (self.isInstalled) {
            // Bail - this case should never be reached
            return;
        } else {
            // Handle tap on Install button.
            
            // TODO: Use package manager to handle actual item installation
            
            self.managedItem = [[NSManagedObject alloc] initWithEntity: self.entity insertIntoManagedObjectContext: self.managedObjectContext];
            [self.managedItem setValue:[self.item valueForKey: @"pkg_name"] forKey: @"name"];
            [self.managedItem setValue:[self.item valueForKey: @"iid"] forKey: @"id"];
            [self.managedItem setValue:[self.item valueForKey: @"pkg_version"] forKey: @"version"];
            
            NSError *error = nil;
            [self.managedObjectContext save: &error];
            
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Application Error" message: @"There was a problem with the application." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction: action];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                self.installButton.enabled = NO;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Installed" message:@"The item was installed." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction: action];
                [self presentViewController:alert animated:YES completion:^{
                    self.isInstalled = YES;
                }];
            }
        }
    } else {
        // Handle tap on "Purchase" button
        [self.billingManager refreshBillingMethods].then(^{
            NSLog(@"Current billing method count: %lu", (unsigned long)[self.billingManager billingMethods].count);
            if ([self.billingManager billingMethods].count <= 0) {
                [self performSegueWithIdentifier:@"item_detail_card_modal" sender:self];
            } else {
                /*
                // TODO: Select billing method, make purchase from billing method
                // TODO: Make better. Currently, just chooses the first
                IMOBillingInfo *billingInfo = [self.billingManager billingMethods][0];
                NSLog(@"Selected billing method: %@", billingInfo);
                [self createPurchaseFromBillingInfo: billingInfo];
                */
                // TODO: Fix problem where billing info data is null
                [self performSegueWithIdentifier:@"item_detail_card_modal" sender:self];
            }
        });
    }
}

- (void) setupItemLabels {
    self.titleLabel.text = [self.item valueForKey: @"display_name"];
    self.versionLabel.text = [self.item valueForKey: @"pkg_version"];
    self.priceLabel.text = [NSString stringWithFormat: @"$%@", [self.item valueForKey: @"price"]];
    self.summaryLabel.text = [self.item valueForKey: @"summary"];
    self.detailsLabel.text = [self.item valueForKey: @"desc"];
}

- (void)setupInstallButton {
    [self checkPurchaseStatus];
    [self checkInstallStatus];
}

- (void)checkInstallStatus {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = self.entity;
    NSLog(@"Item ID: %@", [self.item valueForKey: @"iid"]);
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@", [self.item valueForKey: @"iid"]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error: &error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"Fetched result: %@", result);
        if (!([result count] == 0)) {
            self.managedItem = result[0];
            self.isInstalled = YES;
        } else {
            self.isInstalled = NO;
        }
    }
}

- (void)checkPurchaseStatus {

    NSNumber *itemId = [self.item valueForKey:@"iid"];

    [self.orderManager fetchOrderByUserItem: (NSUInteger)itemId.integerValue].then(^(OVCResponse *response, NSError *error) {
        NSLog(@"Returned responses: %@", response);
        self.isPurchased = ([response.result count] > 0);
    }).catch(^(NSError *error) {
        NSLog(@"No order found for current user for item: %@", self.item);
        self.isPurchased = NO;
    });
}

- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withCard:(PTKCard *)card {
    [self dismissViewControllerAnimated: YES completion: ^{
        [self createPurchaseFromCard: card];
    }];
}

- (void)createPurchaseFromCard:(PTKCard *) card {
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
            NSLog(@"Result from billingInfo:withCard: %@", response);
            [self createPurchaseFromBillingInfo: response];
        }).catch(^(NSError *error) {
            NSLog(@"Error creating billing info.");
            // TODO: Gracefully handle error
        });
    }
}

- (void)createPurchaseFromBillingInfo:(IMOBillingInfo *)billingInfo {
    NSDictionary *orderDict = @{
                                @"item_id": [self.item valueForKey: @"iid"],
                                @"pkg_name": [self.item valueForKey: @"pkg_name"],
                                @"totalPrice": [self.item valueForKey: @"price"],
                                @"totalCharged": [self.item valueForKey: @"price"],
                                @"quantity": @(1),
                                @"orderDate": [NSDate date]
                                };
    
    
   
    STPCard *card = [[STPCard alloc] init];
    
    NSLog(@"creditCardNumber: %@", billingInfo.creditcardNumber);
    NSLog(@"creditCardExpiration: %@", billingInfo.creditcardExpiration);
    NSLog(@"creditCardCVV : %@", billingInfo.creditcardCVV);
    card.number = billingInfo.creditcardNumber;

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:billingInfo.creditcardExpiration];
    NSInteger month = [components month];
    NSInteger year = [components year];

    card.expMonth = month;
    card.expYear = year;
    card.cvc = billingInfo.creditcardCVV;
    NSLog(@"Card: %@", card);
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
            NSLog(@"There was an error creating the Stripe Token: %@", error.localizedDescription);
            // TODO: Notify user of error
        } else {
            [self order:orderDict withBillingInfo:billingInfo withToken:token].then(^{
                self.isPurchased = YES;
            }).catch(^(NSError *error) {
                // TODO: Notify user
                NSLog(@"Error with backend %@", error.localizedDescription);
            });
        }
    }];
}


- (PMKPromise *)billingInfo:(NSDictionary *)dict withCard:(PTKCard *)card {
    
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
    
    NSLog(@"Billing Info Dictionary: %@", mutableDict);
    
    NSError *error = nil;
    IMOBillingInfo *billingInfo = [[IMOBillingInfo alloc] initWithDictionary: mutableDict error: &error];
    
    if (error) {
        NSLog(@"Error creating billing info: %@", error.localizedDescription);
        return nil;
    } else {
        return [self.billingManager addNewBillingMethod: billingInfo];
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

#pragma mark - IMOMockInstallationDelegate

- (PRHTask *)taskForMockInstallation:(IMOMockInstallationViewController *)installationViewController withOptions:(NSDictionary *)options {
    // TODO: Generate PRHTask from package manager
    // For now, using dummy task
    return [PRHTask taskWithProgramName:@"bash" arguments:@"-c", @"sleep 3; echo \"Step 1\";sleep 3;echo \"Step 2\";sleep 3;echo \"Done\"", nil];
}

- (void)installationDidDismiss:(IMOMockInstallationViewController *)installationViewController {
    
}

- (void)installationDidFinish:(IMOMockInstallationViewController *)installationViewController {
    
}

- (IBAction)unwindToItemDetailViewController:(UIStoryboardSegue *)sender {
    // stub
}

@end
