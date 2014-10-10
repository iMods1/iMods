//
//  IMOMockInstallationViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOMockInstallationViewController.h"
#import "PRHTask.h"

@interface IMOMockInstallationViewController ()
@property (strong, nonatomic) NSPipe *pipe;
@property (strong, nonatomic) NSFileHandle *handle;

- (void)launchTaskWithOptions:(NSDictionary *)options;
- (void)handleTaskNotification:(NSNotification *)notification;
@end

@implementation IMOMockInstallationViewController

@synthesize progressView = _progressView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create the DACircularProgressView and add it to the view
    DACircularProgressView *progressView = [[DACircularProgressView alloc]
                                            initWithFrame:self.view.frame];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    // Create a new NSPipe for taskOutput
    self.pipe = [NSPipe pipe];
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
    
    PRHTask *task = [self.delegate taskForMockInstallation:self withOptions:options];
    task.standardOutput = self.pipe;
    
    self.handle = [self.pipe fileHandleForReading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTaskNotification:) name:NSFileHandleDataAvailableNotification  object:nil];
    
    [task launch];

}

- (void)handleTaskNotification:(NSNotification *)notification {
    NSData *data = nil;
    while ((data = [self.handle availableData]) && [data length]) {
        // TODO: Parse output and update progressView appropriately
    }
}

@end
