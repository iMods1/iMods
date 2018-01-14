//
//  IMOSearchViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/1/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "IMOSearchViewController.h"
#import "IMOItemExtensionTableViewCell.h"
#import "IMOItemDetailViewController.h"
#import "IMOItemManager.h"
#import "IMODownloadManager.h"
#import "Promise.h"
#import "UIColor+HTMLColors.h"

@interface IMOSearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) UIViewController *globalRoot;
@property (weak, nonatomic) UIColor *globalColor;
@property (nonatomic, retain) NSArray *searchResult;
@end

@implementation IMOSearchViewController
@synthesize searchResult;

static IMOItemManager* itemManager = nil;
- (void) initWithController:(UIViewController*)root {
    self.globalRoot = root;
}

- (void) initWithColor:(UIColor *)color {
    self.globalColor = color;
    UIImage *img = [self changeImage:[UIImage imageNamed:@"UITextFieldClearButton.png"] toColor:color];
    [self.searchBar setImage:img forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted]; //Perhaps a darker tint or different color?
    [self.searchBar setImage:img forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    dispatch_async(dispatch_get_main_queue(), ^() {
        ((UIView *)[self.searchBar.subviews objectAtIndex:0]).tintColor = color;
        [(UITextField *)[[self.searchBar.subviews objectAtIndex:0].subviews objectAtIndex:1] setTextColor:color];
        [self.searchBar setValue:color forKeyPath:@"_searchField._placeholderLabel.textColor"];
    });
    UIImage *image = [UIImage imageNamed:@"imods-assets-search-icon"];
    UIImage *searchIcon = [[UIImage imageNamed:@"imods-assets-search-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, searchIcon.scale);
    [color set];
    [searchIcon drawInRect:CGRectMake(0, 0, image.size.width, searchIcon.size.height)];
    searchIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.searchBar setImage:searchIcon
        forSearchBarIcon:UISearchBarIconSearch
        state:UIControlStateNormal];
}

-(void)onKeyboardHide:(NSNotification *)notification {
    if (self.searchBar.text.length <= 0) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

-(void)onKeyboardDisplay:(NSNotification *)notification {
    [self initWithColor:self.globalColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithColor:self.globalColor];
    sBarHairlineImageView = [self findHairlineImageViewUnder:self.searchBar];
    itemManager = [[IMOItemManager alloc] init];
    self.view.backgroundColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDisplay:) name:UIKeyboardWillShowNotification object:nil];
    
    [self.searchBar setFrame:CGRectMake(0,-50,self.searchBar.bounds.size.width,50)];
    
    UIVisualEffect* blurEffects = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView* blurViews = [[UIVisualEffectView alloc] initWithEffect:blurEffects];
    blurViews.alpha = 0.95f;
    blurViews.frame = CGRectMake(0,-50,[UIScreen mainScreen].bounds.size.width,self.searchBar.bounds.size.height+13);
    [self.view insertSubview:blurViews atIndex:0];
    [self.searchBar setImage:[UIImage imageNamed:@"imods-assets-search-icon"]
                forSearchBarIcon:UISearchBarIconSearch
              state:UIControlStateNormal];
    [[[self.searchBar.subviews objectAtIndex:0].subviews objectAtIndex:1].subviews objectAtIndex:0].alpha = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    sBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    sBarHairlineImageView.hidden = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) searchAndShowResult:(NSString*)text {
    if (text.length <= 0) {
        return;
    }
    [itemManager fetchItemBySearchTerm:text].then(^(NSArray *results) {
        self.searchResult = results;
    }).finally(^() {
        self.searchBar.text = self.searchBar.text;
    });
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMOItemExtensionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[IMOItemExtensionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    IMOItem *item = [self.searchResult objectAtIndex: indexPath.row];
    
    [cell configureWithItem:item];
    cell.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    
    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.view.subviews objectAtIndex:0].frame  = CGRectMake(0,0,[self.view.subviews objectAtIndex:0].bounds.size.width,self.searchBar.bounds.size.height+13);
    } completion:^(BOOL finishedxr) {
        [self.searchBar becomeFirstResponder]; 
        [self initWithColor:self.globalColor];
    }];
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.searchBar.frame  = CGRectMake(0,20,self.searchBar.bounds.size.width,50);
    } completion:^(BOOL finished) {
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResult count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tag = indexPath.row;
    [self performSegueWithIdentifier:@"search_item_detail_modal" sender:tableView];
}
#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchAndShowResult:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchAndShowResult:[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    UIView* blurView = [[UIView alloc] init];
    blurView.alpha = 0.40f;
    blurView.frame = self.view.bounds;
    blurView.backgroundColor = [UIColor colorWithHexString:@"000000"];
    [controller.searchResultsTableView insertSubview:blurView atIndex:0];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.searchBar.showsCancelButton = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 0) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.rowHeight = 60.5;
    [tableView registerClass:[IMOItemExtensionTableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableView*)sender {
    if ([segue.identifier isEqualToString:@"search_item_detail_modal"]) {
        IMOItemDetailViewController* vc = (IMOItemDetailViewController*)[(UINavigationController*)(segue.destinationViewController) topViewController];
        vc.item = self.searchResult[sender.tag];
        [vc setupNavigationBarItemsForSearchResult];
    }
}

- (IBAction)didTapOnView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (UIImage *) changeImage: (UIImage *)image toColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImg;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
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

@end