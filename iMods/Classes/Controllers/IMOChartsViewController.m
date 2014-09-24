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
@property (weak, nonatomic) IBOutlet UISegmentedControl *topChartsSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IMOItemManager *manager;
@property NSArray *items;

- (void)loadDataForCategory:(NSString *)category;
@end

@implementation IMOChartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.manager = [[IMOItemManager alloc] init];
    
    NSString *category = [self.topChartsSegmentedControl titleForSegmentAtIndex: self.topChartsSegmentedControl.selectedSegmentIndex];
    
    [self loadDataForCategory: category];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *item = [self.items objectAtIndex: indexPath.row];
    
    
    // TODO: Other cell setup
    cell.textLabel.text = [item objectForKey: @"display_name"];
    
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

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    NSString *category = [sender titleForSegmentAtIndex: sender.selectedSegmentIndex];
    
    [self loadDataForCategory: category];
}

- (void)loadDataForCategory:(NSString *)category {
    [self.manager fetchItemsByCategory: category].then(^(OVCResponse *response) {
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

- (IBAction)unwindToCharts:(UIStoryboardSegue *)segue {
    
}

@end
