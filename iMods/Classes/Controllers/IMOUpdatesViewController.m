//
//  IMOUpdatesViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

// TODO: get rid of delete when swiping left

#import "IMOUpdatesViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "IMOSessionManager.h"
#import "UIColor+HTMLColors.h"
#import <QuartzCore/QuartzCore.h>
#import "GUAAlertView.h"
#import "IMOItemDetailViewController.h"
#import "IMOItem.h"
#import "MTLJSONAdapter.h"
#import "IMOInstallationViewController.h"

@interface IMOUpdatesViewController ()
@property (strong, nonatomic) NSMutableArray *installed;
@property (strong, nonatomic) NSMutableArray *installedItems;
@property (strong, nonatomic) NSMutableArray *updatedItems;
@property (strong, nonatomic) IMOItem *item;
@property (weak, nonatomic) IBOutlet UILabel *no_updates;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *uninstallButton;

@property (strong, nonatomic) IMOPackageManager* packageManager;

@property (weak) IMOSessionManager* sessionManager;

- (IBAction)updateButtonWasTapped:(UIButton *)sender;
- (IBAction)uninstallButtonWasTapped:(UIButton *)sender;

@end

@implementation IMOUpdatesViewController

NSInteger currentExpandedIndex = -1;
BOOL installed = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"5D6E7C"];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"E8E8E8"];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"616E7B"]}];

    [[self findHairlineImageViewUnder:self.navigationController.navigationBar] setHidden:YES];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    UIImage *image = [UIImage imageNamed: @"update-bg.png"];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: image];
    //self.tableView.separatorColor = [UIColor colorWithHexString:@"E6E3E3"];
    self.tableView.separatorColor = [UIColor clearColor];
    //self.tableView.rowHeight = 60;
    
    self.sessionManager = [IMOSessionManager sharedSessionManager];
    self.packageManager = [IMOPackageManager sharedPackageManager];
    
    // Fix for border
    /*sv.layer.borderWidth = 1;
    sv.layer.borderColor = [backColor CGColor];
    sv.layer.cornerRadius = sv.frame.size.height/2;
    sv.layer.masksToBounds = YES;*/
    self.updateButton.tintColor = [UIColor colorWithHexString:@"5D6E7C"];
    self.uninstallButton.tintColor = [UIColor colorWithHexString:@"A5ADB1"];
    self.no_updates.textColor = [UIColor colorWithHexString:@"A5ADB1"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    // Load list of installed items from persistent store

    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"616E7B"]}];
    
    [self.sessionManager.userManager refreshInstalled].then(^() {
        [self.sessionManager.userManager refreshUpdates].then(^(NSMutableArray *updatedItems) {
            if ([updatedItems count] == 0) {
                [self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)].alpha = 0;
            } else {
                [self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)].alpha = 1;
                [[self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)] setText:[NSString stringWithFormat:@"%ld", [updatedItems count]]];
            }
            self.updatedItems = [NSMutableArray arrayWithArray:updatedItems];
            if (installed == NO) {
                self.installedItems = self.updatedItems;
                if ([self.updatedItems count] == 0) {
                    self.no_updates.alpha = 1;
                    self.no_updates.text = @"No Updates";
                } else {
                    self.no_updates.alpha = 0;
                }
            } else {
                self.installedItems = self.installed;
                if ([self.installed count] == 0) {
                    self.no_updates.alpha = 1;
                    self.no_updates.text = @"No Mods";
                } else {
                    self.no_updates.alpha = 0;
                }
            }
            // add animation
            [self.tableView reloadData];

            self.installed = [self.sessionManager.userManager.installedItems mutableCopy];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *childCellID = @"changelogCell";
    NSString *parentCellID = @"updateCell";
    BOOL isChild = currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + 1;
    UITableViewCell *cell;
    if (isChild) {
        cell = [tableView dequeueReusableCellWithIdentifier:childCellID];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:parentCellID];
    }
    //if (cell == nil) {
        if (!isChild) {
            NSMutableDictionary *item = [self.installedItems objectAtIndex: indexPath.row];
            
            cell = [[IMOUpdatesParentCell alloc] initWithItem:item forIndex:indexPath withViewController:self];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentCellID];
        }
    //}
    if (isChild) {
        NSDictionary *updatedApp = [self.installedItems objectAtIndex:currentExpandedIndex];
        NSString *changelog = [updatedApp objectForKey:@"changelog"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:changelog];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineHeightMultiple:0.8];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [changelog length])];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 15, cell.bounds.size.width - 25, 30)];
        label.attributedText = attributedString;
        label.numberOfLines = 0;
        label.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        label.textColor = [UIColor colorWithHexString:@"838B93"];
        [label sizeToFit];
        [cell addSubview:label];
        UIImageView *bg = [[UIImageView alloc] initWithFrame:cell.frame];
        bg.backgroundColor = [UIColor clearColor];
        bg.opaque = NO;
        bg.image = [UIImage imageNamed:@"updates-dropdown.png"];
        cell.backgroundView = bg;

        UIImageView *tri = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 23, 13)];
        tri.backgroundColor = [UIColor clearColor];
        tri.opaque = NO;
        tri.image = [UIImage imageNamed:@"dropdown-triangle.png"];

        [cell addSubview:tri];
    }
    
    else {
        int topIndex = (currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex) ? indexPath.row - 1: indexPath.row; //This is basically the indexPath.row of the cell, regardless of if a cell is expanded or not.
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChild = currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + 1;
    if (isChild) {
        UIFont *font = [UIFont systemFontOfSize:13];
        NSDictionary *updatedApp = [self.installedItems objectAtIndex:currentExpandedIndex];
        NSString *changelog = [updatedApp objectForKey:@"changelog"];
        NSInteger length = [[changelog componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count];
        CGFloat lines = (CGFloat)40;
        if (length > 1) {
            lines = (CGFloat)length*12;
        }
        return lines;
    }
    else {
        return 60.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.installedItems count] + ((currentExpandedIndex > -1) ? 1 : 0);
}

- (void)expandItemAtIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSInteger insertPos = index + 1;
    for (NSInteger i = 0; i < 1; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)collapseSubItemsAtIndex:(NSInteger)index {
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSInteger i = index + 1; i <= index + 1; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!installed) {
        BOOL isChild = currentExpandedIndex > -1 && indexPath.row > currentExpandedIndex && indexPath.row <= currentExpandedIndex + 1;
        if (isChild) {
            [tableView beginUpdates];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView endUpdates];
            return;
        }
        
        if (currentExpandedIndex == indexPath.row) {
            [self.tableView beginUpdates];
            [self collapseSubItemsAtIndex:currentExpandedIndex];
            currentExpandedIndex = -1;
            [self.tableView endUpdates];
        } else {
            // TODO: when clicking missing changelog then clicking one with changelog, fails.
            BOOL shouldCollapse = currentExpandedIndex > -1;
            BOOL began = NO;
            if (shouldCollapse) {
                began = YES;
                [self.tableView beginUpdates];
                [self collapseSubItemsAtIndex:currentExpandedIndex];
            }
            
            currentExpandedIndex = (shouldCollapse && indexPath.row > currentExpandedIndex) ? indexPath.row - 1 : indexPath.row;
            NSDictionary *updatedApp = [self.installedItems objectAtIndex:indexPath.row];
            if (updatedApp) {
                NSString *changelog = [updatedApp valueForKey:@"changelog"];
                if (changelog != nil) {
                    if ([changelog length] > 0) {
                        if (began == NO) {
                            began = YES;
                            [self.tableView beginUpdates];
                        }
                        [self expandItemAtIndex:currentExpandedIndex];
                    }
                }
            }
            if (began == YES) {
                [self.tableView endUpdates];
            }
        }
    } else {
       [self performSegueWithIdentifier:@"installed_details_segue" sender:self]; 
    }
}

