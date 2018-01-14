//
//  IMOFeaturedViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/25/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Overcoat/OVCResponse.h>
#import "IMOFeaturedViewController.h"
#import "IMOItemManager.h"
#import "IMOItem.h"
#import "IMOItemDetailViewController.h"
#import "AppDelegate.h"
#import "IMOItemTableViewCell.h"
#import "IMOSessionManager.h"
#import "UIColor+HTMLColors.h"
#import "GUAAlertView.h"
#import "IMOSearchViewController.h" 
#import "IMOLoadingViewController.h"

UIView *hidden1;
UIView *hidden2;

@interface IMOFeaturedViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *themesButton;
@property (weak, nonatomic) IBOutlet UIButton *tweaksButton;
@property (weak, nonatomic) IBOutlet KDCycleBannerView *bannerView;

@property (strong, nonatomic) NSArray *bannerImages;
@property (strong, nonatomic) NSArray *bannerItems;
@property (strong, nonatomic) IMOItem *selectedBanner;
//@property (strong, nonatomic) NSArray *items; // remove
@property (strong, nonatomic) NSArray *tweaks;
@property (strong, nonatomic) NSArray *themes;
@property (strong, nonatomic) IMOItemManager *manager;

@property (weak, nonatomic) IMOSessionManager* sessionManager;

@property (weak, nonatomic) UIViewController *searchRoot;

- (IBAction)tweaksButtonWasTapped:(id)sender;
- (IBAction)themesButtonWasTapped:(id)sender;
- (void)setItemsForCategory:(NSString *)category;
@end
 
@interface UIImage (AverageColor)
- (UIColor *)averageColor;
@end

