//
//  IMORegistrationViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOResetPasswordViewController.h"
#import <Overcoat/NSError+OVCResponse.h>
#import <Overcoat/OVCResponse.h>
#import "IMOUserManager.h"

@interface IMOResetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIButton* submitNewPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton* cancelButton;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;
@property (weak, nonatomic) IBOutlet UITextField* confirmPasswordField;
@property (weak, nonatomic) IBOutlet UILabel* errorLabel;

@property NSString* email;
@property NSString* token;

@end

@implementation IMOResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)prepareToResetPasswordFor:(NSString *)email token:(NSString *)token {
    self.email = email;
    self.token = token;
}

- (IBAction)didTapSubmitButton:(id)sender {
    NSString* newpwd = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* confirmNewpwd = [self.confirmPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([newpwd length] == 0 || [confirmNewpwd length] == 0) {
        self.errorLabel.text = @"Password fields cannot be empty";
        return;
    }
    if (![newpwd isEqualToString:confirmNewpwd]) {
        self.errorLabel.text = @"Password fields don't match";
        return;
    }
    NSLog(@"Reset password: %@ %@ %@", self.email, self.token, newpwd);
    [[IMOUserManager sharedUserManager] userResetPassword:self.email
                                                    token:self.token
                                             new_password:newpwd]
    .catch(^(NSError* error){
        if (error.ovc_response.HTTPResponse.statusCode == 403) {
            self.errorLabel.text = @"The reset password token has expired, please send a new request.";
        } else {
            self.errorLabel.text = error.localizedDescription;
        }
        return error;
    })
    .then(^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Password Reset"
                                                        message:@"Your password has been reset."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self didTapCancelButton:self];
    });
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (IBAction)didTapOutsideTextFields:(id)sender {
    [self.view endEditing:YES];
}

@end
