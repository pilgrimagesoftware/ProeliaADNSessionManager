//
//  ETPSAAuthorizer.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/11/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSAAuthorizer.h"



@implementation ETPSAAuthorizer {

@private
    NSOperationQueue* _loginQueue;

}

- (instancetype)initWithCredentials:(ETPSACredentials*)credentials {
    self = [super init];
    if(self) {
        _loginQueue = [NSOperationQueue new];
        _credentials = credentials;
    }

    return self;
}

- (void)authorize:(ETPSAAuthorizationCompletionHandler)handler {

    NSLog(@"Authorizing...");

    SNPPasswordLoginOperation* loginOp = [[SNPPasswordLoginOperation alloc] initWithClientId:_credentials.clientId
                                                                                 grantSecret:_credentials.grantSecret
                                                                                    username:_credentials.username
                                                                                    password:_credentials.password
                                                                                       scope:_credentials.scopes
                                                                                 finishBlock:^(NSString* accessToken, SNPToken* token, NSError* error) {

                                                                                     NSLog(@"Authorization response: accessToken: %@, token: %@, error: %@", accessToken, token, error);

                                                                                     if(accessToken && token) {
                                                                                         handler(accessToken, token, nil);
                                                                                     }
                                                                                     else {
                                                                                         handler(nil, nil, error);
                                                                                     }
                                                                                 }];
    [_loginQueue addOperation:loginOp];
}

@end
