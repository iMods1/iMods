//
//  IMOCardViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/5/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCardViewController.h"
#import <PaymentKit/PTKView.h>
#import "IMOUserManager.h"

@interface IMOCardViewController ()<PTKViewDelegate>
@property (weak, nonatomic) PTKView *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) PTKCard *card;
@property (strong, nonatomic) IMOBillingInfo *info;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (void)createBillingInfo:(PTKCard *)card;
- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid;
- (BOOL)validateFields;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)submitButtonTapped:(id)sender;
- (IBAction)didTapOutsideFields:(id)sender;
@end

@implementation IMOCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Add PTKView
    
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.scrollView addSubview:self.paymentView];
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

- (IBAction)didTapOutsideFields:(id)sender {
    [self.scrollView endEditing:YES];
}

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    if (valid) {
        self.card = card;
    } else {
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.addressField) {
        [self.zipcodeField becomeFirstResponder];
    } else if (textField == self.zipcodeField) {
        [self.cityField becomeFirstResponder];
    } else if (textField == self.cityField) {
        [self.stateField becomeFirstResponder];
    } else if (textField == self.stateField) {
        [self.countryField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
    }
    return YES;
}

#pragma mark - Misc

- (BOOL)validateFields {
    NSLog(@"Validating Fields");
    BOOL valid = YES;
    valid = valid && (self.addressField.text.length > 0);
    valid = valid && (self.zipcodeField.text.length > 0);
    valid = valid && (self.cityField.text.length > 0);
    valid = valid && (self.stateField.text.length > 0);
    valid = valid && (self.countryField.text.length > 0);
    valid = valid && (self.card.number.length > 0);
    valid = valid && (self.card.expMonth > 0);
    valid = valid && (self.card.expYear > 0);
    valid = valid && (self.card.cvc.length > 0);

    return valid;
}

- (void)createBillingInfo:(PTKCard *)card {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"];
    dateFormatter.dateFormat = @"MM/yy";
    
    NSDictionary *infoDict = @{
                               @"creditcardNumber": card.number,
                               @"creditcardCVV": card.cvc,
                               @"creditcardName": [IMOUserManager sharedUserManager].userProfile.fullname,
                               @"creditcardExpiration": [dateFormatter dateFromString: [NSString stringWithFormat: @"%02lu/%02lu", (unsigned long)card.expMonth, (unsigned long)card.expYear]],
                               @"address": self.addressField.text,
                               @"zipcode": self.zipcodeField.text,
                               @"city": self.cityField.text,
                               @"state": self.stateField.text,
                               @"country": self.countryField.text,
                               @"paymentType": @(CreditCard)
                               };
    NSError *error = nil;
    IMOBillingInfo *info = [IMOBillingInfo modelWithDictionary:infoDict error:&error];
    
    if (error) {
        // TODO: Handle error
        self.info = nil;
    } else {
        NSLog(@"Successfully created billing info: %@", info);
        self.info = info;
    }
    
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate cardControllerDidCancel: self];
}

- (IBAction)submitButtonTapped:(id)sender {
    if (![self validateFields]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Form error"
                                                        message:@"One or more fields are missing or invlid."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self createBillingInfo: self.card];
    [self.delegate cardControllerDidFinish: self withBillingInfo: self.info];
}

@end
