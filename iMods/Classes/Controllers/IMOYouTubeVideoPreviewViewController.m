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
#import <PromiseKit+Foundation.h>
#import "IMOYouTubeVideoPreviewViewController.h"

@interface IMOYouTubeVideoPreviewViewController ()

@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController* playerViewController;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation IMOYouTubeVideoPreviewViewController

- (void) viewDidLoad {
    // Blur view
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    
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
    .then(^(UIImage* thumbnailImage) {
        self.thumbnailImageView.image = thumbnailImage;
        self.thumbnailImageView.userInteractionEnabled = YES;
        self.playButton.hidden = NO;
    });
}

- (IBAction)playVideo:(id)sender {
    NSLog(@"Play video");
    [self presentMoviePlayerViewControllerAnimated:self.playerViewController];
}

- (void) playerPlaybackDidFinish:(NSNotification*)notification {
    
}

- (IBAction)didTapOnView:(id)sender {
    [self.playerViewController.moviePlayer stop];
    [self.playerViewController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
