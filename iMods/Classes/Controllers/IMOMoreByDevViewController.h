//
//  IMOWishlistViewController.h
//  iMods
//
//  Created by Marcus Ferrario on 8/9/15.
//  Copyright © 2015 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "UIViewControllerNoAutorotate.h"
#import "IMOItem.h"
#import "IMODev.h"

@interface IMOMoreByDevViewController : UIViewControllerNoAutorotate <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *packagesTableView;

@property (weak, nonatomic) IBOutlet UILabel *author_name;
@property (weak, nonatomic) IBOutlet UILabel *author_bio;
@property (weak, nonatomic) IBOutlet UIImageView *author_avatar;
@property (weak, nonatomic) IBOutlet UITableView *devTableView;
@property IMOItem* item;
@end
