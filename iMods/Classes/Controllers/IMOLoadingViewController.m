//
//  IMOLoadingViewController.m
//  iMods
//
//

#import "IMOLoadingViewController.h"
#import "UIColor+HTMLColors.h"
#import <QuartzCore/QuartzCore.h>
#import "IMOSessionManager.h"
#import "IMOUserManager.h"
#import "UICKeyChainStore.h"
#import "IMOKeychainManager.h"

@interface IMOLoadingViewController ()
- (void)presentLoginViewController:(BOOL)animated;
@property (weak) IMOSessionManager* sessionManager;
@property (weak, nonatomic) IMOFeaturedViewController *featureViewCtrl;
@end

@implementation IMOLoadingViewController

@synthesize progressView = _progressView;
@synthesize version = _version;

static NSString *IMODS_INTERNAL_VERSION = @"1.0.1"; // update on new versions

BOOL ignore = NO;

- (void) initWithController:(IMOFeaturedViewController *)featureViewCtrl {
    self.featureViewCtrl = featureViewCtrl;
}

- (void)viewDidAppear:(BOOL)animated { 
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    rotation.duration = 1.1; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [self.progressView.layer addAnimation:rotation forKey:@"Spin"];
    if (ignore != YES) {
        IMOUserManager *manager = [IMOUserManager sharedUserManager];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *email = [defaults stringForKey:@"email"];
        NSString *password;
        if (email != nil) {
            NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/AccountsDaemon.framework/"];
            BOOL successful = [bundle load];
            if (successful) {
                self.pass = [IMOKeychainManager passwordForUser:email];
            }
            password = self.pass;
        }
        
        NSLog(@"User login status: %d", manager.userLoggedIn);
        if (!manager.userLoggedIn) {
            NSLog(@"User not logged in");
            if (email && password) {
                [manager userLogin: email password: password].then(^(IMOUser *user) {
                    NSLog(@"User: %@ successfully logged in", user);
                    [self.sessionManager.userManager refreshInstalled].then(^() {
                        if (self.featureViewCtrl) {
                            [self.featureViewCtrl refreshUpdatesCount];
                            [self.featureViewCtrl setItemsForCategory: @"Themes"];
                        }
                        [self dismissView];
                    }).catch(^() {
                        if (self.featureViewCtrl) {
                            [self.featureViewCtrl setItemsForCategory: @"Themes"];
                        }
                        [self dismissView];
                    });
                }).catch(^(NSError *error) {
                    NSLog(@"Login error: %@", error.localizedDescription);
                    [self presentLoginViewController: YES];
                });
            } else {
                [self presentLoginViewController: YES];
            }
        } else {
            [self dismissView];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [IMOSessionManager sharedSessionManager];
    self.view.backgroundColor = [UIColor clearColor];
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.frame;
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:blurView atIndex:0];
    
    UIImage* gradient = [UIImage imageNamed:@"gradientColor"];
    UIColor* gradientColor = [UIColor colorWithPatternImage:gradient];
    self.version.textColor = gradientColor;
    self.progressView.tintColor = gradientColor;
    self.progressView.lineWidth = 5.0f;
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.valueLabel.hidden = YES;

    self.version.text = IMODS_INTERNAL_VERSION;

    [self.progressView setProgress:0.25f];
}

- (void) dismissView {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"tab_bar_login_modal"]) {
        if ([[segue destinationViewController] isKindOfClass: [IMOLoginViewController class]]) {
            IMOLoginViewController *lvc = [segue destinationViewController];
            lvc.delegate = self;
        }
    } 
}

- (void)loginViewControllerDidFinishLogin:(IMOLoginViewController *)lvc {
    ignore = YES;
    [self.sessionManager.userManager refreshInstalled].then(^() {
        if (self.featureViewCtrl) {
            [self.featureViewCtrl refreshUpdatesCount];
            [self.featureViewCtrl setItemsForCategory: @"Themes"];
        }
        [self dismissView];
    }).catch(^() {
        if (self.featureViewCtrl) {
            [self.featureViewCtrl setItemsForCategory: @"Themes"];
        }
        [self dismissView];
    });
}

- (void)presentLoginViewController:(BOOL)animated {
    [self performSegueWithIdentifier: @"tab_bar_login_modal" sender: self];
}

@end
