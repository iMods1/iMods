//
//  IMOScreenShotViewController.m
//  iMods
//
//  Created by Ryan Feng on 11/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Promise.h>
#import <PromiseKit.h>
#import "IMOScreenShotViewController.h"
#import "IMOScreenShotContentViewController.h"
#import "IMODownloadManager.h"

@interface IMOScreenShotViewController ()

@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@end

@implementation IMOScreenShotViewController

- (IMOScreenShotContentViewController *) viewControllerAtIndex:(int)index {
    if (self.pagesCount == 0) {
        return nil;
    }
    else {
        IMOScreenShotContentViewController* contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScreenShotContentViewController"];
        contentVC.imageURL = [self.imageURLs objectAtIndex:index];
        contentVC.index = index;
        contentVC.delegate = self;
        return contentVC;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // TODO: UICollectionView
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    self.activityIndicator.color = [UIColor grayColor];
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];

    if (!self.assets) {
        IMODownloadManager* downloadManager = [IMODownloadManager sharedDownloadManager];
        [downloadManager download:Assets item:self.item]
        .then(^id(NSDictionary* assets){
            if (!assets) {
                return [NSError errorWithDomain:@"FailedToDownloadAssets" code:100 userInfo:nil];
            }
            NSArray* ssURLs = [assets valueForKey:@"screenshots"];
            self.imageURLs = [[NSMutableArray alloc] init];
            for (NSURL *url in ssURLs) {
                [NSURLConnection promise:[NSURLRequest requestWithURL:url]]
                .then(^(NSData* data) {
                    [self.imageURLs addObject:data];
                    if ([self.imageURLs count] == [ssURLs count]) {
                        if (self.imageURLs.count) {
                            self.pagesCount = self.imageURLs.count;
                            UIPageViewController *cntrl = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
                            cntrl.dataSource = self;
                            cntrl.delegate = self;
                            IMOScreenShotContentViewController *pcController = [self viewControllerAtIndex:0];
                            NSArray *viewControllers = @[pcController];
                            [cntrl setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:FALSE completion:nil];
                            self.view.backgroundColor = [UIColor clearColor];
                            cntrl.view.frame = self.view.frame;
                            cntrl.view.backgroundColor = [UIColor clearColor];
                            cntrl.view.autoresizingMask = self.view.autoresizingMask;
                            [self addChildViewController:cntrl];
                            [self.view addSubview:cntrl.view];
                            [cntrl didMoveToParentViewController:self];
                            // Add blur view
                            [self.activityIndicator stopAnimating];
                            [self.activityIndicator removeFromSuperview];
                        } else {
                            [self didFinishViewing:self];
                        }
                    }
                }).catch(^(){
                    [self didFinishViewing:self];
                    return nil;
                });
            }
            return nil;
        }).catch(^(){
            [self didFinishViewing:self];
            return nil;
        });
    } else {
        NSArray* ssURLs = [self.assets valueForKey:@"screenshots"];
        self.imageURLs = [[NSMutableArray alloc] init];
        for (NSURL *url in ssURLs) {
            [NSURLConnection promise:[NSURLRequest requestWithURL:url]]
            .then(^(NSData* data) {
                [self.imageURLs addObject:data];
                if ([self.imageURLs count] == [ssURLs count]) {
                    if (self.imageURLs.count) {
                        self.pagesCount = self.imageURLs.count;
                        UIPageViewController *cntrl = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
                        cntrl.dataSource = self;
                        cntrl.delegate = self;
                        IMOScreenShotContentViewController *pcController = [self viewControllerAtIndex:0];
                        NSArray *viewControllers = @[pcController];
                        [cntrl setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:FALSE completion:nil];
                        self.view.backgroundColor = [UIColor clearColor];
                        cntrl.view.frame = self.view.frame;
                        cntrl.view.backgroundColor = [UIColor clearColor];
                        cntrl.view.autoresizingMask = self.view.autoresizingMask;
                        [self addChildViewController:cntrl];
                        [self.view addSubview:cntrl.view];
                        [cntrl didMoveToParentViewController:self];
                        // Add blur view
                        [self.activityIndicator stopAnimating];
                        [self.activityIndicator removeFromSuperview];
                    } else {
                        [self didFinishViewing:self];
                    }
                }
            });
        }
        if ([ssURLs count] == 0) {
            [self didFinishViewing:self];
        }
    }
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

#pragma mark -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    IMOScreenShotContentViewController *pController = (IMOScreenShotContentViewController *)viewController;
    NSUInteger index = pController.index;
    if (index == 0) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    IMOScreenShotContentViewController *pController = (IMOScreenShotContentViewController *)viewController;
    NSUInteger index = pController.index;
    index++;
    if (index == self.pagesCount) {
        return nil;
    }
    else {
        return [self viewControllerAtIndex:index];
    }
}

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.pagesCount;
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (void) didFinishViewing:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
