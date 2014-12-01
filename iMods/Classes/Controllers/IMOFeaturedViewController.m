//
//  IMOFeaturedViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/25/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Overcoat/OVCResponse.h>
#import "IMOFeaturedViewController.h"
#import "IMOItemManager.h"
#import "IMOItem.h"
#import "IMOItemDetailViewController.h"
#import "AppDelegate.h"
#import "IMOItemTableViewCell.h"
#import "IMOSessionManager.h"

@interface IMOFeaturedViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *themesButton;
@property (weak, nonatomic) IBOutlet UIButton *tweaksButton;
@property (weak, nonatomic) IBOutlet KDCycleBannerView *bannerView;

@property (strong, nonatomic) NSArray *bannerImages;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) IMOItemManager *manager;

@property (weak, nonatomic) IMOSessionManager* sessionManager;

- (IBAction)tweaksButtonWasTapped:(id)sender;
- (IBAction)themesButtonWasTapped:(id)sender;
- (void)setItemsForCategory:(NSString *)category;
@end

@implementation IMOFeaturedViewController

#pragma mark - UIViewController

-(void)viewDidLoad {
    UIImage *image = [UIImage imageNamed: @"imods-assets-featured-tableview-background.png"];
    self.manager = [[IMOItemManager alloc] init];
    self.sessionManager = [IMOSessionManager sharedSessionManager];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: image];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[IMOItemTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.bannerView.autoPlayTimeInterval = 5;
    self.bannerView.datasource = self;
    self.bannerView.delegate = self;
    self.bannerView.continuous = YES;
    
    [self loadBannerImages];
    
    [self setItemsForCategory: @"Themes"];
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IMOItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithItem:self.items[indexPath.row]];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"featured_item_detail_push" sender:self];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"featured_item_detail_push"]) {
        IMOItemDetailViewController *controller = [segue destinationViewController];
        controller.item = self.items[[self.tableView indexPathForSelectedRow].row];
    } else if ([segue.identifier isEqualToString: @"profile_push"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark - KDCycleBannerViewDataource

- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView {
    
    return self.bannerImages;
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    return UIViewContentModeScaleAspectFill;
}

- (UIImage *)placeHolderImageOfZeroBannerView {
    return [UIImage imageNamed:@"carouselimage"];
}

#pragma mark - KDCycleBannerViewDelegate

- (void)cycleBannerView:(KDCycleBannerView *)bannerView didScrollToIndex:(NSUInteger)index {
//    NSLog(@"didScrollToIndex:%ld", (long)index);
}

- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index {
//    NSLog(@"didSelectedAtIndex:%ld", (long)index);
}


#pragma mark - Misc

- (void) loadBannerImages {
    void(^getURLs)(NSArray*) = ^(NSArray* banners) {
        NSMutableArray* imageURLs = [[NSMutableArray alloc] init];
        for(IMOBanner* banner in banners) {
            for(NSDictionary* banner_img in banner.banner_images) {
                NSURL* url = [banner_img valueForKey:@"url"];
                if (url) {
                    [imageURLs addObject:url];
                }
            }
        }
        self.bannerImages = [NSArray arrayWithArray:imageURLs];
        [self.bannerView reloadDataWithCompleteBlock:nil];
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
    
    [self setItemsForCategory: @"Tweaks"];
}

- (IBAction)themesButtonWasTapped:(UIButton *)sender {
    sender.selected = true;
    self.tweaksButton.selected = false;
    
    [self setItemsForCategory: @"Themes"];
}

- (void)setItemsForCategory:(NSString *)category {
    // Don't send request if running tests
    [self.tableView reloadData];
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.isRunningTest) {
        return;
    }
    [self.manager fetchItemsByCategory: category].then(^(NSArray *result) {
        if ([result isKindOfClass: [NSArray class]]) {
            self.items = result;
        } else {
            self.items = [NSArray arrayWithObject:result];
        }
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
        self.items = @[];
    }).finally(^() {
        [self.tableView reloadData];
    });

}

@end
