//
//  IMOProfileViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOProfileViewController.h"
#import "IMOUserManager.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import <RFGravatarImageView.h>

@interface IMOProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *installedItemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishlistItemsLabel;
@property (weak, nonatomic) IBOutlet RFGravatarImageView *profilePictureImageView;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObject *managedItem;

- (void)setupLabels;
- (void)setupProfilePicture;
- (IBAction)walletButtonTapped:(id)sender;

@end

@implementation IMOProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"imods-assets-profile-background"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.tabBarController.tabBar.hidden = YES;
    
    [self setupLabels];
    [self setupProfilePicture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupLabels {
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    if (manager.userLoggedIn) {
        self.nameLabel.text = manager.userProfile.fullname;
        self.wishlistItemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[manager.userProfile.wishlist count]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"IMOInstalledItem"];
        
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error: &error];

        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            self.installedItemsLabel.text = @"?";
        } else {
            self.installedItemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[result count]];
        }
    }
}

- (void)setupProfilePicture {
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    self.profilePictureImageView.email = manager.userProfile.email;
    self.profilePictureImageView.placeholder = [UIImage imageNamed:@"imods-logo"];
    [self.profilePictureImageView loadGravatar];
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2;
    self.profilePictureImageView.layer.masksToBounds = YES;
}

- (IBAction)walletButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"profile_wallet_push" sender:self];
}

@end
