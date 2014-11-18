//
//  IMOScreenShotViewController.m
//  iMods
//
//  Created by Ryan Feng on 11/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Promise.h>
#import "IMOScreenShotViewController.h"
#import "IMOScreenShotContentViewController.h"
#import "IMODownloadManager.h"

@interface IMOScreenShotViewController ()

@property (strong, nonatomic) UIPageViewController* pageViewController;
@property (strong, nonatomic) NSMutableArray* pages;

@end

@implementation IMOScreenShotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScreenShotPageViewController"];
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.view.backgroundColor = [UIColor clearColor];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    // Add page view
    self.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add blur view
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    
    self.pages = [[NSMutableArray alloc] init];
    
    // Download screenshots
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    
    [indicator startAnimating];
    IMODownloadManager* downloadManager = [IMODownloadManager sharedDownloadManager];
    [downloadManager download:Assets item:self.item]
    .then(^id(NSDictionary* assets){
        if (!assets) {
            return [NSError errorWithDomain:@"FailedToDownloadAssets" code:100 userInfo:nil];
        }
        NSArray* ssURLs = [assets valueForKey:@"screenshots"];
        for(NSURL* url in ssURLs) {
            IMOScreenShotContentViewController* contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScreenShotContentViewController"];
            contentVC.imageURL = url;
            contentVC.index = self.pages.count;
            contentVC.delegate = self;
            [self.pages addObject:contentVC];
        }
        if (self.pages.count) {
            [self.pageViewController setViewControllers:self.pages
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
        } else {
            [self didFinishViewing:self];
        }
        return nil;
    })
    .catch(^{
        [self didFinishViewing:self];
    })
    .finally(^{
        [indicator stopAnimating];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
}

#pragma mark -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = ((IMOScreenShotContentViewController*) viewController).index;
    if (index <= 0 || index >= self.pages.count-1) {
        return nil;
    }
    return [self.pages objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = ((IMOScreenShotContentViewController*) viewController).index;
    if (index <= 0 || index >= self.pages.count-1) {
        return nil;
    }
    return [self.pages objectAtIndex:index];
}

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.pages.count;
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (void) didFinishViewing:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
