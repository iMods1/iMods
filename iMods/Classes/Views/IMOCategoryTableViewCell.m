//
//  IMOItemTableViewCell.m
//  iMods
//
//  Created by Brendon Roberto on 11/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCategoryTabelViewCell.h"
#import "IMODownloadManager.h"
#import "IMOCategoryManager.h"
#import "UIColor+HTMLColors.h"

@interface IMOCategoryTableViewCell()

@property (readwrite, strong, nonatomic) UILabel *textLabel;
@property (readwrite, strong, nonatomic) UILabel *detailTextLabel;
@property (readwrite, strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) BOOL isImageSet;

@end

@implementation IMOCategoryTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize imageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 125, self.bounds.origin.y+10, 250, 30)];
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        self.textLabel.textColor = [UIColor colorWithHexString:@"6f6f6f"];
        [self addSubview:self.textLabel];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 75, self.bounds.origin.y + 20, 250, 30)];
        self.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:10.0];
        [self addSubview: self.detailTextLabel];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 75, self.bounds.origin.y + 7, 30, 30)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.image = nil;
        [self addSubview: self.imageView];
        self.isImageSet = NO;
    }
    
    return self;
}

@end
