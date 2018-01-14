//
//  IMOWishlistTableViewCell.m
//  iMods
//
//  Created by Marcus Ferrario on 7/9/15.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

// TODO: find better solution for image reloads
#import "IMOWishlistTableViewCell.h"
#import "IMODownloadManager.h"
#import "IMOReviewManager.h"
#import "UIColor+HTMLColors.h"

@interface IMOWishlistTableViewCell() {
    dispatch_semaphore_t downloadSemaphore;
}

@property (readwrite, strong, nonatomic) UILabel *textLabel;
@property (readwrite, strong, nonatomic) UILabel *detailTextLabel;
@property (readwrite, strong, nonatomic) UIImageView *imageView;
@property (readwrite, strong, nonatomic) UIImageView *typeView;
@property (assign, nonatomic) BOOL isImageSet;
@property (strong, nonatomic) NSNumber *downloadTries;

- (void)downloadIconImage:(IMOItem *)item;

@end

@implementation IMOWishlistTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize imageView;
@synthesize typeView;

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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 55, self.bounds.origin.y+9, 150, 30)];
        self.textLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17.0];
        self.textLabel.textColor = [UIColor colorWithHexString:@"3D404B"];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.textLabel];
        
        self.typeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10, self.bounds.origin.y+19, 12, 12)];
        self.typeView.contentMode = UIViewContentModeScaleAspectFit;
        self.typeView.clipsToBounds = YES;
        self.typeView.image = [UIImage imageNamed:@"imods-assets-tweaks-icon.png"];
        [self addSubview: self.typeView];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.textLabel.bounds.origin.x + 55, self.bounds.origin.y + 24, [UIScreen mainScreen].bounds.size.width - 100, 30)];
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0];
        [self addSubview: self.detailTextLabel];
        self.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        self.priceBadge = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        self.priceBadge.center = CGPointMake(self.bounds.origin.x + [UIScreen mainScreen].bounds.size.width - 25, self.center.y+8);
        [self.priceBadge setImage:[UIImage imageNamed:@"clearIcon-imods"] forState:UIControlStateNormal];
        self.priceBadge.tintColor = [UIColor colorWithHexString:@"ED2F3C"];
        [self addSubview:self.priceBadge];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.bounds.origin.y + 17, 27, 27)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.image = [UIImage imageNamed:@"mask.png"];
        [self addSubview: self.imageView];
        self.isImageSet = NO;
        
        // Try to redownload 5 times
        downloadSemaphore = dispatch_semaphore_create(5);
    }
    
    return self;
}

- (void)prepareForReuse {
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    //TODO: add ratings
    //self.imageView.image = [UIImage imageNamed:@"mask.png"];
    //[self.imageView.file cancel];
    //self.isImageSet = NO;
    [super prepareForReuse];
}

- (void)configureWithItem:(IMOItem *)item forIndex:(NSIndexPath *)indexPath withViewController:(UIViewController *)parentViewController {
    self.imageView.image = [UIImage imageNamed:@"mask.png"];
    [self downloadIconImage:item];
    
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(self.bounds.origin.x + 55, self.bounds.origin.y+9, 150, 30);
    self.textLabel.text = item.display_name;
    self.priceBadge.tag = indexPath.row;
    [self.priceBadge addTarget:parentViewController action:@selector(removeItemFromWishlist:) forControlEvents:UIControlEventTouchUpInside];

    CGSize textSize = [self.textLabel
                       textRectForBounds:self.textLabel.frame
                       limitedToNumberOfLines:self.textLabel.numberOfLines].size;
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, textSize.width, 30);
    self.detailTextLabel.text = item.summary;
    self.typeView.frame = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10, self.textLabel.frame.origin.y+10, 12, 12);
    if ([item.type isEqualToString:@"tweak"]) {
        self.typeView.image = [UIImage imageNamed:@"imods-assets-tweaks-icon.png"];
    } else {
        self.typeView.image = [UIImage imageNamed:@"imods-assets-themes-icon.png"];
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
