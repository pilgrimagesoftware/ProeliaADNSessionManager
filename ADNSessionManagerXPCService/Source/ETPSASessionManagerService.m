//
//  ETPSASessionManagerService.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSASessionManagerService.h"

#import "ETPSAAuthorizer.h"


@implementation ETPSASessionManagerService

- (void)authorize:(ETPSACredentials*)credentials
       completion:(void (^)(NSString* accessToken, NSString* username, NSError* error))completionBlock {

    NSLog(@"Performing authorization with credentials: %@", credentials);

    ETPSAAuthorizer* authorizer = [[ETPSAAuthorizer alloc] initWithCredentials:credentials];

    NSError* error = nil;
    SNPToken* token = nil;
    NSString* accessToken = [authorizer authorize:&token
                                            error:&error];

    if(accessToken && token) {
        completionBlock(accessToken, token.user.username, nil);
    }
    else {
        completionBlock(nil, nil, error);
    }
}

@end
