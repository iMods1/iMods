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
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadDetailsLabel;


- (IBAction)testButtonClicked:(id)sender;

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

- (IBAction)testButtonClicked:(id)sender {
    IMODownloadManager *downloadManager = [IMODownloadManager sharedDownloadManager];
    
    [self.progressView setProgress:0.25 animated:YES];
    
    IMOItemManager *itemManager = [[IMOItemManager alloc] init];
    [itemManager fetchItemByID: 1].then( ^(OVCResponse *response, NSError *error) {
        if (!error) {
            [self.progressView setProgress:0.5 animated:YES];
            IMOItem *item = [response valueForKey:@"result"];
            [downloadManager downloadURL:Deb item:item].then(^(OVCResponse *response, NSError *error) {
                [self.progressView setProgress:0.8 animated:YES];
                NSDictionary *result = [response valueForKey:@"result"];
                NSDictionary *itemDetails = [[result valueForKey:@"items"] firstObject];
                NSString *detailsString = [NSString stringWithFormat:@"Name: %@, DebURL: %@", [itemDetails valueForKey:@"pkg_name" ], [itemDetails valueForKey:@"deb_url"]];
                self.downloadDetailsLabel.text = detailsString;
                [self.progressView setProgress:1.0 animated:YES];
            }).catch(^(NSError *error) {
                self.downloadDetailsLabel.text = error.localizedDescription;
                [self.progressView setProgress:1.0 animated:YES];
            });
        } else {
            self.downloadDetailsLabel.text = error.localizedDescription;
            [self.progressView setProgress:1.0 animated:YES];
        }
    });
    
}
@end
