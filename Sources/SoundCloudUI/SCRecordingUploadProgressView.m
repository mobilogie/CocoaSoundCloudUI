/*
 * Copyright 2010, 2011 nxtbgthng for SoundCloud Ltd.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * For more information and documentation refer to
 * http://soundcloud.com/api
 * 
 */

#import "QuartzCore+SoundCloudAPI.h"
#import "UIImage+SoundCloudAPI.h"
#import "UIDevie+SoundCloudUI.h"

#import "SCBundle.h"

#import "SCRecordingUploadProgressView.h"

#define SPACING 10.0
#define COVER_IMAGE_SIZE 40

typedef enum SCRecordingUploadProgressViewState {
    SCRecordingUploadProgressViewStateUploading = 0,
    SCRecordingUploadProgressViewStateSuccess,
    SCRecordingUploadProgressViewStateFail
} SCRecordingUploadProgressViewState;

@interface SCRecordingUploadProgressView ()
- (void)commonAwake;

@property (nonatomic, readwrite, assign) UIImageView *coverImageView;
@property (nonatomic, readwrite, assign) UILabel *titleLabel;
@property (nonatomic, readwrite, assign) UIView *line;
@property (nonatomic, readwrite, assign) UILabel *progressLabel;
@property (nonatomic, readwrite, assign) UIProgressView *progressView;
@property (nonatomic, readwrite, assign) UIButton *cancelButton;

@property (nonatomic, readwrite, assign) UIImageView *successImageView;
@property (nonatomic, readwrite, assign) UILabel *successLabel;

@property (nonatomic, readwrite, assign) SCRecordingUploadProgressViewState state;

@end

@implementation SCRecordingUploadProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonAwake];
    }
    return self;
}

- (void)commonAwake;
{
    self.backgroundColor = [UIColor whiteColor];
//    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.coverImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    [self addSubview:self.coverImageView];
    
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.titleLabel.text = nil;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [self addSubview:self.titleLabel];
    
    self.line = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    self.line.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.0];
    [self addSubview:self.line];
    
    self.progressLabel = [[[UILabel alloc] init] autorelease];
    self.progressLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.progressLabel.text = SCLocalizedString(@"record_save_uploading", @"Uploading ...");
    [self addSubview:self.progressLabel];
    
    self.progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    self.progressView.progress = 0;
    [self addSubview:self.progressView];
    
    self.cancelButton = [[[UIButton alloc] init] autorelease];
    [self.cancelButton setImage:[SCBundle imageWithName:@"cancel_dark"] forState:UIControlStateNormal];
    [self.cancelButton setImage:[SCBundle imageWithName:@"cancelUpload"] forState:UIControlStateHighlighted];
    [self addSubview:self.cancelButton];
    
    
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(3, 5);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.8;
}


#pragma mark Accessors

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize line;
@synthesize progressLabel;
@synthesize progressView;
@synthesize cancelButton;
@synthesize successImageView;
@synthesize successLabel;
@synthesize state;

- (void)setTitle:(NSString *)aTitle;
{
    self.titleLabel.text = aTitle;
    [self setNeedsLayout];
}

- (void)setCoverImage:(UIImage *)aCoverImage;
{
    CGFloat imageSize;
    
    if ([UIDevice isIPad]) {
        imageSize = 80;
    } else {
        imageSize = COVER_IMAGE_SIZE;
    }
    
    self.coverImageView.image = [aCoverImage imageByResizingTo:CGSizeMake(imageSize, imageSize) forRetinaDisplay:YES];
    [self.coverImageView sizeToFit];
    [self setNeedsLayout];
    
}

