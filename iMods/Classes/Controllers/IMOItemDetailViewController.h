//
//  IMOItemDetailViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOMockInstallationViewController.h"

@class IMOItem;

@interface IMOItemDetailViewController : UIViewController <IMOMockInstallationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *installButton;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IMOItem *item;
- (IBAction)didTapInstallButton:(UIButton *)sender;
- (IBAction)unwindToItemDetailViewController:(UIStoryboardSegue *)sender;
@end
