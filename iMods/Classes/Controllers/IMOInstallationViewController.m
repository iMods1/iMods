//
//  IMOInstallationViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOInstallationViewController.h"
#import "IMOItemDetailViewController.h"
#import "IMOTask.h"
#import "IMODownloadManager.h"
#import "IMOSessionManager.h"
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@interface IMOInstallationViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
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

IMOSessionManager* sessionManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create timer for progress
    // self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.5f target: self selector:@selector(advanceProgressView) userInfo:nil repeats: YES];
    
    sessionManager = [IMOSessionManager sharedSessionManager];
    
    // Create a new NSPipe for taskOutput.
    self.pipe = [NSPipe pipe];
    
    // Set up progressView traits
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.thicknessRatio = 0.1f;
    self.progressView.progressTintColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.5 alpha:1.0];
    self.textView.editable = NO;
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

- (void) appendTextToTextView:(NSString*) text {
    NSString* str = [self.textView.text stringByAppendingString:text];
    self.textView.text = [str stringByAppendingString:@"\n"];
}

- (void)launchTaskWithOptions:(NSDictionary *)options {
    // Get the task from the delegate, set standardOutput to taskOutput
    // TODO: Make exensible with options that are configurable via public properties on Controller
    
#if TARGET_IPHONE_SIMULATOR
    // Don't launch task on simulator
    return;
#elif TARGET_OS_IPHONE
    [self appendTextToTextView:@"Initializing..."];
    [self.progressView setProgress:0.1 animated:YES];
    // Try lock dpkg
    BOOL locked = [sessionManager.packageManager lockDPKG];
    if (!locked) {
        [self appendTextToTextView:@"Unable to lock dpkg, it's probably used by another app, such as Cydia."];
        return;
    }
    
    IMODownloadManager *dlManager = [IMODownloadManager sharedDownloadManager];
    IMOItemDetailViewController* itemController = (IMOItemDetailViewController*)(self.delegate);
    
    [self appendTextToTextView:@"Downloading package file..."];
    [self.progressView setProgress:0.3 animated:YES];
    [dlManager download:Deb item:itemController.item].then(^(NSString* debFile){
        [self appendTextToTextView: [NSString stringWithFormat:@"Download finished.\nStarting dpkg installation for %@", debFile]];
        [self.progressView setProgress: 0.6 animated:YES];
        IMODPKGManager* dpkg = [[IMODPKGManager alloc] initWithDPKGPath:@"/usr/bin/dpkg"];
        [dpkg installDEB:debFile].then(^(IMOTask* task){
            NSLog(@"Task: %@", task);
            [self appendTextToTextView:task.outputStringFromStandardOutputUTF8];
            [self appendTextToTextView:task.errorOutputStringFromStandardErrorUTF8];
            [self appendTextToTextView:@"dpkg installation exited."];
            [self appendTextToTextView:@"Done."];
            [self.progressView setProgress:1.0 animated:YES];
            double delayInSeconds = 2.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.delegate installationDidFinish:self];
            });
        }).catch(^(NSError *error){
            NSDictionary* info = error.userInfo;
            [self appendTextToTextView: [info valueForKey:@"stdout"]];
            [self appendTextToTextView: [info valueForKey:@"stderr"]];
            [self appendTextToTextView: [NSString stringWithFormat: @"Error: %@", error.localizedDescription]];
            [self.progressView setProgress:0.0 animated:YES];
        });
    }).finally(^{
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
