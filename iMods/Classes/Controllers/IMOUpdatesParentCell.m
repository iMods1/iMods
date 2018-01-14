//
//  IMOUpdatesParentCell.m
//  iMods
//
//  Created by Yannis on 8/5/15.
//  Copyright (c) 2015 Ryan Feng. All rights reserved.
//
//item_id <- iid

#import "IMOUpdatesParentCell.h"
#import "IMODownloadManager.h"
#import "IMOItemManager.h"
#import "IMOItem.h"

@interface IMOUpdatesParentCell() {
    dispatch_semaphore_t downloadSemaphore;
}

@property (strong, nonatomic) NSNumber *downloadTries;
@property (strong, nonatomic) IMOItem* item;
@end

@implementation IMOUpdatesParentCell

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

BOOL installedTab = NO;

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)installedTab:(BOOL)selected {
    installedTab = selected;
}

- (id)initWithItem:(NSDictionary *)item forIndex:(NSIndexPath *)indexPath withViewController:(UIViewController *)parentViewController {
    NSError *error;
    self = [[IMOUpdatesParentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"updateCell"];
    self.item = item;
    self.backgroundColor = [UIColor colorWithHexString:@"ECECEC"];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, self.bounds.origin.y + 17, 27, 27)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    imageView.image = [UIImage imageNamed:@"mask.png"];
    [self addSubview: imageView];
    
    if (!installedTab) {
        [self downloadIconImageIMOITEM:item withView:imageView];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 80, self.bounds.origin.y+((installedTab) ? 15 : 9), 150, 30)];
        nameLabel.text = [self.item valueForKey: @"display_name"];
        nameLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17.0];
        nameLabel.textColor = [UIColor colorWithHexString:@"3D404B"];
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        CGSize textSize = [nameLabel
                           textRectForBounds:nameLabel.frame
                           limitedToNumberOfLines:nameLabel.numberOfLines].size;
        nameLabel.frame = CGRectMake(self.bounds.origin.x + 80, self.bounds.origin.y+((installedTab) ? 15 : 9), textSize.width, 30);
        [self addSubview: nameLabel];
        
        UILabel *detailSnippet = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 80, self.bounds.origin.y + 24, [UIScreen mainScreen].bounds.size.width - 100, 30)];
        detailSnippet.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0];
        detailSnippet.textColor = [UIColor darkGrayColor];
        NSString *translationBundle = [[NSBundle mainBundle] pathForResource:@"Translations" ofType:@"bundle"];
        NSBundle *ourBundle = [[NSBundle alloc] initWithPath:translationBundle];
        if ([self.item valueForKey:@"changelog"] != nil) {
            if ([[self.item valueForKey:@"changelog"] length] > 0)
                detailSnippet.text = NSLocalizedStringFromTableInBundle(@"click for changelog", nil, ourBundle, nil);
        } else {
            detailSnippet.text = NSLocalizedStringFromTableInBundle(@"no changelog available", nil, ourBundle, nil);
        }
        [self addSubview: detailSnippet];
        
        UILabel *versionBadge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
        versionBadge.layer.backgroundColor = [UIColor colorWithHexString:@"E19BA4"].CGColor;
        versionBadge.layer.cornerRadius = versionBadge.bounds.size.height / 2;
        versionBadge.center = CGPointMake(self.bounds.origin.x + [UIScreen mainScreen].bounds.size.width - (35 + 50), self.center.y+8);
        versionBadge.textAlignment = NSTextAlignmentCenter;
        versionBadge.font = [UIFont fontWithName:@"OpenSans-Bold" size:10.0];
        versionBadge.textColor = [UIColor colorWithHexString:@"ECECEC"];
        versionBadge.text = [self.item valueForKey: @"pkg_version_latest"];
        versionBadge.numberOfLines = 0;
        versionBadge.lineBreakMode = NSLineBreakByWordWrapping;
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width + 10, self.bounds.origin.y+((installedTab) ? 25 : 19), 12, 12)];
        typeView.contentMode = UIViewContentModeScaleAspectFit;
        typeView.clipsToBounds = YES;
        if ([[self.item valueForKey: @"type"] isEqualToString:@"theme"]) {
            typeView.image = [UIImage imageNamed:@"imods-assets-themes-icon.png"];
        } else {
            typeView.image = [UIImage imageNamed:@"imods-assets-tweaks-icon.png"];
        }
        [self addSubview: versionBadge];
        [self addSubview: typeView];
    } else {
        [self downloadIconImageIMOITEM:item withView:imageView];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x + 80, self.bounds.origin.y+((installedTab) ? 15 : 9), 150, 30)];
        nameLabel.text = [self.item valueForKey: @"display_name"];
        nameLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17.0];
        nameLabel.textColor = [UIColor colorWithHexString:@"3D404B"];
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview: nameLabel];
        
        CGSize textSize = [nameLabel
                           textRectForBounds:nameLabel.frame
                           limitedToNumberOfLines:nameLabel.numberOfLines].size;
        nameLabel.frame = CGRectMake(self.bounds.origin.x + 80, self.bounds.origin.y+((installedTab) ? 15 : 9), textSize.width, 30);
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width + 10, self.bounds.origin.y+((installedTab) ? 25 : 19), 12, 12)];
        typeView.contentMode = UIViewContentModeScaleAspectFit;
        typeView.clipsToBounds = YES;
        typeView.image = [UIImage imageNamed:@"imods-assets-tweaks-icon.png"];
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(typeView.frame.origin.x + typeView.frame.size.width + 5, self.bounds.origin.y+24, 70, 12)];
        versionLabel.text = [NSString stringWithFormat:@"v%@", [self.item valueForKey: @"pkg_version"]];
        versionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:10.0];
        versionLabel.textColor = [UIColor colorWithHexString:@"3E90C4"];
        versionLabel.numberOfLines = 0;
        versionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        if ([self.item valueForKey: @"type"]) {
            if ([[self.item valueForKey: @"type"] isEqualToString:@"theme"]) {
                typeView.image = [UIImage imageNamed:@"imods-assets-themes-icon.png"];
                versionLabel.textColor = [UIColor colorWithHexString:@"F69741"];
            }
        }
        [self addSubview: versionLabel];
        [self addSubview: typeView];
    }
    
    UIButton *priceBadge = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (installedTab) ? 75 : 58, 21)];
    priceBadge.layer.backgroundColor = [UIColor colorWithHexString:@"D65161"].CGColor;
    priceBadge.layer.cornerRadius = priceBadge.bounds.size.height / 2;
    priceBadge.center = CGPointMake((installedTab) ? self.bounds.origin.x + [UIScreen mainScreen].bounds.size.width - 48.5 : self.bounds.origin.x + [UIScreen mainScreen].bounds.size.width - 40, self.center.y+8);
    //priceBadge.textAlignment = NSTextAlignmentCenter;
    priceBadge.font = [UIFont fontWithName:@"OpenSans-Bold" size:11.0];
    //priceBadge.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    //priceBadge.text = (installedTab) ? @"UNINSTALL" : @"INSTALL";
    NSString *translationBundle = [[NSBundle mainBundle] pathForResource:@"Translations" ofType:@"bundle"];
    NSBundle *ourBundle = [[NSBundle alloc] initWithPath:translationBundle];
    [priceBadge setTitle:(installedTab) ? NSLocalizedStringFromTableInBundle(@"UNINSTALL", nil, ourBundle, nil) : NSLocalizedStringFromTableInBundle(@"INSTALL", nil, ourBundle, nil) forState:UIControlStateNormal];
    priceBadge.tag = indexPath.row;
    if (installedTab) {
        [priceBadge addTarget:parentViewController action:@selector(uninstallPackage:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [priceBadge addTarget:parentViewController action:@selector(installPackage:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:priceBadge];
    downloadSemaphore = dispatch_semaphore_create(5);
    //self.detailTextLabel.text = [item valueForKey: @"version"];
    return  self;
}

- (void)downloadIconImageIMOITEM:(NSDictionary *)item withView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_main_queue(), ^{
        IMODownloadManager *manager = [IMODownloadManager sharedDownloadManager];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(30, self.bounds.origin.y + 17, 27, 27);
        [self addSubview:indicator];
        [indicator startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [manager downloadIconFromDictionaryWithitem:item].then(^(NSDictionary *results) {
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                if ([results valueForKey:@"icon"]) {
                    UIImage *icon = [results valueForKey:@"icon"];
                    UIImage *mask = [UIImage imageNamed:@"mask.png"];
                    UIImage *maskedImage = [self maskImage:icon withMask:mask];
                    //TODO: fix mask
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = maskedImage;
                        imageView.layer.masksToBounds = YES;
                        imageView.layer.cornerRadius = imageView.frame.size.height / 2;
                        [self setNeedsDisplay];
                    });
                }
            }).catch(^{
                // If failed, try again.
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    dispatch_semaphore_wait(downloadSemaphore, DISPATCH_TIME_FOREVER);
                    [self downloadIconImageIMOITEM:item withView:imageView];
                });
            });
        });

    });
}

@end
