//
//  IMOFeaturedViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/25/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOFeaturedViewController.h"
#import "IMOItemManager.h"
#import "IMOItem.h"
#import "IMOItemDetailViewController.h"
#import <Overcoat/OVCResponse.h>

@interface IMOFeaturedViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *themesButton;
@property (weak, nonatomic) IBOutlet UIButton *tweaksButton;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) IMOItemManager *manager;

- (IBAction)tweaksButtonWasTapped:(id)sender;
- (IBAction)themesButtonWasTapped:(id)sender;
- (void)setItemsForCategory:(NSString *)category;
@end

@implementation IMOFeaturedViewController

#pragma mark - UIViewController

-(void)viewDidLoad {
    UIImage *image = [UIImage imageNamed: @"imods-assets-featured-tableview-background.png"];
    self.manager = [[IMOItemManager alloc] init];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: image];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setItemsForCategory: @"Themes"];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
    }
    
    // Configure cell
    NSDictionary *item = [self.items objectAtIndex: indexPath.row];
    NSLog(@"Item at row %ld: %@", (long)indexPath.row, item);
    cell.textLabel.text = [item objectForKey:@"display_name"];
    cell.detailTextLabel.text = [item objectForKey:@"summary"];
    cell.backgroundColor = [UIColor clearColor];
    
    // TODO: Add price badge, add image downloaded from assets server
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"featured_item_detail_push"]) {
        // TODO: Retrieve item
        IMOItemDetailViewController *controller = [segue destinationViewController];
        controller.item = self.items[[self.tableView indexPathForSelectedRow].row];
    } else if ([segue.identifier isEqualToString: @"profile_push"]) {
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark - Misc

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
    [self.manager fetchItemsByCategory: category].then(^(OVCResponse *response) {
        NSLog(@"Result %@", response.result);
        if ([response.result isKindOfClass: [NSArray class]]) {
            self.items = response.result;
        } else {
            self.items = [NSArray arrayWithObject:response.result];
        }
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
        self.items = @[];
    }).finally(^() {
        [self.tableView reloadData];
    });

}

@end
