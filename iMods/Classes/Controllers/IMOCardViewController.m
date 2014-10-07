//
//  IMOCardViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/5/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCardViewController.h"
#import <PaymentKit/PTKView.h>

@interface IMOCardViewController ()<PTKViewDelegate>
@property (weak, nonatomic) PTKView *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) PTKCard *card;

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid;
- (IBAction)submitButtonTapped:(id)sender;
@end

@implementation IMOCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Add PTKView
    
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
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

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    self.submitButton.enabled = YES;
    self.card = card;
}

- (IBAction)submitButtonTapped:(id)sender {
    [self.delegate cardControllerDidFinish: self withCard: self.card];
}

@end
