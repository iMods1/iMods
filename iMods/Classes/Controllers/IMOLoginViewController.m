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

@interface IMOLoginViewController ()

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)loginButtonWasTapped:(UIButton *)sender;
- (IBAction)registerButtonWasTapped:(UIButton *)sender;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textField == self.passwordField is %d", textField == self.passwordField);
    if (textField == self.passwordField) {
        [self.view endEditing:YES];
        [textField resignFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    return false;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonWasTapped:(UIButton *)sender {
    
    // Don't require login on debug
    
#ifdef DEBUG
    [self.delegate loginViewControllerDidFinishLogin: self];
#endif
    
    // TODO: Store/retrieve login credentials from Key Chain
    
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    [manager userLogin:self.userNameField.text
             password:self.passwordField.text].then(^(IMOUser *user){
        
        [UICKeyChainStore setString: user.email forKey: @"email"];
        [UICKeyChainStore setString: self.passwordField.text forKey: @"password"];
        [self.delegate loginViewControllerDidFinishLogin: self];
    }).catch(^(NSError *error) {
        self.errorLabel.text = @"Could not login. Please try again.";
    });
}

- (IBAction)registerButtonWasTapped:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Not Implemented"
                                message:@"Registering is not implemented! Sorry!"
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)didTapOutsideTextFields:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}
@end
