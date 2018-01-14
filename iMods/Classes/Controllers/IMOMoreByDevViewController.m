//
//  IMOWishlistViewController.m
//  iMods
//
//  Created by Marcus Ferrario on 8/9/15.
//  Copyright © 2015 Ryan Feng. All rights reserved.
//

#import "IMOMoreByDevViewController.h"
#import "UIColor+HTMLColors.h"
#import "IMOItemManager.h"
#import "IMOCategoryItemTableViewCell.h"
#import "IMOItemDetailViewController.h"
#import "IMODev.h"

@interface IMOMoreByDevViewController ()
    @property (nonatomic, strong) NSArray *packages;
    @property (nonatomic, strong) NSString *contact_email;
    @property (nonatomic, strong) NSString *contact_name;
    @property (nonatomic, strong) NSString *contact_twitter;
    @property (weak, nonatomic) IBOutlet UIButton *email;
    @property (weak, nonatomic) IBOutlet UIButton *twitter;
    @property (strong, nonatomic) IMOItemManager *manager;
@end

@implementation IMOMoreByDevViewController
- (IBAction)twitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        if ([self.contact_twitter rangeOfString:@"@"].location == 0) {
            NSArray *parts = [self.contact_twitter componentsSeparatedByString:@"@"];
            if ([parts count] > 1) {
                self.contact_twitter = [parts objectAtIndex:1];
            }
        } else if ([self.contact_twitter rangeOfString:@"twitter.com/"].location != NSNotFound) {
            NSArray *parts = [self.contact_twitter componentsSeparatedByString:@"twitter.com/"];
            if ([parts count] > 1) {
                self.contact_twitter = [parts objectAtIndex:1];
                if ([self.contact_twitter rangeOfString:@"/"].location != NSNotFound) {
                    NSArray *parts2 = [self.contact_twitter componentsSeparatedByString:@"/"];
                    if ([parts2 count] > 1) {
                        self.contact_twitter = [parts objectAtIndex:0];
                    }
                }
            }
        }
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"\@%@ Hey %@,", self.contact_twitter, self.contact_name]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
- (IBAction)email:(id)sender {
    
    MFMailComposeViewController *comp=[[MFMailComposeViewController alloc]init];
    [comp setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        [comp setToRecipients:[NSArray arrayWithObjects:self.contact_email, nil]];
        [comp setSubject:@"Mail to Dev"];
        //[comp setMessageBody:@"Hello bro" isHTML:NO];
        [comp setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:comp animated:YES completion:nil];
    }
    else {
        UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Mail not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Couldn't send mail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)exitView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[IMOItemManager alloc] init];
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    self.packagesTableView.delegate = self;
    self.packagesTableView.dataSource = self;
    self.packagesTableView.rowHeight = 45;
    
    [self.packagesTableView registerClass:IMOCategoryItemTableViewCell.class forCellReuseIdentifier:@"Cell"];
    
    [self.packagesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.packagesTableView.backgroundColor = [UIColor clearColor];
    self.packagesTableView.opaque = NO;
    //self.packages = @[];

    [self.manager fetchItemsByAuthor: self.item.author_id].then(^(IMODev *result) {
        self.contact_name = result.fullname;
        self.author_name.text = result.fullname;
        self.author_bio.text = result.summary;
        self.author_avatar.image = [UIImage imageNamed:@"imods_default"];
        self.author_avatar.layer.cornerRadius = self.author_avatar.frame.size.width / 2;
        self.author_avatar.layer.masksToBounds = YES;
        self.packages = result.items;
        self.contact_email = result.contact_email;
        self.contact_twitter = result.twitter;
        [self.packagesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        if ([result.twitter isKindOfClass:[NSNull class]] || result.twitter == nil) {
            self.twitter.hidden = YES;
        }
        if ([result.contact_email isKindOfClass:[NSNull class]] || result.contact_email == nil) {
            self.email.hidden = YES;
        }
        if (result.profile_image_url && ![result.profile_image_url isEqualToString:@""] && result.profile_image_url != [NSNull class]) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:result.profile_image_url]];
                UIImage *image1 = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.author_avatar.image = image1;
                });
            });
        }
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.packages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMOCategoryItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithItem:self.packages[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tag = indexPath.row;
    [self performSegueWithIdentifier:@"dev_item_detail_modal" sender:tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableView*)sender {
    if ([segue.identifier isEqualToString:@"dev_item_detail_modal"]) {
        IMOItemDetailViewController* controller = (IMOItemDetailViewController*)[(UINavigationController*)(segue.destinationViewController) topViewController];
        controller.item = self.packages[sender.tag];
        [controller setupNavigationBarItemsForSearchResult];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
