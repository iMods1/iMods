//
//  IMOTestDownloadViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/27/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOTestDownloadViewController.h"
#import "IMODownloadManager.h"
#import "IMOItem.h"
#import "IMOItemmanager.h"

@interface IMOTestDownloadViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *assetsProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *packageProgressView;
@property (weak, nonatomic) IBOutlet UILabel *assetsDownloadDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *packageDownloadDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexDownloadDetailsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;


- (IBAction)testAssetButtonClicked:(id)sender;
- (IBAction)testPackageButtonClicked:(id)sender;
- (IBAction)testIndexButtonClicked:(id)sender;

@end

@implementation IMOTestDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)testAssetButtonClicked:(id)sender {
    IMODownloadManager *downloadManager = [IMODownloadManager sharedDownloadManager];
    
    [self.assetsProgressView setProgress:0.25 animated:YES];
    
    IMOItemManager *itemManager = [[IMOItemManager alloc] init];
    [itemManager fetchItemByID: 10].then(^(IMOItem *item) {
        [self.assetsProgressView setProgress:0.5 animated:YES];
        [downloadManager download:Assets item:item].then(^(NSDictionary *results) {
            [self.assetsProgressView setProgress:1.0 animated:YES];
            UIImage *icon = [UIImage imageWithData:[results valueForKey:@"icon"]];
            self.iconImageView.image = icon;
            UIImage *screenshot = [UIImage imageWithData:[results valueForKey:@"screenshot"]];
            self.screenshotImageView.image = screenshot;
            self.assetsDownloadDetailsLabel.text = @"Downloaded Successfully!";
        }).catch(^(NSError *error) {
            self.assetsDownloadDetailsLabel.text = error.localizedDescription;
            [self.assetsProgressView setProgress:1.0 animated:YES];
        });
    }).catch(^(NSError *error) {
        NSLog(@"Error with fetch: %@", error.localizedDescription);
        self.packageDownloadDetailsLabel.text = error.localizedDescription;
        [self.packageProgressView setProgress:1.0 animated:YES];
    });
}

- (IBAction)testPackageButtonClicked:(id)sender {
    IMODownloadManager *downloadManager = [IMODownloadManager sharedDownloadManager];
    
    [self.packageProgressView setProgress:0.25 animated:YES];
    
    IMOItemManager *itemManager = [[IMOItemManager alloc] init];
    [itemManager fetchItemByID: 10].then(^(IMOItem *item) {
        [self.packageProgressView setProgress:0.5 animated:YES];
        [downloadManager download:Deb item:item].then(^(NSData *data) {
            [self.packageProgressView setProgress:1.0 animated:YES];
            self.packageDownloadDetailsLabel.text = [data description];
        }).catch(^(NSError *error) {
            self.packageDownloadDetailsLabel.text = error.localizedDescription;
            [self.packageProgressView setProgress:1.0 animated:YES];
        });
    }).catch(^(NSError *error) {
        NSLog(@"Error with fetch: %@", error.localizedDescription);
        self.packageDownloadDetailsLabel.text = error.localizedDescription;
        [self.packageProgressView setProgress:1.0 animated:YES];
    });
}

- (IBAction)testIndexButtonClicked:(id)sender {
    IMODownloadManager *downloadManager = [IMODownloadManager sharedDownloadManager];
    
    [self.packageProgressView setProgress:0.25 animated:YES];
    
    [downloadManager downloadIndex]
    .then(^(NSString* filePath){
        self.indexDownloadDetailsLabel.text = filePath;
    });
}
@end
