//
//  IMOChartsTableViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOChartsViewController.h"
#import "IMOItemDetailViewController.h"
#import "IMOItem.h"
#import "IMOItemManager.h"
#import <Overcoat/OVCResponse.h>

@interface IMOChartsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *topFreeButton;
@property (weak, nonatomic) IBOutlet UIButton *topPaidButton;
@property (weak, nonatomic) IBOutlet UIButton *topNewButton;
@property (strong, nonatomic) IMOItemManager *manager;
@property (strong, nonatomic) NSArray *items;
@property (assign, nonatomic) NSInteger selectedButtonIndex;

- (IBAction)topFreeButtonTapped:(UIButton *)sender;
- (IBAction)topPaidButtonTapped:(UIButton *)sender;
- (IBAction)topNewButtonTapped:(UIButton *)sender;
- (void)loadDataForCategory:(NSString *)category;

- (void)customizeNavigationBar;
- (void)resetNavigationBar;

- (NSString *)categoryForSelectedIndex;
@end

@implementation IMOChartsViewController

@synthesize selectedButtonIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.manager = [[IMOItemManager alloc] init];
    
    NSString *category = [self categoryForSelectedIndex];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"imods-assets-featured-tableview-background"]];
    
    self.tableView.backgroundView = imageView;

    [self loadDataForCategory: category];
}

- (void)viewWDidAppear:(BOOL)animated {
    [self customizeNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resetNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    IMOItem *item = [self.items objectAtIndex: indexPath.row];
    
    
    // TODO: Other cell setup
    cell.textLabel.text = item.display_name;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"charts_item_detail_push"]) {
        NSLog(@"Passing item: %@", self.items[[self.tableView indexPathForSelectedRow].row]);
        
        IMOItemDetailViewController *controller = [segue destinationViewController];
        controller.item = self.items[[self.tableView indexPathForSelectedRow].row];
    }
}


# pragma mark - Misc

- (IBAction)topFreeButtonTapped:(UIButton *)sender {
    self.selectedButtonIndex = 0;
    sender.selected = YES;
    
    self.topPaidButton.selected = NO;
    self.topNewButton.selected = NO;
    
    NSString *category = [self categoryForSelectedIndex];
    
    [self loadDataForCategory: category];
}

- (IBAction)topPaidButtonTapped:(UIButton *)sender {
    self.selectedButtonIndex = 1;
    sender.selected = YES;
    
    self.topFreeButton.selected = NO;
    self.topNewButton.selected = NO;
    
    NSString *category = [self categoryForSelectedIndex];
    
    [self loadDataForCategory: category];
}

- (IBAction)topNewButtonTapped:(UIButton *)sender {
    self.selectedButtonIndex = 2;
    sender.selected = YES;
    
    self.topFreeButton.selected = NO;
    self.topPaidButton.selected = NO;
    
    NSString *category = [self categoryForSelectedIndex];
    
    [self loadDataForCategory: category];
}

- (void)loadDataForCategory:(NSString *)category {
    [self.manager fetchItemsByCategory: category].then(^(NSArray *result) {
        self.items = result;
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
        self.items = @[];
    }).finally(^() {
        [self.tableView reloadData];
    });
}

- (void)customizeNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)resetNavigationBar {
    self.navigationController.navigationBar.translucent = NO;
}

- (NSString *)categoryForSelectedIndex {
    NSArray *categories = @[@"Free", @"Paid", @"New"];
    
    return categories[self.selectedButtonIndex];
}

- (IBAction)unwindToCharts:(UIStoryboardSegue *)segue {
    
}

@end
