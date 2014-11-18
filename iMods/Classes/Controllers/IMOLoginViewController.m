//
//  IMOLoginViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/23/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOLoginViewController.h"
#import "IMOUserManager.h"
#import "UICKeyChainStore.h"
#import "AppDelegate.h"
#import "IMOResetPasswordViewController.h"

@interface IMOLoginViewController ()

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *lostPasswordButton;
@property  NSDictionary* resetPasswordData;

- (IBAction)loginButtonWasTapped:(UIButton *)sender;
- (IBAction)didTapOutsideTextFields:(UITapGestureRecognizer *)sender;

@end

@implementation IMOLoginViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Setup reset password notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveResetPassword:)
                                                 name:@"ResetPassword"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
//    NSLog(@"Current Login Delegate: %@", self.delegate);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSLog(@"textField == self.passwordField is %d", textField == self.passwordField);
    if (textField == self.passwordField) {
        [self.view endEditing:YES];
        [textField resignFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"login_register_modal"]) {
        ((IMORegistrationViewController *)segue.destinationViewController).delegate = self;
    }
    if ([segue.identifier isEqualToString:@"reset_password_modal"]) {
        IMOResetPasswordViewController* vc = segue.destinationViewController;
        [vc prepareToResetPasswordFor:[self.resetPasswordData valueForKey:@"email"]
                                token:[self.resetPasswordData valueForKey:@"token"]];
    }
}


- (IBAction)loginButtonWasTapped:(UIButton *)sender {

    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    [manager userLogin:self.emailField.text
             password:self.passwordField.text].then(^(IMOUser *user){
        
        [UICKeyChainStore setString: user.email forKey: @"email"];
        [UICKeyChainStore setString: self.passwordField.text forKey: @"password"];
        [self.delegate loginViewControllerDidFinishLogin: self];
    }).catch(^(NSError *error) {
        self.errorLabel.text = @"Could not login. Please try again.";
    });
}

- (IBAction)didTapOutsideTextFields:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)registrationDidFinish:(IMORegistrationViewController *)sender withEmail:(NSString *)email withPassword:(NSString *)password {
    self.emailField.text = email;
    self.passwordField.text = password;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)sender {
    // Stub
}

- (IBAction)didTapLostPasswordButton:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset password"
                                                    message:@"Do you want to reset your password?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Reset", nil];
    alert.tag = 1;
    [alert show];
}

- (void) didReceiveResetPassword:(NSNotification*) notification {
    self.resetPasswordData = notification.object;
    [self performSegueWithIdentifier:@"reset_password_modal" sender:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1 && buttonIndex == alertView.firstOtherButtonIndex) {
        // Check email field
        NSString* email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([email length] <= 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Email"
                                                            message:@"Email field cannot be empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        
        IMOUserManager* userManager = [IMOUserManager sharedUserManager];
        
        // Show indicator
        __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        indicator.center = self.view.center;
        
        [self.view addSubview: indicator];
        
        [indicator startAnimating];
        
        [userManager userRequestResetPassword:email]
        .catch(^(NSError* error){
            NSString* msg = [NSString stringWithFormat:@"Error occurred during sending request: %@",
                             error.localizedDescription];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            // Propagate error
            return error;
        })
        .then(^{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset password"
                                                            message:@"The reset password link has been sent to your email address."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        })
        .finally(^{
            [indicator stopAnimating];
            [indicator removeFromSuperview];
        });
    }
}
@end
