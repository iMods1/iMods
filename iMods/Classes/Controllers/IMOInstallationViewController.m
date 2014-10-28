//
//  IMOInstallationViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOInstallationViewController.h"
#import "IMOTask.h"
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@interface IMOInstallationViewController ()
@property (strong, nonatomic) NSPipe *pipe;
@property (strong, nonatomic) NSFileHandle *handle;
@property (strong, nonatomic) NSTimer *timer;

- (void)launchTaskWithOptions:(NSDictionary *)options;
- (void)handleTaskNotification:(NSNotification *)notification;
- (void)handleTaskFinishedNotification:(NSNotification *)notification;
- (void)advanceProgressView;
- (IBAction)didTapOnView:(id)sender;
@end

@implementation IMOInstallationViewController

@synthesize progressView = _progressView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create timer for progress
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.5f target: self selector:@selector(advanceProgressView) userInfo:nil repeats: YES];
    
    // Create a new NSPipe for taskOutput.
    self.pipe = [NSPipe pipe];
    
    // Set up progressView traits
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.thicknessRatio = 0.1f;
    self.progressView.progressTintColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.5 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self launchTaskWithOptions:nil];
    
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

- (void)launchTaskWithOptions:(NSDictionary *)options {
    // Get the task from the delegate, set standardOutput to taskOutput
    // TODO: Make exensible with options that are configurable via public properties on Controller
    
#if TARGET_IPHONE_SIMULATOR
    // Don't launch task on simulator
    return;
#elif TARGET_OS_IPHONE
    __weak IMOInstallationViewController *weakSelf = self;
    [IMOTask launchTask:@"/bin/bash" arguments:@[@"-c", @"sleep 3; echo \"Step 1\";sleep 3;echo \"Step 2\";sleep 3;echo \"Done\""]].then(^{
        [self.progressView setProgress: 1.0 animated:YES];
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [weakSelf.delegate installationDidFinish:weakSelf];
        });
    }).catch(^(NSError *error){
        NSLog(@"Error with task: %@", error.localizedDescription);
    });
#else
#endif

}

- (void)handleTaskNotification:(NSNotification *)notification {
    NSLog(@"Handling Task Notification");
    NSData *data = nil;
    while ((data = [self.handle availableData]) && [data length]) {
        // TODO: Parse output and update progressView appropriately
        NSLog(@"Task data: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    }
}

- (void)handleTaskFinishedNotification:(NSNotification *)notification {
}

- (void)advanceProgressView {
    if (self.progressView.progress < 0.9) {
        // Generate float between 0.0 and 0.5
        CGFloat amount = ((CGFloat)rand() / RAND_MAX) * 0.25f;
        [self.progressView setProgress:MIN(self.progressView.progress + amount, 0.91) animated:YES] ;
    } else {
        // Invalidate timer
        [self.timer invalidate];
        self.timer = nil;
#if TARGET_IPHONE_SIMULATOR
        // FIX: This is not how it should work, temporary logic for demo
        __weak IMOInstallationViewController *weakSelf = self;
        [self.progressView setProgress: 1.0 animated:YES];
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [weakSelf.delegate installationDidFinish:weakSelf];
        });
#elif TARGET_OS_IPHONE
#else
#endif
    }
}

- (IBAction)didTapOnView:(id)sender {
    [self.delegate installationDidDismiss:self];
}

@end
