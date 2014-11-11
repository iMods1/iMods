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
#import "UIColor+HTMLColors.h"
#import "FXBlurView.h"
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@interface IMOInstallationViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton* dismissButton;
@property (weak, nonatomic) IBOutlet UILabel* installationLabel;
@property (strong, nonatomic) NSPipe *pipe;
@property (strong, nonatomic) NSFileHandle *handle;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UITapGestureRecognizer* tapGestureRecognizer;

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
    
    sessionManager = [IMOSessionManager sharedSessionManager];
    
    // Create timer for progress
    // self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.5f target: self selector:@selector(advanceProgressView) userInfo:nil repeats: YES];
    
    // Create a new NSPipe for taskOutput.
    self.pipe = [NSPipe pipe];
    
    // Set up progressView traits
    self.progressView.lineWidth = 10.0f;
    UIImage* gradient = [UIImage imageNamed:@"gradientColor"];
    UIColor* gradientColor = [UIColor colorWithPatternImage:gradient];
    self.progressView.tintColor = gradientColor;
//    self.progressView.tintColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.5 alpha:1.0];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.valueLabel.font = [self.progressView.valueLabel.font fontWithSize:35.0];
    self.dismissButton.backgroundColor = [UIColor clearColor];
    [self.dismissButton setTitleColor: [UIColor colorWithHexString:@"#9f9f9f"]
                             forState:UIControlStateNormal];
    self.dismissButton.tag = 0xFFEE; // A random tag to distinguish it from other views
    self.installationLabel.backgroundColor = [UIColor clearColor];
    [self.installationLabel setTextColor:gradientColor];
    self.textView.editable = NO;
    self.textView.opaque = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setHidden:YES];
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7 doesn't support UIVisualEffectView, here's a workaround
        UIToolbar* blurView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        blurView.autoresizingMask = self.view.autoresizingMask;
        self.view.opaque = NO;
        self.view.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:blurView atIndex:0];
    } else {
//        FXBlurView* blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
        self.view.backgroundColor = [UIColor clearColor];
        UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        blurView.backgroundColor = [[UIColor colorWithHexString:@"#e4e4e4"] colorWithAlphaComponent:0.7];
        blurView.frame = self.view.frame;
        blurView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view insertSubview:blurView atIndex:0];
    }
}

- (void)updateDismissLabelVisibility {
    [self.dismissButton setHidden:self.status == Running];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self launchTaskWithOptions:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)redirectPipeContentToTextView:(NSPipe*)pipe {
    NSFileHandle* pipeReadHandle = [pipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandler:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle];
    [pipeReadHandle readInBackgroundAndNotify];
}

- (void)redirectNotificationHandler:(NSNotification*)notification {
    NSData* data = [notification.userInfo objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self appendTextToTextView:str];
    [notification.object readInBackgroundAndNotify];
}

- (void)redirectRemainingContentToTextView:(NSPipe*)pipe {
    NSFileHandle* pipeReadHandle = [pipe fileHandleForReading];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectEndNotificationHandler:)
                                                 name:NSFileHandleReadToEndOfFileCompletionNotification
                                               object:pipeReadHandle];
    [pipeReadHandle readToEndOfFileInBackgroundAndNotify];
}

- (void)redirectEndNotificationHandler:(NSNotification*)notification {
    NSData* data = [notification.userInfo objectForKey:NSFileHandleNotificationDataItem];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self appendTextToTextView:str];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadToEndOfFileCompletionNotification
                                                  object:notification.object];
    
}

- (void)removePipeRedirct:(NSPipe*)pipe {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadCompletionNotification
                                                  object:[pipe fileHandleForReading]];
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
    self.textView.text = str;
    NSRange range;
    range.location = [self.textView.text length] - 1;
    range.length = 0;
    // Scroll visible area to the end of the output
    [self.textView scrollRangeToVisible:range];
}

- (void)launchTaskWithOptions:(NSDictionary *)options {
    // Get the task from the delegate, set standardOutput to taskOutput
    // TODO: Make exensible with options that are configurable via public properties on Controller
    
#if TARGET_IPHONE_SIMULATOR
    // Don't launch task on simulator
    self.status = FinishedSuccessfully;
    [self.textView setText:@"oiasjdoiajdoaijdoiasdoaisdjaoasoidjaoidjoij\naosidjaidjaodjaodiasdoahidaosidha\nsajdoasidjaosijsoaidjasodjasd\noaisdjaosdjaoidjaosidjoasidoasidoiasdja\naosidjoasidoadjoasidjasiodjaosidjaosidjaoisdjoai\n"];
    [self updateDismissLabelVisibility];
    [self.progressView setProgress:0.79];
    return;
#elif TARGET_OS_IPHONE
    self.textView.text = @"";
    self.status = Running;
    [self updateDismissLabelVisibility];
    [self appendTextToTextView:@"Initializing...\n"];
    // Try lock dpkg
    BOOL locked = [sessionManager.packageManager lockDPKG];
    if (!locked) {
        [self appendTextToTextView:@"Unable to lock dpkg, it's probably used by another app, such as Cydia.\n"];
        self.status = FinishedWithError;
        [self updateDismissLabelVisibility];
        return;
    }
    
    // Setup pipes
    [self redirectPipeContentToTextView:sessionManager.packageManager.taskStdoutPipe];
    [self redirectPipeContentToTextView:sessionManager.packageManager.taskStderrPipe];
    
    [sessionManager.packageManager installPackage:[self.delegate item]
                                 progressCallback:^(float progress){
                                    [self.progressView setProgress:progress animated:YES];
                                }]
    .catch(^(NSError* error) {
        self.status = FinishedWithError;
        [self appendTextToTextView:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        return error;
    })
    .then(^{
        self.status = FinishedSuccessfully;
    }).finally(^{
//        [self redirectRemainingContentToTextView:sessionManager.packageManager.taskStdoutPipe];
//        [self redirectRemainingContentToTextView:sessionManager.packageManager.taskStderrPipe];
        [self updateDismissLabelVisibility];
        if (self.status == FinishedSuccessfully) {
            [self appendTextToTextView:@".Done\n"];
            [self.delegate installationDidFinish:self];
        } else {
            [self appendTextToTextView:@"Package manager exited with error.\n"];
        }
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

- (IBAction)didTapOnView:(id)sender{
    [self.textView setHidden:!self.textView.hidden];
    [self.progressView setHidden:!self.progressView.hidden];
}

- (IBAction)didTapDismissButton:(id)sender {
    if (self.status != Running) {
        [sessionManager.packageManager unlockDPKG];
        NSLog(@"Unregister pipe notifications");
        [self removePipeRedirct:sessionManager.packageManager.taskStdoutPipe];
        [self removePipeRedirct:sessionManager.packageManager.taskStderrPipe];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
