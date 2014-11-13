//
//  IMOItemTableViewCell.m
//  iMods
//
//  Created by Brendon Roberto on 11/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOItemTableViewCell.h"
#import "IMODownloadManager.h"

@interface IMOItemTableViewCell()

@property (readwrite, strong, nonatomic) UILabel *textLabel;
@property (readwrite, strong, nonatomic) UILabel *detailTextLabel;
@property (readwrite, strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) BOOL isImageSet;

- (void)downloadIconImage:(IMOItem *)item;

@end

@implementation IMOItemTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize imageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 50, self.bounds.origin.y, 250, 30)];
        self.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:14.0];
        [self addSubview:self.textLabel];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 50, self.bounds.origin.y + 15, 250, 30)];
        self.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:10.0];
        [self addSubview: self.detailTextLabel];
        
        self.priceBadge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        self.priceBadge.layer.backgroundColor = [UIColor colorWithHue:0.49 saturation:0.77 brightness:0.85 alpha:1.0].CGColor;
        self.priceBadge.layer.cornerRadius = self.priceBadge.bounds.size.height / 2;
        self.priceBadge.center = CGPointMake(self.bounds.origin.x + self.bounds.size.width - 50, self.center.y);
        self.priceBadge.textAlignment = NSTextAlignmentCenter;
        self.priceBadge.font = [UIFont fontWithName:@"Avenir-Heavy" size:10.0];
        self.priceBadge.textColor = [UIColor lightTextColor];
        [self addSubview:self.priceBadge];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.bounds.origin.y + 7, 30, 30)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.image = nil;
        [self addSubview: self.imageView];
        self.isImageSet = NO;
    }
    
    return self;
}

- (void)configureWithItem:(IMOItem *)item {
    
    // Download image from item
    [self downloadIconImage:item];
    
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.text = item.display_name;
    self.detailTextLabel.text = item.summary;
    if (item.price > 0) {
        self.priceBadge.text = [NSString stringWithFormat: @"$%.2f", item.price];
    } else {
        self.priceBadge.text = @"FREE";
    }
}

- (void)downloadIconImage:(IMOItem *)item {
    if (!self.isImageSet) {
        IMODownloadManager *manager = [IMODownloadManager sharedDownloadManager];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.imageView.center;
        [self addSubview:indicator];
        [indicator startAnimating];
        [manager download:Assets item:item].then(^(NSDictionary *results) {
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            UIImage *icon = [UIImage imageWithData:[results valueForKey:@"icon"]];
            self.imageView.image = icon;
            //[self.imageView setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, 30, 30)];
            self.imageView.layer.masksToBounds = YES;
            self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2;
            [self setNeedsDisplay];
            self.isImageSet = YES;
        }).catch(^{
            // If failed, try again.
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            [self downloadIconImage:item];
        });
    }
}
@end