- (void)setSuccess:(BOOL)success;
{
    self.state = SCRecordingUploadProgressViewStateSuccess;
    
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
    [self.progressLabel removeFromSuperview];
    self.progressLabel = nil;
    
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;
    
    self.successLabel = [[[UILabel alloc] init] autorelease];
    if (success) {
        self.successImageView = [[[UIImageView alloc] initWithImage:[SCBundle imageWithName:@"success"]] autorelease];
        self.successLabel.text = SCLocalizedString(@"record_save_upload_success", @"Yay, that worked!");
        
    } else {
        self.successImageView = [[[UIImageView alloc] initWithImage:[SCBundle imageWithName:@"fail"]] autorelease];
        self.successLabel.text = SCLocalizedString(@"record_save_upload_fail", @"Ok, that went wrong.");
    }
    [self.successImageView sizeToFit];
    [self addSubview:self.successImageView];
    
    self.successLabel.textAlignment = UITextAlignmentCenter;
    self.successLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [self.successLabel sizeToFit];
    [self addSubview:self.successLabel];
    
    [self setNeedsLayout];
}


#pragma mark View Management
    
- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    //    NSLog(@"%s self.bounds: %@", __FUNCTION__, NSStringFromCGRect(self.bounds));
    
    CGFloat spacing;
    
    if ([UIDevice isIPad]) {
        spacing = 20.0;
    } else {
        spacing = SPACING;
    }
    
    
    if (self.coverImageView.image) {
        
        CGFloat imageSize;
        
        if ([UIDevice isIPad]) {
            imageSize = 80;
        } else {
            imageSize = COVER_IMAGE_SIZE;
        }
        
        self.coverImageView.frame = CGRectMake(spacing, spacing, imageSize, imageSize);
        
        CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds) - 2 * spacing - CGRectGetMaxX(self.coverImageView.frame),
                                    imageSize);
        CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                           constrainedToSize:maxSize
                                               lineBreakMode:self.titleLabel.lineBreakMode];
        
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame) + spacing,
                                           spacing,
                                           textSize.width,
                                           textSize.height);
        
    } else {
        CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds) - 2 * spacing,
                                    COVER_IMAGE_SIZE);
        CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                           constrainedToSize:maxSize
                                               lineBreakMode:self.titleLabel.lineBreakMode];
        
        self.titleLabel.frame = CGRectMake(spacing,
                                           spacing,
                                           textSize.width,
                                           textSize.height);
    }
    
    
    self.line.frame = CGRectMake(spacing,
                                 MAX(CGRectGetMaxY(self.titleLabel.frame),
                                     CGRectGetMaxY(self.coverImageView.frame)) + spacing,
                                 CGRectGetWidth(self.bounds) - 2 * spacing,
                                 1);
    
    switch (self.state) {
        case SCRecordingUploadProgressViewStateSuccess:
        case SCRecordingUploadProgressViewStateFail:
        {
            self.successImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.line.frame) + SPACING + CGRectGetHeight(self.successImageView.frame) / 2.0);
            
            self.successLabel.frame = CGRectMake(spacing, CGRectGetMaxY(self.successImageView.frame) + SPACING, CGRectGetWidth(self.bounds) - 2 * spacing, CGRectGetHeight(self.successLabel.frame));
            
            CGRect frame = self.frame;
            frame.size.height = CGRectGetMaxY(self.successLabel.frame) + spacing;
            self.frame = frame;
            break;
        }
            
        default:
        {
            self.cancelButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - spacing - 30, CGRectGetMaxY(self.line.frame) + spacing, 30, 30);
            
            self.progressLabel.frame = CGRectMake(spacing, CGRectGetMaxY(self.line.frame) + spacing, 0, 0);
            [self.progressLabel sizeToFit];
            
            self.progressView.frame = CGRectMake(spacing, CGRectGetMaxY(self.progressLabel.frame) + 6, CGRectGetWidth(self.bounds) - 30 - 3 * spacing, 10);
            
            CGRect frame = self.frame;
            frame.size.height = CGRectGetMaxY(self.progressView.frame) + spacing;
            self.frame = frame;
            break;
        }
            break;
    }
}


@end
