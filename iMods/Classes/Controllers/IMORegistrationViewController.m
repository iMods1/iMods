//
//  IMORegistrationViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMORegistrationViewController.h"
#import "IMOUserManager.h"

@interface IMORegistrationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

- (IBAction)registerButtonTapped:(id)sender;
- (IBAction)didTapOutsideTextFields:(id)sender;

@end

@implementation IMORegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ageTextField.delegate = self;
    self.userNameField.delegate = self;
    self.fullNameField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordConfirmationTextField.delegate = self;
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


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // TODO: unstub
    return YES;
}



- (IBAction)registerButtonTapped:(id)sender {
    UIColor *errorRed = [UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:1.0];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSString *userName = self.userNameField.text;
    NSString *fullName = self.fullNameField.text;
    NSNumber *age = [f numberFromString: self.ageTextField.text];
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *confirmation = self.passwordConfirmationTextField.text;
    
    if (!([password isEqualToString: confirmation] && password.length > 0)) {
        // Bail if passwords are not correct.
        self.passwordTextField.backgroundColor = errorRed;
        self.passwordConfirmationTextField.backgroundColor = errorRed;
        return;
    }
    
    PMKPromise *registerPromise = [[IMOUserManager sharedUserManager] userRegister:email password:password fullname:fullName age:age author_id:userName].catch(^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Registration Error" message:[NSString stringWithFormat:@"An error occurred while registering.\n%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"register_login_unwind" sender:self];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    });
    
    [PMKPromise when: @[registerPromise]].then(^{
        [self.delegate registrationDidFinish:self withEmail:email withPassword:password];
    });
}

- (IBAction)didTapOutsideTextFields:(id)sender {
    [self.view endEditing:YES];
}
@end
