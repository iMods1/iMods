//
//  IMOSearchViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/1/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOSearchViewController.h"
#import "IMOItemTableViewCell.h"
#import "IMOItemDetailViewController.h"
#import "IMOItemManager.h"
#import "IMODownloadManager.h"
#import "Promise.h"
#include "libimpkg.h"

@interface IMOSearchViewController ()
@property (assign) BOOL searchReady;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation IMOSearchViewController

TagFile indexFile;
std::vector<TagSection> searchResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    
    // Load the index file
#if TARGET_IPHONE_SIMULATOR
    NSString* indexFilePath = @"/tmp/Packages.gz";
#else
    NSString* indexFilePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingString:@"/"] stringByAppendingString: @"Packages.gz"];
#endif
    if(!indexFile.open([indexFilePath UTF8String], true)){
        self.searchReady = NO;
        IMODownloadManager* downloadManager = [IMODownloadManager sharedDownloadManager];
        [downloadManager downloadIndex]
        .then(^(NSString* filePath) {
            if(!indexFile.open([filePath UTF8String], true)){
                [self errorLoadingIndexFile];
            } else {
                self.searchReady = YES;
            }
        });
    } else {
        self.searchReady = YES;
    }
    
}

- (void) errorLoadingIndexFile {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Cannot download the index file, or the file was curupted. Search is not functioning."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    searchResult.clear();
    searchResult.shrink_to_fit();
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) searchAndShowResult:(NSString*)text {
    if (!self.searchReady) {
        return;
    }
    if (text.length <= 0) {
        return;
    }
    std::string searchText([text UTF8String]);
    FilterCondition pkgNameCond(std::make_pair("itemname", searchText), FilterCondition::TAG_A_MATCH_I);
    FilterCondition debPkgNameCond(std::make_pair("package", searchText), FilterCondition::TAG_A_MATCH_I);
    FilterCondition pkgSummaryCond(std::make_pair("summary", searchText), FilterCondition::TAG_A_MATCH_I);
    searchResult = std::move(indexFile.filter({pkgNameCond, debPkgNameCond, pkgSummaryCond}));
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    NSInteger index = indexPath.row;
    std::string pkgname, pkgsummary;
    searchResult[index].tag("itemname", pkgname);
    if(pkgname.empty()) {
        searchResult[index].tag("package", pkgname);
    }
    searchResult[index].tag("summary", pkgsummary);
    cell.textLabel.text = [NSString stringWithUTF8String:pkgname.c_str()];
    cell.detailTextLabel.text = [NSString stringWithUTF8String:pkgsummary.c_str()];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResult.size();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.tag = indexPath.row;
    [self performSegueWithIdentifier:@"search_item_detail_modal" sender:tableView];
}
#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchAndShowResult:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchAndShowResult:[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.navigationController.navigationBarHidden = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.navigationController.navigationBarHidden = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 0) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    // Result table view style
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableView*)sender {
    if ([segue.identifier isEqualToString:@"search_item_detail_modal"]) {
        IMOItemDetailViewController* vc = (IMOItemDetailViewController*)[(UINavigationController*)(segue.destinationViewController) topViewController];
        TagSection& tagsection = searchResult[sender.tag];
        std::string itemid_str;
        tagsection.tag("itemid", itemid_str);
        NSUInteger itemid = std::stoul(itemid_str);
        IMOItemManager* itemManager = [[IMOItemManager alloc] init];
        [itemManager fetchItemByID:itemid]
        .then(^(IMOItem* item) {
            [vc setupNavigationBarItemsForSearchResult:item.display_name];
            [vc setupItem:item];
        });
    }
}

- (IBAction)didTapOnView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end