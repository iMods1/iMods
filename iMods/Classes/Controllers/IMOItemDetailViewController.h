//
//  IMOItemDetailViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOInstallationViewController.h"
#import "AXRatingView.h"

@class IMOItem;

@interface IMOItemDetailViewController : UIViewController <IMOInstallationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *installButton;
@property (weak, nonatomic) IBOutlet UIImageView* itemIconImage;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (strong, nonatomic) IMOItem *item;
@property (weak, nonatomic) IBOutlet AXRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingThankYou;

@property (weak, nonatomic) IBOutlet UIImageView *tapToRateLabel;
- (IBAction)didTapInstallButton:(UIButton *)sender;
- (IBAction)unwindToItemDetailViewController:(UIStoryboardSegue *)sender;
- (void)setUpNavigationBarItemsForCategory:(NSString*)categoryName icon:(UIImage*)categoryIcon;
- (void)setupNavigationBarItemsForSearchResult:(NSString*)back;
- (void)setupItem:(IMOItem*)item;
@end
