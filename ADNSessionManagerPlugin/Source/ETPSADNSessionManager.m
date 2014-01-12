//
//  ADNSessionManager.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/7/13.
//  Copyright (c) 2013 Pilgrimage Software. All rights reserved.
//

#import "ETPSADNSessionManager.h"

#import "SSKeychain.h"

#import "ETPSALoginViewController.h"

#import "ETPSASessionManagerServiceProtocol.h"
#import "ETPSAConstants.h"


@implementation ETPSADNSessionManager {

@private
    ETPSALoginViewController* _loginView;
    ETKMActiveEncounter* _encounter;
    NSString* _account;

}

#pragma mark - ETKPPlugin method implementations

- (NSString *)name {
    return [ETPSADNSessionManager name];
}

+ (NSString *)name {
    return @"adnsm";
}

+ (NSString *)shortLabel {
    return @"App.net";
}

- (NSString *)shortLabel {
    return [ETPSADNSessionManager shortLabel];
}

+ (NSString *)label {
    return @"App.net Session Manager";
}

- (NSString *)label {
    return [ETPSADNSessionManager label];
}


#pragma mark - ETKSSessionManager method implementations

@synthesize encounter = _encounter;
@synthesize account = _account;

- (NSViewController*)authorizationViewController {

    if(_loginView == nil) {
        _loginView = [ETPSALoginViewController new];
    }

    return _loginView;
}

- (void)performAuthorization:(NSDictionary*)authInfo
              withCompletion:(void (^)(NSString* account, NSError* error))completionBlock {

    // lookup previous account information
    if(_account) {
        NSString* accessToken = [SSKeychain passwordForService:ProeliaKeychainServiceName
                                                       account:_account];
        if(accessToken) {
            completionBlock(_account, nil);
            return;
        }
    }

    NSString* clientId = authInfo[@"clientId"];
    NSString* grantSecret = authInfo[@"grantSecret"];
    NSString* scopes = authInfo[@"scopes"];

    if(_account) {
    _loginView.usernameField.stringValue = _account;
    }
    
    _loginView.loginHandler = ^BOOL(NSString* username, NSString* password) {

        // XPC call
        NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(ETPSASessionManagerService)];
        NSXPCConnection* connection = [[NSXPCConnection alloc] initWithServiceName:@"com.pilgrimagesoftware.proelia.xpc.ADNSessionManager"];
        connection.remoteObjectInterface = interface;
        [connection resume];

        ETPSACredentials* credentials = [ETPSACredentials new];
        credentials.clientId = clientId;
        credentials.grantSecret = grantSecret;
        credentials.scopes = scopes;
        credentials.username = username;
        credentials.password = password;

        id<ETPSASessionManagerService> sessionManager = (id<ETPSASessionManagerService>)connection.remoteObjectProxy;
        [sessionManager authorize:credentials
                       completion:^(NSString *accessToken, NSString* username, NSError* error) {

                           if(accessToken && username) {
                               // store in keychain
                               [SSKeychain setPassword:accessToken
                                            forService:ProeliaKeychainServiceName
                                               account:username];

                               _account = username;

                               // call block
                               completionBlock(username, nil);
                           }
                           else {
                               // TODO?

                               completionBlock(nil, error);
                               return;
                           }
                       }];

        return YES;
    };
}

- (void)startSession:(ETKMActiveEncounter*)encounter
          completion:(void (^)())completionBlock {

}

- (NSArray*)allPlayers {

    NSMutableArray* players = [NSMutableArray new];

    // TODO

    return [players copy];
}

- (void)addPlayer:(id)playerInfo
       completion:(void (^)())completionBlock {

}

- (void)removePlayer:(id)playerInfo
          completion:(void (^)())completionBlock {

}

- (void)postChatMessage:(NSString*)message
             completion:(void (^)())completionBlock {

}

- (void)sendPrivateMessage:(NSString*)message
                  toPlayer:(id)playerInfo
                completion:(void (^)())completionBlock {
    
}

- (void)sendControlMessage:(id)message
                completion:(void (^)())completionBlock {
    
}

@end
