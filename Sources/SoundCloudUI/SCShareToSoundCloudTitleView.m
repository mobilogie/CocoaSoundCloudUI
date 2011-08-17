//
//  SCShareToSoundCloudTitleView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 28.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "SCBundle.h"

#import "SCShareToSoundCloudTitleView.h"

@implementation SCShareToSoundCloudTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor blackColor];
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        
        UIImageView *cloudImageView = [[UIImageView alloc] init];
//        cloudImageView.backgroundColor = [UIColor greenColor];
        cloudImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
        cloudImageView.image = [SCBundle imageWithName:@"cloud"];
        [cloudImageView sizeToFit];
        cloudImageView.frame = CGRectMake(9, 7, CGRectGetWidth(cloudImageView.frame), CGRectGetHeight(cloudImageView.frame));
        [self addSubview:cloudImageView];
        [cloudImageView release];
        
        UIImageView *titleImageView = [[UIImageView alloc] init];
//        titleImageView.backgroundColor = [UIColor yellowColor];
        titleImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
        titleImageView.image = [SCBundle imageWithName:@"sharetosc"];
        [titleImageView sizeToFit];
        titleImageView.frame = CGRectMake(43, 7, CGRectGetWidth(titleImageView.frame), CGRectGetHeight(titleImageView.frame));
        [self addSubview:titleImageView];
        [titleImageView release];
    }
    return self;
}

- (void)drawRect:(CGRect)rect;
{
    CGRect topLineRect;
    CGRect gradientRect;
    CGRect bottomLineRect;
    CGRectDivide(self.bounds, &topLineRect, &gradientRect, 0.0, CGRectMinYEdge);
    CGRectDivide(gradientRect, &bottomLineRect, &gradientRect, 1.0, CGRectMaxYEdge);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 (CGFloat[]){1.0,0.40,0.0,1.0,  1.0,0.21,0.0,1.0},
                                                                 (CGFloat[]){0.0, 1.0},
                                                                 2);
    CGContextDrawLinearGradient(context, gradient, gradientRect.origin, CGPointMake(gradientRect.origin.x, CGRectGetMaxY(gradientRect)), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetFillColor(context, (CGFloat[]){0.0,0.0,0.0,1.0});
    CGContextFillRect(context, topLineRect);
}

@end
