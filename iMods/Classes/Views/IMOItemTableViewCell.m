//
//  IMOItemTableViewCell.m
//  iMods
//
//  Created by Brendon Roberto on 11/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

// TODO: find better solution for image reloads
#import "IMOItemTableViewCell.h"
#import "IMODownloadManager.h"
#import "IMOReviewManager.h"
#import "UIColor+HTMLColors.h"
#import "AXRatingView.h"
//@property (strong, nonatomic) NSMutableDictionary *imageCache;self.cachedImages = [[NSMutableDictionary alloc] init];
@interface IMOItemTableViewCell() {
    dispatch_semaphore_t downloadSemaphore;
}

@property (readwrite, strong, nonatomic) UILabel *textLabel;
@property (readwrite, strong, nonatomic) UILabel *detailTextLabel;
@property (readwrite, strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) BOOL isImageSet;
@property (readwrite, strong, nonatomic) AXRatingView* ratingControl;
@property (strong, nonatomic) NSNumber *downloadTries;

- (void)downloadIconImage:(IMOItem *)item;

@end

@implementation IMOItemTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize imageView;

//http://stackoverflow.com/questions/5757386/how-to-mask-an-uiimageview
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 55, self.bounds.origin.y+9, 150, 30)];
        self.textLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17.0];
        self.textLabel.textColor = [UIColor colorWithHexString:@"3D404B"];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.textLabel];
        
        self.ratingControl = [[AXRatingView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 150, self.bounds.origin.y+18, 50, 15)];
        self.ratingControl.numberOfStar = 5;
        self.ratingControl.stepInterval = 1.0;
        self.ratingControl.markFont = [UIFont systemFontOfSize:9.0];
        self.ratingControl.baseColor = [UIColor colorWithHexString:@"BCBCBC"];
        [self.ratingControl setUserInteractionEnabled:NO];
        [self insertSubview:self.ratingControl belowSubview:self.textLabel];
        
        //self.textLabel.bounds.origin.x self.bounds.origin.x + 50
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.textLabel.bounds.origin.x + 55, self.bounds.origin.y + 24, [UIScreen mainScreen].bounds.size.width - 100, 30)];
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0];
        [self addSubview: self.detailTextLabel];
        self.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        self.priceBadge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 21)];
        self.priceBadge.layer.backgroundColor = [UIColor colorWithHue:.415 saturation:0.64 brightness:0.87 alpha:1.0].CGColor;
        self.priceBadge.layer.cornerRadius = self.priceBadge.bounds.size.height / 2;
        self.priceBadge.center = CGPointMake(self.bounds.origin.x + [UIScreen mainScreen].bounds.size.width - 35, self.center.y+8);
        self.priceBadge.textAlignment = NSTextAlignmentCenter;
        self.priceBadge.font = [UIFont fontWithName:@"Avenir-Heavy" size:12.0];
        self.priceBadge.textColor = [UIColor colorWithHexString:@"007E4E"];
        [self addSubview:self.priceBadge];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.bounds.origin.y + 17, 27, 27)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.image = [UIImage imageNamed:@"mask.png"];
        //self.imageView.layer.masksToBounds = YES;
        [self addSubview: self.imageView];
        self.isImageSet = NO;

        UIView *additionalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, 0.5)];
        additionalSeparator.backgroundColor = [UIColor colorWithHexString:@"E0DCDC"];
        [self addSubview:additionalSeparator];
        
        // Try to redownload 5 times
        downloadSemaphore = dispatch_semaphore_create(5);
    }
    
    return self;
}

- (void)prepareForReuse {
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    self.priceBadge.text = nil;
    //TODO: add ratings
    //self.imageView.image = [UIImage imageNamed:@"mask.png"];
    //[self.imageView.file cancel];
    //self.isImageSet = NO;
    [super prepareForReuse];
}

- (void)configureWithItem:(IMOItem *)item {
    self.imageView.image = [UIImage imageNamed:@"mask.png"];
    // Download image from item
    [self downloadIconImage:item];
    
    if (item.rating >= 0) {
        self.ratingControl.value = item.rating;
    } else {
        IMOReviewManager* reviewManager = [[IMOReviewManager alloc] init];
        [reviewManager getReviewsByItem:item]
        .then(^(NSArray* reviews) {
            NSUInteger totalRating = 0;
            for(IMOReview* rev in reviews) {
                totalRating += rev.rating;
            }
            NSUInteger count = reviews.count;
            if (count == 0) {
                count = 1;
            }
            float finalRating = (float)totalRating/count;
            item.rating = finalRating;
            self.ratingControl.value = finalRating;
        });
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(self.bounds.origin.x + 55, self.bounds.origin.y+9, 150, 30);
    self.textLabel.text = item.display_name;
    
    CGSize textSize = [self.textLabel
                       textRectForBounds:self.textLabel.frame
                       limitedToNumberOfLines:self.textLabel.numberOfLines].size;
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, textSize.width, 30);
    self.detailTextLabel.text = item.summary;
    self.ratingControl.frame = CGRectMake(self.textLabel.frame.origin.x + textSize.width + 10, self.ratingControl.frame.origin.y, 50, 15);
    if (item.price > 0) {
        self.priceBadge.text = [NSString stringWithFormat: @"$ %.2f", item.price];
    } else {
        self.priceBadge.text = @"FREE";
    }
}

- (void)downloadIconImage:(IMOItem *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        IMODownloadManager *manager = [IMODownloadManager sharedDownloadManager];

        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.imageView.center;
        [self addSubview:indicator];
        [indicator startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [manager download:Icon item:item].then(^(NSDictionary *results) {
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                if ([results valueForKey:@"icon"]) {
                    UIImage *icon = [results valueForKey:@"icon"];
                    UIImage *mask = [UIImage imageNamed:@"mask.png"];
                    UIImage *maskedImage = [self maskImage:icon withMask:mask];
                    //TODO: fix mask
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = maskedImage;
                        self.imageView.layer.masksToBounds = YES;
                        self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2;
                        [self setNeedsDisplay];
                        self.isImageSet = YES;
                    });
                }
            }).catch(^{
                // If failed, try again.
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_semaphore_wait(downloadSemaphore, DISPATCH_TIME_FOREVER);
                    [self downloadIconImage:item];
                });
            });
        });
    });
}


@end
