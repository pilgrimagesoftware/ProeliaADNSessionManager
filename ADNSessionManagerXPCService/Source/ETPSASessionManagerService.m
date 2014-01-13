//
//  ETPSASessionManagerService.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSASessionManagerService.h"

#import "ETPSAAuthorizer.h"


@implementation ETPSASessionManagerService {

@private
    ETPSAAuthorizer* _authorizer;

}

- (void)authorize:(ETPSACredentials*)credentials
       completion:(void (^)(NSString* accessToken, NSInteger userId, NSError* error))completionBlock {

    NSLog(@"Performing authorization with credentials: %@", credentials);

    _authorizer = [[ETPSAAuthorizer alloc] initWithCredentials:credentials];

    [_authorizer authorize:^(NSString *accessToken, SNPToken *token, NSError *error) {

        if(accessToken && token) {
            completionBlock(accessToken, token.user.userId, nil);
        }
        else {
            completionBlock(nil, 0, error);
        }
    }];
}

@end
