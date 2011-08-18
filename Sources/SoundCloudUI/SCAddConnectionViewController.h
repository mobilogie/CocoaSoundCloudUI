//
//  SCAddConnectionViewController.h
//  Soundcloud
//
//  Created by Gernot Poetsch on 30.11.10.
//  Copyright 2010 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCAddConnectionViewControllerDelegate.h"

@class SCAccount;

@interface SCAddConnectionViewController : UIViewController <UIWebViewDelegate> {
    
    id<SCAddConnectionViewControllerDelegate> delegate;
    
    SCAccount *account;
    NSString *service;
    NSURL *authorizeURL;
    UIWebView *webView;
    
    BOOL loading;
}

- (id)initWithService:(NSString *)service account:(SCAccount *)anAccount delegate:(id<SCAddConnectionViewControllerDelegate>)delegate;
- (id)initWithService:(NSString *)service delegate:(id<SCAddConnectionViewControllerDelegate>)delegate;

@end