/*
 UIImage+AverageColor.m
 
 Copyright (c) 2010, Mircea "Bobby" Georgescu
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Mircea "Bobby" Georgescu nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Mircea "Bobby" Georgescu BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@implementation UIImage (AverageColor)
 
- (UIColor *)averageColor {
 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
 
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);  
 
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}
 
@end

@implementation IMOFeaturedViewController

NSString *currentCategory = @"Themes";
UIVisualEffectView *visualEffectView;
BOOL colorize = YES;
#pragma mark - UIViewController

- (CGRect)frameForTabInTabBar:(UITabBar*)tabBar withIndex:(NSUInteger)index {
    NSUInteger currentTabIndex = 0;

    for (UIView* subView in tabBar.subviews)
    {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")])
        {
            if (currentTabIndex == index)
                return subView.frame;
            else
                currentTabIndex++;
        }
    }

    NSAssert(NO, @"Index is out of bounds");
    return CGRectNull;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.sessionManager.userManager refreshUpdates].then(^ (NSMutableArray *updatedItems) {
        if ([updatedItems count] == 0) {
            [self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)].alpha = 0;
        } else {
            [self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)].alpha = 1;
            [[self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)] setText:[NSString stringWithFormat:@"%ld", (unsigned long)[updatedItems count]]];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    self.selectedBanner = nil;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    colorize = YES;
    visualEffectView.hidden = NO;
    if ([_bannerView.subviews count] > 1) {
        if ([[_bannerView.subviews objectAtIndex:0] subviews].count > 1) {
            UIImageView *firstIview = (UIImageView *)[[_bannerView.subviews objectAtIndex:0].subviews objectAtIndex: self.lastIndex];
            [self setAverageColorToBar:firstIview];
        }
        else {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                          forBarMetrics:UIBarMetricsDefault];
            self.navigationController.navigationBar.translucent = YES;
            
            self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"939394"]; //939394
            self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"898A8B"];
            [self.navigationController.navigationBar
             setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"6A7B8D"] colorWithAlphaComponent:0.8], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
            self.navigationController.navigationBar.backgroundColor =  [UIColor clearColor];
        }
    }
    else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = YES;
    
        self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"939394"]; //939394
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"898A8B"];
        [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"6A7B8D"] colorWithAlphaComponent:0.8], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
        self.navigationController.navigationBar.backgroundColor =  [UIColor clearColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    colorize = NO;
    visualEffectView.hidden = YES;
}

-(void)viewDidLoad {
    self.tweakShadowView.hidden = YES;
    [self performSegueWithIdentifier:@"loading_modal" sender:self];
    self.lastIndex = 0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-170, self.view.frame.size.width, 58.7)];
    //imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = [UIImage imageNamed: @"tabbar-shadow.png"]; //tabbar-shadow.png
    [self.view addSubview: imageView];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
     forBarMetrics:UIBarMetricsDefault];
     self.navigationController.navigationBar.translucent = YES;
    
    self.navigationItem.rightBarButtonItem.tintColor = [[UIColor colorWithHexString:@"939394"] colorWithAlphaComponent:0.3];
    self.navigationItem.leftBarButtonItem.tintColor = [[UIColor colorWithHexString:@"939394"] colorWithAlphaComponent:0.3];//0.7

    //self.navigationController.navigationBar.tintColor = [[UIColor colorWithHexString:@"939394"] colorWithAlphaComponent:0.6]; //939394
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"898A8B"];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"6A7B8D"] colorWithAlphaComponent:0.8], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
    //TODO: pick color from bg
    //UIImage *image = [UIImage imageNamed: @"imods-assets-featured-tableview-background.png"];
    self.manager = [[IMOItemManager alloc] init];
    self.sessionManager = [IMOSessionManager sharedSessionManager];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage: image];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60.5;//60
    [self.tableView registerClass:[IMOItemTableViewCell class] forCellReuseIdentifier:@"Cell"];
    //[self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.bannerView.autoPlayTimeInterval = 10;
    self.bannerView.datasource = self;
    self.bannerView.delegate = self;
    self.bannerView.continuous = YES;
    
    CGRect bounds = self.navigationController.navigationBar.bounds;
    bounds.size.height = bounds.size.height + 20;
    bounds.origin.y = -20;

    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    visualEffectView.frame = bounds;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    visualEffectView.alpha = 0.93f;
    visualEffectView.userInteractionEnabled = false;

    [self.navigationController.navigationBar addSubview:visualEffectView];
    //TODO: reduce blur effect and darken tint
    self.navigationController.navigationBar.backgroundColor =  [UIColor clearColor];
    [self.navigationController.navigationBar sendSubviewToBack:visualEffectView];
    [[self findHairlineImageViewUnder:self.navigationController.navigationBar] setHidden:YES];
    
    [self loadBannerImages];
    
    [self setItemsForCategory: @"Themes"];
}

- (void) refreshUpdatesCount {
    UILabel* l = [[UILabel alloc] initWithFrame:
                    CGRectMake([self frameForTabInTabBar:self.tabBarController.tabBar withIndex:2].origin.x+75, -12, 20, 20)];
    [l setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0]];
    [l setText:@"1"];
    [l setBackgroundColor:[UIColor colorWithHexString:@"E13D50"]];
    [l setTextColor:[UIColor whiteColor]];
    [l setTextAlignment:NSTextAlignmentCenter];
    
    l.layer.cornerRadius = l.frame.size.height/2;
    l.layer.masksToBounds = YES;
    [self.sessionManager.userManager refreshUpdates].then(^ (NSMutableArray *updatedItems) {
        if ([updatedItems count] == 0) {
            l.alpha = 0;
        } else {
            l.alpha = 1;
            [l setText:[NSString stringWithFormat:@"%ld", (unsigned long)[updatedItems count]]];
        }
    });
    [self.tabBarController.tabBar addSubview:l];
}

- (void) observeValueForKeyPath:(NSString *)path ofObject:(id) object change:(NSDictionary *) change context:(void *)context {
    [hidden1 setHidden:FALSE];
    [hidden2 setHidden:FALSE];
    if ([path isEqualToString:@"image"]) {
        UIImageView *imgView = (UIImageView *)object;
        [self setAverageColorToBar:imgView];
        self.lastIndex = 1;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IMOItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if ([currentCategory isEqualToString:@"Themes"]) {
        [cell configureWithItem:self.themes[indexPath.row]];
    } else {
        [cell configureWithItem:self.tweaks[indexPath.row]];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([currentCategory isEqualToString:@"Themes"]) {
        return [self.themes count];
    } else {
        return [self.tweaks count];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"featured_item_detail_push" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"featured_item_detail_push"]) {
        if (self.selectedBanner) {
            IMOItemDetailViewController *controller = [segue destinationViewController];
            controller.item = self.selectedBanner;
        } else {
            IMOItemDetailViewController *controller = [segue destinationViewController];
            if ([currentCategory isEqualToString:@"Themes"]) {
                controller.item = self.themes[[self.tableView indexPathForSelectedRow].row];
            } else {
                controller.item = self.tweaks[[self.tableView indexPathForSelectedRow].row];
            }
        }
    }
    else if ([segue.identifier isEqualToString: @"search_push"]) {
        [(IMOSearchViewController *)[segue destinationViewController] initWithController:self];
        self.searchRoot = [segue destinationViewController];
        if ([self.bannerView.subviews count] > 0) {
            if ([[self.bannerView.subviews objectAtIndex:0].subviews count] >= (self.lastIndex+1)) {
                UIImageView *view = (UIImageView *)[[self.bannerView.subviews objectAtIndex:0].subviews objectAtIndex: self.lastIndex];
                [self setAverageColorToBar:view];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"profile_push"]) {
        [segue destinationViewController].hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"loading_modal"]) {
        [(IMOLoadingViewController *)[segue destinationViewController] initWithController:self];
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];//else if ([segue.identifier isEqualToString: @"profile_push"]) {
}

#pragma mark - KDCycleBannerViewDataource

- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView {
    return self.bannerImages;
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    return UIViewContentModeScaleAspectFit;
}

- (UIImage *)placeHolderImageOfZeroBannerView {
    return [UIImage imageNamed:@"carouselimage"];
}

#pragma mark - KDCycleBannerViewDelegate

- (void)cycleBannerView:(KDCycleBannerView *)bannerView didScrollToIndex:(NSUInteger)index {
    self.selectedBanner = nil;
    self.lastIndex = index+1;
    UIImageView *view = (UIImageView *)[[bannerView.subviews objectAtIndex:0].subviews objectAtIndex: index+1];
    [self setAverageColorToBar:view];
}

- (void)setAverageColorToBar:(UIImageView *)view {
    UIColor *averageColor = [view.image averageColor];
    if (self.searchRoot) {
        [(IMOSearchViewController *)self.searchRoot initWithColor: averageColor];
    }
    if (colorize) {
        self.bannerView.backgroundColor = [averageColor colorWithAlphaComponent:0.3];
        self.navigationItem.rightBarButtonItem.tintColor = [averageColor colorWithAlphaComponent:0.3];
        self.navigationItem.leftBarButtonItem.tintColor = [averageColor colorWithAlphaComponent:0.3];//0.7
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : [averageColor colorWithAlphaComponent:0.8], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]}];
    }
    
}

- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    self.selectedBanner = self.bannerItems[(long)index];
    [self performSegueWithIdentifier:@"featured_item_detail_push" sender:self];
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

- (void) loadBannerImages {
    void(^getURLs)(NSArray*) = ^(NSArray* banners) {
        NSMutableArray* imageURLs = [[NSMutableArray alloc] init];
        NSMutableArray* bannerData = [[NSMutableArray alloc] init];
        for (IMOBanner* banner in banners) {
            for(NSDictionary* banner_img in banner.banner_images) {
                NSURL* url = [banner_img valueForKey:@"url"];
                if (url) {
                    [bannerData addObject:banner.item];
                    [imageURLs addObject:url];
                }
            }
        }
        self.bannerImages = [NSArray arrayWithArray:imageURLs];
        self.bannerItems = [NSArray arrayWithArray:bannerData];
        [self.bannerView reloadDataWithCompleteBlock:^() {
            UIImageView *firstIview = (UIImageView *)[[_bannerView.subviews objectAtIndex:0].subviews objectAtIndex: 1];
            [firstIview addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        }];
    };
    if (!self.sessionManager.bannerManager.banners) {
        [self.sessionManager.bannerManager refreshBanners]
        .then(getURLs);
    } else {
        NSArray* banners = self.sessionManager.bannerManager.banners;
        getURLs(banners);
    }
}

- (IBAction)tweaksButtonWasTapped:(UIButton *)sender {
    sender.selected = true;
    self.themesButton.selected = false;
    self.shadowView.hidden = YES;
    self.tweakShadowView.hidden = NO;
    [self setItemsForCategory: @"Tweaks"];
}

- (IBAction)themesButtonWasTapped:(UIButton *)sender {
    sender.selected = true;
    self.tweaksButton.selected = false;
    self.shadowView.hidden = NO;
    self.tweakShadowView.hidden = YES;
    [self setItemsForCategory: @"Themes"];
}

- (void)setItemsForCategory:(NSString *)category {
    currentCategory = category;
    // Don't send request if running tests
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.isRunningTest) {
        return;
    }
    [self.manager fetchItemsByCategory: category].then(^(NSArray *result) {
        if ([result isKindOfClass: [NSArray class]]) {
            if ([category isEqualToString:@"Themes"]) {
                self.themes = result;
            } else {
                self.tweaks = result;
            }
        } else {
            if ([category isEqualToString:@"Themes"]) {
                self.themes = [NSArray arrayWithObject:result];
            } else {
                self.tweaks = [NSArray arrayWithObject:result];
            }
        }
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
        //self.items = @[];
    }).finally(^() {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        //[self.tableView reloadData];
    });

}

@end
