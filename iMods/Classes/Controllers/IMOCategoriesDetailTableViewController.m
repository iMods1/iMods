//
//  IMOCategoriesDetailTableViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCategoriesDetailTableViewController.h"
#import "IMOItem.h"
#import "IMOItemManager.h"
#import "IMOItemDetailViewController.h"
#import "IMOCategoryItemTableViewCell.h"
#import <Overcoat/OVCResponse.h>
#import "UIColor+HTMLColors.h"

@interface IMOCategoriesDetailTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IMOItemManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *sortByDateButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByRatingButton;
@property (weak, nonatomic) IBOutlet UILabel *sortByDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sortByRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *categoryIconButton;
@property NSSortDescriptor* sortByDate;
@property NSSortDescriptor* sortByRating;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) UIViewController *globalRoot;
@end

@implementation IMOCategoriesDetailTableViewController

@synthesize items;
@synthesize category;

- (void) initWithController:(UIViewController*)root {
    [UIView animateWithDuration:1.0 animations:^(void) {
        root.view.alpha = 1;
        root.view.alpha = 0;
    }];
    self.globalRoot = root;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Current category: %@", self.category);
    
    self.manager = [[IMOItemManager alloc] init];
    
    // Setup blur view
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    self.categoryIconButton.contentMode = UIViewContentModeScaleAspectFit;
    self.categoryIconButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.categoryIconButton.imageView.tintColor = [UIColor colorWithHexString:@"6D7B88"];
    self.categoryIconButton.tintColor = [UIColor colorWithHexString:@"6D7B88"];
    [self.categoryIconButton setImage:self.categoryIcon forState:UIControlStateNormal & UIControlStateHighlighted];
    [self.categoryIconButton setTitle:[@"  " stringByAppendingString:NSLocalizedStringFromTableInBundle(self.category, nil, [self translationsBundle], nil)] forState:UIControlStateNormal];
    self.categoryNameLabel.text = NSLocalizedStringFromTableInBundle(self.category, nil, [self translationsBundle], nil);
    self.categoryNameLabel.textColor = [UIColor colorWithHexString:@"6D7B88"];
    self.categoryNameLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17.0];
    self.tableView.rowHeight = 45;
    //self.sortByDateLabel.textColor = [UIColor colorWithHexString:@"9f9f9f"];
    //self.sortByRatingLabel.textColor = [UIColor colorWithHexString:@"9f9f9f"];
    
    [self.tableView registerClass:IMOCategoryItemTableViewCell.class forCellReuseIdentifier:@"Cell"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Set sorting methods
    self.sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"add_date" ascending:NO];
    self.sortByRating = [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO];

    self.sortByDateButton.imageView.tintColor = [UIColor colorWithHexString:@"57616B"];
    self.sortByDateLabel.textColor = [UIColor colorWithHexString:@"57616B"];
    self.sortByRatingButton.imageView.tintColor = [UIColor colorWithHexString:@"8D9AA6"];
    self.sortByRatingLabel.textColor = [UIColor colorWithHexString:@"8D9AA6"];
    
    [self.manager fetchItemsByCategory: self.category].then(^(NSArray *result) {
        if ([result isKindOfClass: [NSArray class]]) {
            self.items = result;
        } else {
            self.items = [NSArray arrayWithObject: result];
        }
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
        self.items = @[];
    }).finally(^() {
        self.items = [self.items sortedArrayUsingDescriptors:@[self.sortByDate]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.items = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMOCategoryItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (cell == nil) {
        cell = [[IMOCategoryItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    IMOItem* item = [self.items objectAtIndex: indexPath.row];
    
    // Configure the cell...
    [cell configureWithItem:item];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"categories_item_detail_modal"]) {
        UINavigationController* nav = [segue destinationViewController];
        IMOItemDetailViewController *controller = (IMOItemDetailViewController*)nav.topViewController;
        controller.item = self.items[[self.tableView indexPathForSelectedRow].row];
        [controller setUpNavigationBarItemsForCategory:self.category icon:self.categoryIcon];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"categories_item_detail_modal" sender:self];
}

- (IBAction)didTapIconButton:(id)sender {
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.globalRoot.view.alpha = 0;
        self.globalRoot.view.alpha = 1;
    }];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)didTapSortByRating:(id)sender {
    self.sortByDateButton.imageView.tintColor = [UIColor colorWithHexString:@"8D9AA6"];
    self.sortByDateLabel.textColor = [UIColor colorWithHexString:@"8D9AA6"];
    self.sortByRatingButton.imageView.tintColor = [UIColor colorWithHexString:@"57616B"];
    self.sortByRatingLabel.textColor = [UIColor colorWithHexString:@"57616B"];
    self.items = [self.items sortedArrayUsingDescriptors:@[self.sortByRating]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)didTapSortByDateButton:(id)sender {
    self.sortByDateButton.imageView.tintColor = [UIColor colorWithHexString:@"57616B"];
    self.sortByDateLabel.textColor = [UIColor colorWithHexString:@"57616B"];
    self.sortByRatingButton.imageView.tintColor = [UIColor colorWithHexString:@"8D9AA6"];
    self.sortByRatingLabel.textColor = [UIColor colorWithHexString:@"8D9AA6"];
    self.items = [self.items sortedArrayUsingDescriptors:@[self.sortByDate]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

@end
