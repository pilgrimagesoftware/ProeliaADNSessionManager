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

- (NSString*)authorize:(SNPToken**)token
                 error:(NSError**)errorPtr {

    NSLog(@"Authorizing...");

    __block NSString* accessToken = nil;

    SNPPasswordLoginOperation* loginOp = [[SNPPasswordLoginOperation alloc] initWithClientId:_credentials.clientId
                                                                                 grantSecret:_credentials.grantSecret
                                                                                    username:_credentials.username
                                                                                    password:_credentials.password
                                                                                       scope:_credentials.scopes
                                                                                 finishBlock:^(NSString* accessTokenString, SNPToken* tokenInfo, NSError* error) {

                                                                                     NSLog(@"Response: accessTokenString: %@, tokenInfo: %@, error: %@", accessTokenString, tokenInfo, error);

                                                                                     if(accessTokenString && tokenInfo) {
                                                                                         accessToken = accessTokenString;
                                                                                         if(token) {
                                                                                             *token = tokenInfo;
                                                                                         }
                                                                                     }
                                                                                     else {
                                                                                         if(errorPtr) {
                                                                                             *errorPtr = error;
                                                                                         }
                                                                                     }
                                                                                 }];
    [_loginQueue addOperation:loginOp];
    [loginOp waitUntilFinished];
    
    return accessToken;
}

@end