-(void)uninstallPackage:(UIButton*)sender {
    NSMutableDictionary *item = self.installedItems[sender.tag];
    NSString* pkg_name = [item valueForKey:@"pkg_name"];
    NSString* display_name = [item valueForKey:@"display_name"];
    //TODO; pkg_name actually corresponds to bundle id

    GUAAlertView *v = [GUAAlertView alertViewWithTitle:NSLocalizedStringFromTableInBundle(@"Attention", nil, [self translationsBundle], nil)
                            message:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Are you sure you want to remove \"%@\" from your device?", nil, [self translationsBundle], nil), display_name]
                            buttonTitle:NSLocalizedStringFromTableInBundle(@"Proceed", nil, [self translationsBundle], nil)
                            buttonTouchedAction:^{
                                NSLog(@"button touched");
                                [self.installedItems removeObject: item];
                                [self.installed removeObject: item];
                                [self.tableView reloadData];
                                self.uninstallInvoker = pkg_name;
                                [self performSegueWithIdentifier:@"installed_uninstallation_modal" sender:self];
                                //[self.sessionManager.packageManager removePackage:pkg_name];
                            } dismissAction:^{
                                NSLog(@"dismiss");
                            }
                            buttons: YES];
    [v show];
}

-(void)installPackage:(UIButton*)sender {
    NSMutableDictionary *item = self.installedItems[sender.tag];
    NSString* pkg_name = [item valueForKey:@"pkg_name"];
    NSString* pkg_version = [item valueForKey:@"pkg_version_latest"];

    GUAAlertView *v = [GUAAlertView alertViewWithTitle:NSLocalizedStringFromTableInBundle(@"Attention", nil, [self translationsBundle], nil)
                            message:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Are you sure you want to update \"%@\" to version %@?", nil, [self translationsBundle], nil), [item valueForKey:@"display_name"], pkg_version]
                            buttonTitle:NSLocalizedStringFromTableInBundle(@"Proceed", nil, [self translationsBundle], nil)
                            buttonTouchedAction:^{
                                [self performSegueWithIdentifier:@"updates_install_segue" sender:self];
                                [self.tableView reloadData];
                            } dismissAction:^{
                                NSLog(@"dismiss");
                            }
                            buttons: YES];
    [v show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"updates_install_segue"]) {
        NSError *error;
        self.item = [MTLJSONAdapter modelOfClass:[IMOItem class] fromJSONDictionary:self.installedItems[[self.tableView indexPathForSelectedRow].row] error:&error];
        ((IMOInstallationViewController *)segue.destinationViewController).delegate = self;
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
            ((IMOInstallationViewController *)segue.destinationViewController).modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            ((IMOInstallationViewController *)segue.destinationViewController).modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
    } else if ([segue.identifier isEqualToString: @"installed_uninstallation_modal"]) {
        IMOUninstallationViewController *controller = [segue destinationViewController];
        controller.pkg_name = self.uninstallInvoker;
    } else if ([segue.identifier isEqualToString:@"installed_details_segue"]) {
        IMOItemDetailViewController *controller = [segue destinationViewController];
        NSError *error;
        controller.item = [MTLJSONAdapter modelOfClass:[IMOItem class] fromJSONDictionary:self.installed[[self.tableView indexPathForSelectedRow].row] error:&error];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)updateButtonWasTapped:(UIButton *)sender {
    //[sender setHighlighted:YES];
    self.updateButton.tintColor = [UIColor colorWithHexString:@"5D6E7C"];
    self.uninstallButton.tintColor = [UIColor colorWithHexString:@"A5ADB1"];
    [[IMOUpdatesParentCell alloc] installedTab:NO];
    installed = NO;
    self.installedItems = self.updatedItems;
    if ([self.updatedItems count] == 0) {
        self.no_updates.alpha = 1;
        self.no_updates.text = @"No Updates";
    } else {
        self.no_updates.alpha = 0;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)uninstallButtonWasTapped:(UIButton *)sender {
    //[sender setHighlighted:YES];
    [self.tableView beginUpdates];
    BOOL shouldCollapse = currentExpandedIndex > -1;
    if (shouldCollapse) {
        [self collapseSubItemsAtIndex:currentExpandedIndex];
        currentExpandedIndex = -1;
    }
    [self.tableView endUpdates];
    self.uninstallButton.tintColor = [UIColor colorWithHexString:@"5D6E7C"];
    self.updateButton.tintColor = [UIColor colorWithHexString:@"A5ADB1"];
    [[IMOUpdatesParentCell alloc] installedTab:YES];
    installed = YES;
    self.installedItems = self.installed;
    if ([self.installed count] == 0) {
        self.no_updates.alpha = 1;
        self.no_updates.text = @"No Mods";
    } else {
        self.no_updates.alpha = 0;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Misc

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

- (void)installationDidFinish:(IMOInstallationViewController *)installationViewController {
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

@end
