//
//  ETPSAAuthorizer.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/11/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Snapper/Snapper.h>

#import "ETPSACredentials.h"


typedef void (^ETPSAAuthorizationCompletionHandler)(NSString* accessToken, SNPToken* token, NSError* error);

@interface ETPSAAuthorizer : NSObject

@property (strong, nonatomic) ETPSACredentials* credentials;

- (instancetype)initWithCredentials:(ETPSACredentials*)credentials;

- (void)authorize:(ETPSAAuthorizationCompletionHandler)handler;

@end
