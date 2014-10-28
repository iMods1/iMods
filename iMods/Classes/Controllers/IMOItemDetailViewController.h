//
//  IMOItemDetailViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOInstallationViewController.h"
#import <AccordionView.h>

@class IMOItem;

@interface IMOItemDetailViewController : UIViewController <IMOInstallationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *installButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IMOItem *item;
- (IBAction)didTapInstallButton:(UIButton *)sender;
- (IBAction)unwindToItemDetailViewController:(UIStoryboardSegue *)sender;
@end
