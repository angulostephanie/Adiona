//
//  CustomClusterIconGenerator.m
//  safetyApp
//
//  Created by Amy Xiong on 7/27/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

/* Copied from "GMUDefaultClusterIconGenerator.m"*/

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "CustomClusterIconGenerator.h"

#define UIColorFromHEX(hexValue)                                         \
[UIColor colorWithRed:((CGFloat)((hexValue & 0xff0000) >> 16)) / 255.0 \
green:((CGFloat)((hexValue & 0x00ff00) >> 8)) / 255.0  \
blue:((CGFloat)((hexValue & 0x0000ff) >> 0)) / 255.0  \
alpha:1.0]



@implementation CustomClusterIconGenerator {
    NSCache *_iconCache;
    NSArray<NSNumber *> *_buckets;
    NSArray<UIImage *> *_backgroundImages;
    NSArray<UIColor *> *kGMUBucketBackgroundColors; // Default bucket background colors when no background images are set.
}

- (instancetype)init {
    if ((self = [super init]) != nil) {
        _iconCache = [[NSCache alloc] init];
        _buckets = @[ @10, @50, @100, @200, @1000 ];
        kGMUBucketBackgroundColors = @[
                                       UIColorFromHEX(0x0099cc),
                                       UIColorFromHEX(0x669900),
                                       UIColorFromHEX(0xff8800),
                                       UIColorFromHEX(0xcc0000),
                                       UIColorFromHEX(0x9933cc),
                                       ];
    }
    return self;
}

- (instancetype)initWithBuckets:(NSArray<NSNumber *> *)buckets
                      hexColors:(NSArray<NSNumber *> *)hexColors {
    if ((self = [self initWithBuckets:buckets]) != nil) {
        if (buckets.count != hexColors.count) {
            [NSException raise:NSInvalidArgumentException
                        format:@"buckets' size: %lu is not equal to hexColors' size: %lu",
             (unsigned long)buckets.count, (unsigned long)hexColors.count];
        }
        
        _iconCache = [[NSCache alloc] init];
        _buckets = @[ @10, @50, @100, @200, @1000 ];
        
        NSMutableArray<UIColor *> *convertedHEX = [[NSMutableArray alloc] init];
        for (int i = 0; i < hexColors.count; ++i) {
            [convertedHEX addObject:UIColorFromHEX([hexColors[i] intValue])];
        }
        kGMUBucketBackgroundColors = convertedHEX;
    }
    return self;
}

- (instancetype)initWithBuckets:(NSArray<NSNumber *> *)buckets
               backgroundImages:(NSArray<UIImage *> *)backgroundImages {
    if ((self = [self initWithBuckets:buckets]) != nil) {
        if (buckets.count != backgroundImages.count) {
            [NSException raise:NSInvalidArgumentException
                        format:@"buckets' size: %lu is not equal to backgroundImages' size: %lu",
             (unsigned long)buckets.count, (unsigned long)backgroundImages.count];
        }
        
        _backgroundImages = [backgroundImages copy];
    }
    return self;
}

- (instancetype)initWithBuckets:(NSArray<NSNumber *> *)buckets {
    if ((self = [self init]) != nil) {
        if (buckets.count == 0) {
            [NSException raise:NSInvalidArgumentException format:@"buckets are empty"];
        }
        for (int i = 0; i < buckets.count; ++i) {
            if (buckets[i].longLongValue <= 0) {
                [NSException raise:NSInvalidArgumentException
                            format:@"buckets have non positive values"];
            }
        }
        for (int i = 0; i < buckets.count - 1; ++i) {
            if (buckets[i].longLongValue >= buckets[i+1].longLongValue) {
                [NSException raise:NSInvalidArgumentException
                            format:@"buckets are not strictly increasing"];
            }
        }
        _buckets = [buckets copy];
    }
    return self;
}

- (UIImage *)iconForSize:(NSUInteger)size {
    NSUInteger bucketIndex = [self bucketIndexForSize:size];
    NSString *text;
    
    // If size is smaller to first bucket size, use the size as is otherwise round it down to the
    // nearest bucket to limit the number of cluster icons we need to generate.
    if (size < _buckets[0].unsignedLongValue) {
        text = [NSString stringWithFormat:@"%ld", (unsigned long)size];
    } else {
        text = [NSString stringWithFormat:@"%ld+", _buckets[bucketIndex].unsignedLongValue];
    }
    if (_backgroundImages != nil) {
        UIImage *image = _backgroundImages[bucketIndex];
        return [self iconForText:text withBaseImage:image];
    }
    return [self iconForText:text withBucketIndex:bucketIndex];
}

#pragma mark Private

// Finds the smallest bucket which is greater than |size|. If none exists return the last bucket
// index (i.e |_buckets.count - 1|).
- (NSUInteger)bucketIndexForSize:(NSUInteger)size {
    NSUInteger index = 0;
    while (index + 1 < _buckets.count && _buckets[index + 1].unsignedLongValue <= size) {
        ++index;
    }
    return index;
}

- (UIImage *)iconForText:(NSString *)text withBaseImage:(UIImage *)image {
    UIImage *icon = [_iconCache objectForKey:text];
    if (icon != nil) {
        return icon;
    }
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 NSParagraphStyleAttributeName : paragraphStyle,
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGRect textRect = CGRectInset(rect, (rect.size.width - textSize.width) / 2,
                                  (rect.size.height - textSize.height) / 2);
    [text drawInRect:CGRectIntegral(textRect) withAttributes:attributes];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_iconCache setObject:newImage forKey:text];
    return newImage;
}

- (UIImage *)iconForText:(NSString *)text withBucketIndex:(NSUInteger)bucketIndex {
    UIImage *icon = [_iconCache objectForKey:text];
    if (icon != nil) {
        return icon;
    }
    
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 NSParagraphStyleAttributeName : paragraphStyle,
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    CGSize textSize = [text sizeWithAttributes:attributes];
    
    // Create an image context with a square shape to contain the text (with more padding for
    // larger buckets).
    CGFloat rectDimension = MAX(20, MAX(textSize.width, textSize.height)) + 3 * bucketIndex + 6;
    CGRect rect = CGRectMake(0.f, 0.f, rectDimension, rectDimension);
    UIGraphicsBeginImageContext(rect.size);
    
    // Draw background circle.
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    bucketIndex = MIN(bucketIndex, kGMUBucketBackgroundColors.count - 1);
    UIColor *backColor = kGMUBucketBackgroundColors[bucketIndex];
    CGContextSetFillColorWithColor(ctx, backColor.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    CGContextRestoreGState(ctx);
    
    // Draw text.
    [[UIColor whiteColor] set];
    CGRect textRect = CGRectInset(rect, (rect.size.width - textSize.width) / 2,
                                  (rect.size.height - textSize.height) / 2);
    [text drawInRect:CGRectIntegral(textRect) withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_iconCache setObject:newImage forKey:text];
    return newImage;
}

@end
