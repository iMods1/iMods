//
//  IMOViewPreviewViewController.h
//  iMods
//
//  Created by Ryan Feng on 11/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IMOYouTubeVideoPreviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (strong, nonatomic) NSString* youtubeVideoID;

@end
