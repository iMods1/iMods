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

@interface IMOItemDetailViewController ()
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObject *managedItem;
@property (strong, nonatomic) NSEntityDescription *entity;

- (void)setupItemLabels;

@end

@implementation IMOItemDetailViewController

@synthesize item;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up Core Data objects
    self.managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
    self.entity = [NSEntityDescription entityForName:@"IMOInstalledItem" inManagedObjectContext:self.managedObjectContext];
    
       [self setupItemLabels];
}

- (void)viewWillAppear:(BOOL)animated {
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
            self.installButton.enabled = false;
            [self.installButton setTitle:@"Installed" forState:UIControlStateNormal | UIControlStateDisabled];
        }
    }
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

#pragma mark - Misc

- (IBAction)didTapInstallButton:(UIButton *)sender {
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
        self.installButton.enabled = false;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Installed" message:@"The item was installed." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction: action];
        [self presentViewController:alert animated:YES completion:nil];
        [self.installButton setTitle:@"Installed" forState:UIControlStateNormal | UIControlStateDisabled];
    }
}

- (void) setupItemLabels {
    self.titleLabel.text = [self.item valueForKey: @"display_name"];
    self.versionLabel.text = [self.item valueForKey: @"pkg_version"];
    self.priceLabel.text = [NSString stringWithFormat: @"$%@", [self.item valueForKey: @"price"]];
    self.summaryLabel.text = [self.item valueForKey: @"summary"];
    self.detailsLabel.text = [self.item valueForKey: @"desc"];
}
@end
