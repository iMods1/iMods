#import <UIKit/UIKit.h>
#import "IMOSessionManager.h"
#import "IMOPackageManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;

@property (readonly, nonatomic) BOOL isRunningTest;
@property (readonly, nonatomic) BOOL paymentProductionMode;
@property (strong, nonatomic) IMOSessionManager* sharedSessionManager;

@end
