//
//  IMOLoadingViewController.h
//  iMods
//
//

#import <UIKit/UIKit.h>
#import <MRProgress.h>
#import "UIViewControllerNoAutorotate.h"
#import "IMOFeaturedViewController.h"
#import "IMOLoginViewController.h"
@interface IMOLoadingViewController : UIViewControllerNoAutorotate <IMOLoginDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet MRCircularProgressView* progressView;
- (void) dismissView;
@property NSString *pass;
- (void) initWithController:(IMOFeaturedViewController *)featureViewCtrl;
@end