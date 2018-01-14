//
//  IMOWishlistViewController.m
//  iMods
//
//  Created by Marcus Ferrario on 8/9/15.
//  Copyright © 2015 Ryan Feng. All rights reserved.
//

#import "IMOWishlistViewController.h"
#import "IMOWishlistTableViewCell.h"
#import "IMOWishlistManager.h"
#import "IMOUserManager.h"
#import "IMOItemDetailViewController.h"
#import "UIColor+HTMLColors.h"

@interface IMOWishlistViewController ()
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *titleText;

    @property (strong, nonatomic) IMOWishListManager *wishlistManager;
    @property (strong, nonatomic) IMOUserManager *userManager;
    @property (nonatomic, strong) NSArray *wishes;
@end

@implementation IMOWishlistViewController

- (void)viewDidLoad {
    self.titleText.textColor = [UIColor colorWithHexString:@"6D7B88"];
    self.iconButton.imageView.tintColor = [UIColor colorWithHexString:@"6D7B88"];

    [super viewDidLoad];
    self.userManager = [IMOUserManager sharedUserManager];
    self.wishlistManager = [[IMOWishListManager alloc] init];
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.wishlistTableView.delegate = self;
    self.wishlistTableView.dataSource = self;
    self.wishlistTableView.rowHeight = 45;
    
    [self.wishlistTableView registerClass:[IMOWishlistTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.wishlistTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.wishlistTableView.backgroundColor = [UIColor clearColor];
    self.wishlistTableView.opaque = NO;
    
    [self.wishlistManager refreshWishList].then(^() {
        self.wishes = self.userManager.userProfile.wishlist;
    }).catch(^(NSError *error) {
        NSLog(@"Problem refreshing Wishlist: %@", [error localizedDescription]);
        self.wishes = @[];
    }).finally(^() {
        [self.wishlistTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

/*- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"%@", recognizer.view);
    if (recognizer.state == UIGestureRecognizerStateEnded){
        //code here
        NSLog(@"subview touched");
    }
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.wishes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMOWishlistTableViewCell *cell = [self.wishlistTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithItem:self.wishes[indexPath.row] forIndex:indexPath withViewController:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"details_push_wishlist" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"details_push_wishlist"]) {
        IMOItemDetailViewController *controller = (IMOItemDetailViewController*)[(UINavigationController*)(segue.destinationViewController) topViewController];
        controller.item = self.wishes[[self.wishlistTableView indexPathForSelectedRow].row];
        [controller setupNavigationBarItemsForSearchResult];
    }
}

- (void)removeItemFromWishlist:(UIButton*)sender {
    [self.wishlistManager removeItemFromWishListByItem:self.wishes[sender.tag]].then(^() {
        return [self.wishlistManager refreshWishList];
    }).then(^() {
        self.wishes = self.userManager.userProfile.wishlist;
    }).catch(^(NSError *error) {
        NSLog(@"Problem refreshing Wishlist: %@", [error localizedDescription]);
        self.wishes = @[];
    }).finally(^() {
        [self.wishlistTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapIconButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
