//
//  IMOCardViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/5/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

//#import "PTKView.h"
#import <PayPalMobile.h>
#import "IMOCardViewController.h"
#import "IMOUserManager.h"
#import "AppDelegate.h"

/*@interface IMOCardViewController ()<PTKViewDelegate, PayPalFuturePaymentDelegate>*/
@interface IMOCardViewController ()<PayPalFuturePaymentDelegate>
//@property (weak, nonatomic) PTKView *paymentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
//@property (strong, nonatomic) PTKCard *card;
@property (strong, nonatomic) IMOBillingInfo *info;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paymentTypeControl;

@property (nonatomic, assign) PaymentType selectedPaymentType;
@property (nonatomic, strong) PayPalConfiguration* paypalConfig;
//- (void)createCreditCardBillingInfo:(PTKCard *)card;
- (void)createPaypalBillingInfo:(NSDictionary*)authorizationInfo;
//- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid;
- (BOOL)validateFields;
- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)submitButtonTapped:(id)sender;
- (IBAction)didTapOutsideFields:(id)sender;
@end

@implementation IMOCardViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Init paypal configuration
        self.paypalConfig = [[PayPalConfiguration alloc] init];
        self.paypalConfig.merchantName = @"iMods";
        // FIXME: Replace urls with correct ones
        self.paypalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@""];
        self.paypalConfig.merchantUserAgreementURL = [NSURL URLWithString:@""];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Add PTKView

    //PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    //self.paymentView = view;
    //self.paymentView.delegate = self;
    //[self.scrollView addSubview:self.paymentView];

    // Preconnect to paypal
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.paymentProductionMode) {
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];

    } else if(appDelegate.isRunningTest) {
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    } else {
//        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
    }
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

/*- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
    if (valid) {
        self.card = card;
    } else {

    }
}*/

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
    BOOL valid = YES;
    valid = valid && (self.addressField.text.length > 0);
    valid = valid && (self.zipcodeField.text.length > 0);
    valid = valid && (self.cityField.text.length > 0);
    valid = valid && (self.stateField.text.length > 0);
    valid = valid && (self.countryField.text.length > 0);
    if (self.selectedPaymentType == CreditCard) {
        /*valid = valid && (self.card.number.length > 0);
        valid = valid && (self.card.expMonth > 0);
        valid = valid && (self.card.expYear > 0);
        valid = valid && (self.card.cvc.length > 0);*/
    }
    return valid;
}

/*- (void)createCreditCardBillingInfo:(PTKCard *)card {
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

}*/

- (void)createPaypalBillingInfo:(NSDictionary*)authorizationInfo {
    NSString* auth_code = [authorizationInfo valueForKeyPath:@"response.code"];
    if (!auth_code) {
        NSString *authStr = NSLocalizedStringFromTableInBundle(@"Authorization Failed", nil, [self translationsBundle], nil);
        NSString *ppAuthStr = NSLocalizedStringFromTableInBundle(@"PayPal authorization failed, please try again later.", nil, [self translationsBundle], nil);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:authStr
                                                        message:ppAuthStr
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSDictionary* infoDict = @{
                               @"paymentType": @(Paypal),
                               @"address": self.addressField.text,
                               @"zipcode": self.zipcodeField.text,
                               @"city": self.cityField.text,
                               @"state": self.stateField.text,
                               @"country": self.countryField.text,
                               @"paypalAuthCode": auth_code
                               };
    NSError* error = nil;
    IMOBillingInfo *info = [IMOBillingInfo modelWithDictionary:infoDict error:&error];
    if (error) {
        NSString *errorStr = NSLocalizedStringFromTableInBundle(@"Error", nil, [self translationsBundle], nil);
        NSString *spErrorStr = NSLocalizedStringFromTableInBundle(@"Unable to create billing info.", nil, [self translationsBundle], nil);
        NSString *okStr = NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:errorStr
                                                        message:spErrorStr
                                                       delegate:self
                                              cancelButtonTitle:okStr
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"Unable to create billing info: %@", error.localizedDescription);
        self.info = nil;
    } else {
        self.info = info;
    }
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate cardControllerDidCancel: self];
}

- (IBAction)paymentTypeTapped:(id)sender {
    if (self.paymentTypeControl.selectedSegmentIndex == 0) {
        self.selectedPaymentType = CreditCard;
        //self.paymentView.hidden = false;
    } else {
        self.selectedPaymentType = Paypal;
        //self.paymentView.hidden = true;
    }
}

- (IBAction)submitButtonTapped:(id)sender {
    if (![self validateFields]) {
        NSString *okStr = NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil);
        NSString *fError = NSLocalizedStringFromTableInBundle(@"Form error", nil, [self translationsBundle], nil);
        NSString *fieldError = NSLocalizedStringFromTableInBundle(@"One or more fields are missing or invlid.", nil, [self translationsBundle], nil);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:fError
                                                        message:fieldError
                                                       delegate:self
                                              cancelButtonTitle:okStr
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (self.selectedPaymentType == CreditCard) {
        //[self createCreditCardBillingInfo: self.card];
        [self.delegate cardControllerDidFinish:self withBillingInfo:self.info];
    } else {
        PayPalFuturePaymentViewController *fpViewController;
        fpViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.paypalConfig
                                                                                   delegate:self];

        // Present the PayPalFuturePaymentViewController
        [self presentViewController:fpViewController animated:YES completion:nil];
    }
}

#pragma mark PayPalFuturePaymentDelegate

- (void) payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {

    [self.delegate cardControllerDidCancel:self];
}

- (void) payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    [self createPaypalBillingInfo:futurePaymentAuthorization];
    if (self.info) {
        [self.delegate cardControllerDidFinish:self withBillingInfo:self.info];
    }
}

@end
