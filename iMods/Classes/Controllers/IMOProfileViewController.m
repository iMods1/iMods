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

@interface IMOProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *installedItemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishlistItemsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObject *managedItem;

- (void)setupLabels;
- (void)setupProfilePicture;
- (IBAction)walletButtonTapped:(id)sender;

@end

@implementation IMOProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"imods-assets-profile-background"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.tabBarController.tabBar.hidden = YES;
    
    [self setupLabels];
    [self setupProfilePicture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    
    self.tabBarController.tabBar.hidden = NO;
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

- (void)setupLabels {
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    if (manager.userLoggedIn) {
        self.nameLabel.text = manager.userProfile.fullname;
        self.wishlistItemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[manager.userProfile.wishlist count]];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"IMOInstalledItem"];
        
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error: &error];

        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            self.installedItemsLabel.text = @"?";
        } else {
            self.installedItemsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[result count]];
        }
    }
}

- (void)setupProfilePicture {
    if (self.profilePictureImageView.image) {
        return;
    }
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    self.profilePictureImageView.image = [UIImage imageNamed:@"imods-logo"];
    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width / 2;
    self.profilePictureImageView.layer.masksToBounds = YES;
    [manager getProfileImage].then(^(NSData* data){
        if (data) {
            self.profilePictureImageView.image = [UIImage imageWithData:data];
        }
    });
}

- (IBAction)walletButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"profile_wallet_push" sender:self];
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
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Update your photo"
                                                                             message:@"Select an image source"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    void(^actionPickFromPhotoLibrary)(UIAlertAction*) = ^(UIAlertAction* action){
        [self presentViewController:imagePicker animated:YES completion:nil];
    };
    
    void(^actionTakePicture)(UIAlertAction*) = ^(UIAlertAction* action){
        [self presentViewController:cameraPicker animated:YES completion:nil];
    };
    
    UIAlertAction* pickFromPhotoLibrary = [UIAlertAction actionWithTitle:@"Photo Library"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:actionPickFromPhotoLibrary];
    
    UIAlertAction* takePicture = [UIAlertAction actionWithTitle:@"Take a Picture"
                                                          style:UIAlertActionStyleDefault
                                                        handler:actionTakePicture];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
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
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Failed to upload image, please try again later."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
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
