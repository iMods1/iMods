//
//  IMOChartsTableViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

//TODO: add cache
#import "IMOChartsViewController.h"
#import "IMOItemDetailViewController.h"
#import "IMOItemExtensionTableViewCell.h"
#import "IMOCategoryChooser.h"
#import "IMOItem.h"
#import "IMOItemManager.h"
#import "IMOSessionManager.h"
#import <Overcoat/OVCResponse.h>
#import "UIColor+HTMLColors.h"

@interface IMOChartsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *topFreeButton;
@property (weak, nonatomic) IBOutlet UIButton *topPaidButton;
@property (weak, nonatomic) IBOutlet UIButton *topNewButton;
@property (strong, nonatomic) IMOItemManager *manager;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *freeItems;
@property (strong, nonatomic) NSArray *paidItems;
@property (strong, nonatomic) NSArray *newedItems;
@property (assign, nonatomic) NSInteger selectedButtonIndex;
@property (nonatomic) BOOL firstLoad;
@property (weak) IMOSessionManager* sessionManager;

- (IBAction)topFreeButtonTapped:(UIButton *)sender;
- (IBAction)topPaidButtonTapped:(UIButton *)sender;
- (IBAction)topNewButtonTapped:(UIButton *)sender;
- (PMKPromise*)loadDataForCategory:(NSString *)category;

- (void)customizeNavigationBar;
- (void)resetNavigationBar;

- (NSString *)categoryForSelectedIndex;
@end

@implementation IMOChartsViewController

@synthesize selectedButtonIndex;

- (void) setCategory:(NSString *)category {
    self.navigationController.navigationBar.topItem.title = category;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-140, self.view.frame.size.width, 27)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.alpha = 0.8;
    imageView.image = [UIImage imageNamed: @"tabbar-shadow.png"]; //tabbar-shadow.png
    [self.view addSubview: imageView];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"616E7B"];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"616E7B"]}];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.view.tintColor = [UIColor colorWithHexString:@"E8E8E8"];

    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"6D7984"];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithHexString:@"868F99"];
    self.sessionManager = [IMOSessionManager sharedSessionManager];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[self findHairlineImageViewUnder:self.navigationController.navigationBar] setHidden:YES];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.5;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    self.manager = [[IMOItemManager alloc] init];
    
    NSString *category = [self categoryForSelectedIndex];

    [self.tableView registerClass:IMOItemExtensionTableViewCell.class forCellReuseIdentifier:@"Cell"];

    if (!self.firstLoad) {
        self.selectedButtonIndex = 0;
        self.topFreeButton.selected = YES;
        self.topPaidButton.selected = NO;
        self.topNewButton.selected = NO;
        self.topFreeButton.tintColor = [UIColor colorWithHexString:@"5F6E79"];
        self.topPaidButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
        self.topNewButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
        self.firstLoad = YES;
    }
    
    [self loadDataForCategory: category].then(^() {
        self.freeItems = self.items;
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [self setCategory:@"Top Charts"];
    [self customizeNavigationBar];
    [self.sessionManager.userManager refreshUpdates].then(^ (NSMutableArray *updatedItems) {
        if ([updatedItems count] == 0) {
            [self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)].alpha = 0;
        } else {
            [self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)].alpha = 1;
            [[self.tabBarController.tabBar.subviews objectAtIndex:([self.tabBarController.tabBar.subviews count]-1)] setText:[NSString stringWithFormat:@"%ld", (unsigned long)[updatedItems count]]];
        }
    });
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
    IMOItemExtensionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[IMOItemExtensionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    IMOItem *item = [self.items objectAtIndex: indexPath.row];
    
    [cell configureWithItem:item];
    
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
    } else if ([segue.identifier isEqualToString:@"categories_view_modal"]) {
        IMOCategoryChooser *controller = [segue destinationViewController];
        [controller initWithCharts:self];
    }
     self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}


# pragma mark - Misc

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

- (IBAction)topFreeButtonTapped:(UIButton *)sender {
    self.selectedButtonIndex = 0;
    sender.selected = YES;
    sender.tintColor = [UIColor colorWithHexString:@"5F6E79"];
    
    self.topPaidButton.selected = NO;
    self.topNewButton.selected = NO;
    self.topPaidButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
    self.topNewButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
    
    NSString *category = [self categoryForSelectedIndex];
    self.items = self.freeItems;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    [self loadDataForCategory: category].then(^() {
        self.freeItems = self.items;
    });
}

- (IBAction)topPaidButtonTapped:(UIButton *)sender {
    self.selectedButtonIndex = 1;
    sender.selected = YES;
    sender.tintColor = [UIColor colorWithHexString:@"5F6E79"];
    
    self.topFreeButton.selected = NO;
    self.topNewButton.selected = NO;
    self.topFreeButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
    self.topNewButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
    
    NSString *category = [self categoryForSelectedIndex];
    self.items = self.paidItems;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    [self loadDataForCategory: category].then(^() {
        self.paidItems = self.items;
    });
}

- (IBAction)topNewButtonTapped:(UIButton *)sender {
    self.selectedButtonIndex = 2;
    sender.selected = YES;
    sender.tintColor = [UIColor colorWithHexString:@"5F6E79"];
    
    self.topFreeButton.selected = NO;
    self.topPaidButton.selected = NO;
    self.topFreeButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
    self.topPaidButton.tintColor = [UIColor colorWithHexString:@"A8B1BB"];
    
    NSString *category = [self categoryForSelectedIndex];
    self.items = self.newedItems;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    [self loadDataForCategory: category].then(^() {
        self.newedItems = self.items;
    });
}

- (PMKPromise*)loadDataForCategory:(NSString *)category {
    return [self.manager fetchItemsByCategory: category].then(^(NSArray *result) {
        self.items = result;
    }).catch(^(NSError *error) {
        NSLog(@"Problem with HTTP request: %@", [error localizedDescription]);
        self.items = @[];
    }).finally(^() {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

- (void)customizeNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"616E7B"];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"616E7B"]}];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.view.tintColor = [UIColor colorWithHexString:@"E8E8E8"];

    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"6D7984"];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithHexString:@"868F99"];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"charts_item_detail_push" sender:self];
}

@end
