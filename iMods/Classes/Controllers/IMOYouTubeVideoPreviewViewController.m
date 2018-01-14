//
//  IMOViewPreviewViewController.m
//  iMods
//
//  Created by Ryan Feng on 11/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <XCDYouTubeVideoPlayerViewController.h>
#import <XCDYouTubeVideo.h>
#import <Promise.h>
#import <PromiseKit.h>
#import "IMOYouTubeVideoPreviewViewController.h"

@interface IMOYouTubeVideoPreviewViewController ()

@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController* playerViewController;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;

@end

@implementation IMOYouTubeVideoPreviewViewController

- (void) viewDidLoad {
    // Blur view
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    self.activityIndicator.color = [UIColor grayColor];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
    
    // Init video player
    self.playerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.youtubeVideoID];
    self.playerViewController.moviePlayer.backgroundView.backgroundColor = [UIColor clearColor];
    self.playButton.hidden = YES;
    
    
    // Register notifications
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(playerViewControllerDidReceiveVideo:) name:XCDYouTubeVideoPlayerViewControllerDidReceiveVideoNotification object:self.playerViewController];
    [notification addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.playerViewController.moviePlayer];
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void) playerViewControllerDidReceiveVideo:(NSNotification*) notification {
    XCDYouTubeVideo* video = notification.userInfo[XCDYouTubeVideoUserInfoKey];
    
    NSURL* thumbnailURL = video.mediumThumbnailURL ? video.mediumThumbnailURL : video.smallThumbnailURL;
    [NSURLConnection promise:[NSURLRequest requestWithURL:thumbnailURL]]
    .catch(^(NSError* error) {
        NSString *translationBundle = [[NSBundle mainBundle] pathForResource:@"Translations" ofType:@"bundle"];
        NSBundle *ourBundle = [[NSBundle alloc] initWithPath:translationBundle];
        NSString* msg = [NSLocalizedStringFromTableInBundle(@"Cannot load video:", nil, ourBundle, nil) stringByAppendingString:[NSString stringWithFormat:@" %@", error.localizedDescription]];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Error", nil, ourBundle, nil)
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, ourBundle, nil)
                                              otherButtonTitles:nil];
        [alert show];
        return error;
    })
    .then(^(UIImage* thumbnailImage) {
        self.thumbnailImageView.image = thumbnailImage;
        self.thumbnailImageView.userInteractionEnabled = YES;
        self.playButton.hidden = NO;
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        [self presentMoviePlayerViewControllerAnimated:self.playerViewController];
    })
    .finally(^{
    });
}

- (IBAction)playVideo:(id)sender {
    NSLog(@"Play video");
    [self presentMoviePlayerViewControllerAnimated:self.playerViewController];
}

- (void) playerPlaybackDidFinish:(NSNotification*)notification {
    [self didFinishViewing:self];
}

- (IBAction)didTapOnView:(id)sender {
    [self.playerViewController.moviePlayer stop];
    [self.playerViewController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didFinishViewing:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
