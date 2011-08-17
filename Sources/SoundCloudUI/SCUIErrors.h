//
//  SCUIErrors.h
//  SoundCloudUI
//
//  Created by Tobias Kräntzer on 17.08.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

extern NSString * const SCUIErrorDomain;

extern NSInteger const SCUICanceledErrorCode;	

#define SC_CANCELED(error) ([error.domain isEqualToString:SCUIErrorDomain] && error.code == SCUICanceledErrorCode)
