//
//  IMOCategoryChooser.m
//  iMods
//
//  Created by Marcus Ferrario on 12/25/15.
//  Copyright © 2015 Ryan Feng. All rights reserved.
//

#import "IMOCategoryChooser.h"
#import "UIColor+HTMLColors.h"
#import "IMOCategoryTabelViewCell.h"
#import "IMOCategory.h"
#import "IMOCategoryManager.h"

@interface IMOCategoryChooser ()
@property (nonatomic, strong) NSArray *categories;
@property (weak, nonatomic) IMOChartsViewController *globalRoot;
@property (nonatomic, strong) IMOCategoryManager *manager;
@property (nonatomic, strong) NSSet *disallowedCategories;
@property (nonatomic, strong) NSDictionary* categoryIcons;
@property (nonatomic, strong) UIImage* defaultCategoryIcon;
- (NSArray *)removeDisallowedCategories:(NSArray *)source;
@end

@implementation IMOCategoryChooser

@synthesize categories;
@synthesize manager;

- (void)initWithCharts:(IMOChartsViewController*)root {
    self.globalRoot = root;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.disallowedCategories = [NSSet setWithArray: @[@"Featured", @"Banner", @"Paid", @"Free", @"Tweaks", @"Themes", @"featured", @"New"]];
    
    self.categoryIcons = @{
                           @"Business": @"business",
                           @"Aesthetics": @"aesthetics",
                           @"Games": @"category-icon-functionality",
                           @"Performance": @"performance",
                           @"Entertainment": @"details-icon-video-preview",
                           @"Productivity": @"imods-assets-chart-icon-selected",
                           @"Functionality": @"imods-category-functionality",
                           @"Education": @"imods-category-education"
                           };
    self.defaultCategoryIcon = [UIImage imageNamed:@"category-icon-placeholder"];
    // Do any additional setup after loading the view.

    self.navBar.barTintColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.navBar.tintColor = [UIColor colorWithHexString:@"616E7B"];
    [self.navBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"616E7B"]}];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    self.view.tintColor = [UIColor colorWithHexString:@"E8E8E8"];

    [[self findHairlineImageViewUnder:self.navBar] setHidden:YES];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[IMOCategoryTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    //self.tableView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];

    UIImage *image = [UIImage imageNamed: @"update-bg.png"];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: image];
    self.tableView.rowHeight = 60.5;

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
        //sort by name
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }).catch(^(NSError *error) {
        NSLog(@"Error with HTTP request: %@", error.description);
    }).finally(^(void) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [categories count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.globalRoot setCategory:[categories[indexPath.row] objectForKey:@"name"]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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

- (NSArray *)removeDisallowedCategories:(NSArray *)source {
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *category in source) {
        if (![self.disallowedCategories containsObject:[category objectForKey:@"name"]]) {
            [result addObject:category];
        }
    }
    return result;
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

@end
