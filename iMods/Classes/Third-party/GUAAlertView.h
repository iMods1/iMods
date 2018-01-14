//
//  GUAAlertView.h
//  GUAAlertView
//
//  Created by gua on 11/11/14.
//  Copyright (c) 2014 GUA. All rights reserved.
//

#import <UIKit/UIKit.h>;


typedef void (^GUAAlertViewBlock)(void);


@interface GUAAlertView : UIView

+ (instancetype)alertViewWithTitle:(NSString *)title
                           message:(NSString *)message
                       buttonTitle:(NSString *)buttonTitle
               buttonTouchedAction:(GUAAlertViewBlock)buttonBlock
                     dismissAction:(GUAAlertViewBlock)dismissBlock
                     buttons:(Boolean *)buttons;

- (void)show;
- (void)dismiss;

@end