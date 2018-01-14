//
//  IMOProfileViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "IMOProfileViewController.h"
#import "IMOUserManager.h"
#import "IMONetworkManager.h"
#import "AppDelegate.h"
#import "UIColor+HTMLColors.h"
#import "NSString+MD5.h"
#import "GUAAlertView.h"

UIView *hidden1;
UIView *hidden2;

@interface IMOProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *installedItemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishlistItemsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

- (void)setupLabels;
- (void)setupProfilePicture;
- (IBAction)walletButtonTapped:(id)sender;

@end

@implementation IMOProfileViewController
- (IBAction)emailUs:(id)sender {
    [self supportEmailComposer];
}

- (void)shareText:(NSString *)text andUrl:(NSURL *)url {
    NSMutableArray *sharingItems = [NSMutableArray new];

    if (text) {
        [sharingItems addObject:text];
    }

    if (url) {
        [sharingItems addObject:url];
    }

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}
- (IBAction)callUs:(id)sender {
    GUAAlertView *v = [GUAAlertView alertViewWithTitle:@"Attention"
        message:@"Calling us is not available in the beta."
        buttonTitle:@"Ok"
       buttonTouchedAction:^{
           NSLog(@"button touched");
       } dismissAction:^{
           NSLog(@"dismiss");
       }
       buttons: NO];

    [v show];
}
- (IBAction)chatWithUs:(id)sender {
    GUAAlertView *v = [GUAAlertView alertViewWithTitle:@"Attention"
        message:@"Chatting with us is not available in the beta."
        buttonTitle:@"Ok"
       buttonTouchedAction:^{
           NSLog(@"button touched");
       } dismissAction:^{
           NSLog(@"dismiss");
       }
       buttons: NO];

    [v show];
}

- (IBAction)shareButton:(id)sender {
    [self shareText:@"Checkout out iMods!" andUrl:[NSURL URLWithString:@"http://imods.co"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.tabBarController.view.subviews objectAtIndex:0].hidden = YES;
    //[self.tabBarController.tabBar.layer setFrame:CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.tabBarController.tabBar.frame.origin.y+100, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height)];
    /*
    self.tabBarController.tabBar.hidden = YES;
    self.tabBarController.tabBar.userInteractionEnabled = NO;
     */

    [self setupLabels];
    [self setupProfilePicture];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"488CA5"];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar
        setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"488CA5"]}];
}

- (void)setupLabels {
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    if (manager.userLoggedIn) {
        self.nameLabel.text = manager.userProfile.fullname;
        self.wishlistItemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[manager.userProfile.wishlist count]];
        
        self.installedItemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[manager.installedItems count]];
    }
}

- (void)setupProfilePicture {
    if (self.profilePictureImageView.image) {
        return;
    }
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2;
    self.profilePictureImageView.layer.masksToBounds = YES;

    [manager getProfileImage].then(^(NSURL* imgURL){
        if (imgURL) {
            //TODO: add cacheManager for this, should be actual persist not in memory as it doesnt change constant
            self.profilePictureImageView.image = [UIImage imageNamed:@"imods_default"];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:imgURL];
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.profilePictureImageView.image = image;
                });
            });
        }
    });
}

- (IBAction)walletButtonTapped:(id)sender {
    GUAAlertView *v = [GUAAlertView alertViewWithTitle:@"Attention"
        message:@"Wallet is not available in the beta."
        buttonTitle:@"Ok"
       buttonTouchedAction:^{
           NSLog(@"button touched");
       } dismissAction:^{
           NSLog(@"dismiss");
       }
       buttons: NO];

    [v show];
    /*[self performSegueWithIdentifier:@"profile_wallet_push" sender:self];*/
}

- (IBAction)profileImageTapped:(UIView*)sender {
    UIImagePickerController* imagePicker = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
    }
    
    UIImagePickerController* cameraPicker = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.allowsEditing = YES;
        cameraPicker.delegate = self;
    }
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Update your photo", nil, [self translationsBundle], nil)
                                                                             message:NSLocalizedStringFromTableInBundle(@"Select an image source", nil, [self translationsBundle], nil)
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    void(^actionPickFromPhotoLibrary)(UIAlertAction*) = ^(UIAlertAction* action){
        [self presentViewController:imagePicker animated:YES completion:nil];
    };
    
    void(^actionTakePicture)(UIAlertAction*) = ^(UIAlertAction* action){
        [self presentViewController:cameraPicker animated:YES completion:nil];
    };
    
    UIAlertAction* pickFromPhotoLibrary = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Photo Library", nil, [self translationsBundle], nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:actionPickFromPhotoLibrary];
    
    UIAlertAction* takePicture = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Take a Picture", nil, [self translationsBundle], nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:actionTakePicture];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [self translationsBundle], nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action){}];
    if (imagePicker) {
        [alertController addAction:pickFromPhotoLibrary];
    }
    if (cameraPicker) {
        [alertController addAction:takePicture];
    }
    [alertController addAction:cancel];
    
    UIPopoverPresentationController* popover = alertController.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.profilePictureImageView;
        popover.sourceRect = self.profilePictureImageView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) supportEmailComposer {
    MFMailComposeViewController *comp=[[MFMailComposeViewController alloc]init];
    [comp setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        [comp setToRecipients:[NSArray arrayWithObjects:@"staff@imods.co", nil]];
        [comp setSubject:@"Help Request"];
        //[comp setMessageBody:@"Hello bro" isHTML:NO];
        [comp setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:comp animated:YES completion:nil];
    }
    else {
        UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Mail not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Couldn't send mail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrt show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Upload the image
        IMONetworkManager *manager = [IMONetworkManager sharedNetworkManager];
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.profilePictureImageView.bounds];
        [self.profilePictureImageView addSubview:indicator];
        [indicator startAnimating];
        
        [manager POST:@"user/profile_image/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
        {
            NSData* imageData = UIImagePNGRepresentation(imageToUse);
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"profile_img.png" mimeType:@"image/png"];
        }
             completion:^(OVCResponse* response, NSError* error)
        {
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            if (error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Error", nil, [self translationsBundle], nil)
                                                                message:NSLocalizedStringFromTableInBundle(@"Failed to upload image, please try again later.", nil, [self translationsBundle], nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [self translationsBundle], nil)
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            self.profilePictureImageView.image = imageToUse;
         }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
