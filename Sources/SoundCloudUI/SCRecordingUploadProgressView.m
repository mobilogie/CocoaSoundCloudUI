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


@interface SCRecordingUploadProgressView ()
- (void)commonAwake;

@property (nonatomic, readwrite, assign) UIImageView *coverImageView;
@property (nonatomic, readwrite, assign) UILabel *titleLabel;
@property (nonatomic, readwrite, assign) UIView *line;
@property (nonatomic, readwrite, assign) UILabel *progressLabel;
@property (nonatomic, readwrite, assign) UIProgressView *progressView;
@property (nonatomic, readwrite, assign) UIButton *openTrackButton;
@property (nonatomic, readwrite, retain) NSDictionary *trackInfo;


#pragma mark Actions
- (void)openTrackButtonPressed;

#pragma mark Helpers
- (NSURL *)appURL;
- (NSURL *)appStoreURL;

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
    self.state = SCRecordingUploadProgressViewStateUploading;
    
    // Background Color
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    
    // Cover Image
    self.coverImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [self addSubview:self.coverImageView];
    
    // Title
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.titleLabel.text = nil;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [self addSubview:self.titleLabel];
    
    // HR
    self.line = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.line.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.0];
    [self addSubview:self.line];
    
    // Progress
    self.progressLabel = [[[UILabel alloc] init] autorelease];
    self.progressLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.progressLabel.text = SCLocalizedString(@"record_save_uploading", @"Uploading ...");
    [self addSubview:self.progressLabel];
    
    self.progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    self.progressView.progress = 0;
    [self addSubview:self.progressView];
    
    // Open Track Button
    self.openTrackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.openTrackButton.hidden = YES;
    [self.openTrackButton addTarget:self action:@selector(openTrackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.openTrackButton];
    
    // Shadow
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
@synthesize openTrackButton;
@synthesize state;
@synthesize trackInfo;

- (void)setState:(SCRecordingUploadProgressViewState)aState;
{
    if (state != aState) {
        state = aState;
        
        switch (state) {
            case SCRecordingUploadProgressViewStateFailed:
            {
                self.progressLabel.text = SCLocalizedString(@"record_save_upload_fail", @"Ok, that went wrong.");
                break;
            }
            
            case SCRecordingUploadProgressViewStateSuccess:
                self.progressLabel.text = SCLocalizedString(@"record_save_upload_success", @"Yay, that worked!");
                break;
                
            default:
                self.progressLabel.text = SCLocalizedString(@"record_save_uploading", @"Uploading ...");
                break;
        }
        [self setNeedsLayout];
    }
}

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

- (void)setTrackInfo:(NSDictionary *)aTrackInfo;
{
    if (trackInfo != aTrackInfo) {
        [aTrackInfo retain];
        [trackInfo release];
        trackInfo = aTrackInfo;
        
        [self setNeedsLayout];
    }
}

#pragma mark View Management
    
- (void)layoutSubviews;
{
    [super layoutSubviews];
        
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
    
    self.progressLabel.frame = CGRectMake(spacing, CGRectGetMaxY(self.line.frame) + spacing, 0, 0);
    [self.progressLabel sizeToFit];
    
    self.progressView.frame = CGRectMake(spacing, CGRectGetMaxY(self.progressLabel.frame) + 6, CGRectGetWidth(self.bounds) - 2 * spacing, 10);
    
    CGRect frame = self.frame;
    
    switch (self.state) {
        case SCRecordingUploadProgressViewStateSuccess:
        {
            self.openTrackButton.hidden = NO;
            
            NSURL *appURL = [self appURL];
            if (appURL) {
                [self.openTrackButton setTitle:SCLocalizedString(@"open_soundcloud_app", @"Open Track in SoundCloud App") forState:UIControlStateNormal];
            } else {
                [self.openTrackButton setTitle:SCLocalizedString(@"download_soundcloud_app", @"Get SoundCloud App") forState:UIControlStateNormal];
            }
            
            [self.openTrackButton sizeToFit];
            
            self.openTrackButton.center = CGPointMake(CGRectGetMidX(self.bounds),
                                                      CGRectGetMaxY(self.progressView.frame) + spacing + CGRectGetHeight(self.openTrackButton.frame));
            
            frame.size.height = CGRectGetMaxY(self.openTrackButton.frame) + spacing;
            break;
        }
        
        default:
            frame.size.height = CGRectGetMaxY(self.progressView.frame) + spacing;
            break;
    }
    
    self.frame = frame;
}

#pragma mark Actions

- (void)openTrackButtonPressed;
{
    NSURL *appURL = [self appURL];
    if (appURL) {
        [[UIApplication sharedApplication] openURL:appURL];
    } else {
        [[UIApplication sharedApplication] openURL:[self appStoreURL]];
    }
}

#pragma mark Helpers

- (NSURL *)appURL;
{
    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:tracks/%@", [trackInfo objectForKey:@"id"]]];
    NSURL *legacyTrackURL = [NSURL URLWithString:@"x-soundcloud:"];
    
    if ([[UIApplication sharedApplication] canOpenURL:trackURL]) {
        return trackURL;
    } else if ([[UIApplication sharedApplication] canOpenURL:legacyTrackURL]) {
        return legacyTrackURL;
    } else {
        return nil;
    }

}

- (NSURL *)appStoreURL;
{
    return [NSURL URLWithString:@"itms-apps://itunes.com/apps/SoundCloud"];
}

@end


