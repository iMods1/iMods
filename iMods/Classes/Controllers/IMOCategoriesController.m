//
//  IMOCategoriesController.m
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCategoriesController.h"
#import "IMOCategoriesDetailTableViewController.h"
#import "IMOCategoryTabelViewCell.h"
#import "IMOCategory.h"
#import "IMOCategoryManager.h"
#import "UIColor+HTMLColors.h"

@interface IMOCategoriesController ()
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) IMOCategoryManager *manager;
@property (nonatomic, strong) NSSet *disallowedCategories;
@property (nonatomic, strong) NSDictionary* categoryIcons;
@property (nonatomic, strong) UIImage* defaultCategoryIcon;
@property (nonatomic, weak) IBOutlet UIButton* topCategoryIconButton;
@property (weak, nonatomic) IBOutlet UILabel *topCategoriesLabel;

- (NSArray *)removeDisallowedCategories:(NSArray *)source;
@end

@implementation IMOCategoriesController

@synthesize categories;
@synthesize manager;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.disallowedCategories = [NSSet setWithArray: @[@"Featured", @"Banner", @"Paid", @"Free", @"Tweaks", @"Themes", @"featured"]];
    
    self.categoryIcons = @{
                           @"Business": @"category-icon-business",
                           @"Aesthetics": @"category-icon-aesthetics",
                           @"Functionality": @"category-icon-functionality",
                           @"Performance": @"category-icon-performance"
                           };
    self.defaultCategoryIcon = [UIImage imageNamed:@"category-icon-placeholder"];
    
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    
    [self.categoriesTableView registerClass:[IMOCategoryTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.categoriesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    // Blurry background, only works on >= iOS 8.0
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    self.categoriesTableView.backgroundColor = [UIColor clearColor];
    self.categoriesTableView.opaque = NO;
    
    self.topCategoriesLabel.textColor = [UIColor colorWithHexString:@"9f9f9f"];
    
    // Fetch categories
    
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
    IMOCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Verify that the category is still valid
    if (indexPath.row < [categories count]) {
        NSDictionary *category = categories[indexPath.row];
        
        NSString* categoryName = [category objectForKey:@"name"];
        cell.textLabel.text = categoryName;
        NSString* iconName = [self.categoryIcons valueForKey:categoryName];
        if (iconName) {
            cell.imageView.image = [UIImage imageNamed:iconName];
        } else {
            cell.imageView.image = self.defaultCategoryIcon;
        }
        cell.category = category;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"category_items_push" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqual:@"category_items_push"]) {
        // TODO: Pass selected category information to the destination
        IMOCategoryTableViewCell* cell = (IMOCategoryTableViewCell*)[self.categoriesTableView cellForRowAtIndexPath:[self.categoriesTableView indexPathForSelectedRow]];
        IMOCategoriesDetailTableViewController* detailController = segue.destinationViewController;
        detailController.category = [self.categories[[self.categoriesTableView indexPathForSelectedRow].row] objectForKey: @"name"];
        detailController.categoryIcon = cell.imageView.image;
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
- (IBAction)didTapIconButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
