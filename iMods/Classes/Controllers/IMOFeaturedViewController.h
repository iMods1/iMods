//
//  IMOFeaturedViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/25/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KDCycleBannerView.h>
#import "UIViewControllerNoAutorotate.h"
#import <CoreData/CoreData.h>

@interface IMOFeaturedViewController : UIViewControllerNoAutorotate <UITableViewDataSource, UITableViewDelegate, KDCycleBannerViewDataource, KDCycleBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *tweakShadowView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowView;
@property int lastIndex;
- (void) refreshUpdatesCount;
- (void)setItemsForCategory:(NSString *)category;
@end
