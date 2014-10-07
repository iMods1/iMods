//
//  IMOCategoriesController.m
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCategoriesController.h"
#import "IMOCategoriesDetailTableViewController.h"
#import "IMOCategory.h"
#import "IMOCategoryManager.h"

@interface IMOCategoriesController ()
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) IMOCategoryManager *manager;
@property (nonatomic, strong) NSSet *disallowedCategories;

- (NSArray *)removeDisallowedCategories:(NSArray *)source;
@end

@implementation IMOCategoriesController

@synthesize categories;
@synthesize manager;

- (void)viewDidLoad {
    self.disallowedCategories = [NSSet setWithArray: @[@"Featured", @"Banner", @"Paid", @"Free", @"Tweaks", @"Themes", @"featured"]];
    [super viewDidLoad];
    
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    
    self.manager = [[IMOCategoryManager alloc] init];
    
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    indicator.center = self.view.center;
    
    [self.view addSubview: indicator];
    
    [indicator startAnimating];
    
    NSLog(@"Sending HTTP request for category data");
    [self.manager fetchCategories].then(^(OVCResponse *response) {
        if ([response.result isKindOfClass: [NSArray class]]) {
            self.categories = [self removeDisallowedCategories: response.result];
        } else {
            self.categories = [self removeDisallowedCategories:[NSArray arrayWithObject:response.result]];
        }
        [self.categoriesTableView reloadData];
    }).catch(^(NSError *error) {
        NSLog(@"Error with HTTP request: %@", error.description);
    }).finally(^(void) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.categories = nil;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Verify that the category is still valid
    if (indexPath.row < [categories count]) {
        NSDictionary *category = categories[indexPath.row];
        
        cell.textLabel.text = [category objectForKey:@"name"];
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqual:@"categories_categories_detail_push"]) {
        // TODO: Pass selected category information to the destination
        IMOCategoriesDetailTableViewController *detailController = [segue destinationViewController];
        detailController.category = [self.categories[[self.categoriesTableView indexPathForSelectedRow].row] objectForKey: @"name"];
    }
}

#pragma mark - Misc

- (NSArray *)removeDisallowedCategories:(NSArray *)source {
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *category in source) {
        if (![self.disallowedCategories containsObject:[category objectForKey:@"name"]]) {
            [result addObject:category];
        }
    }
    return result;
}
@end
