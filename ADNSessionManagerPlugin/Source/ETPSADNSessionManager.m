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

#import <ProeliaCore/ETCVActiveEncounterService.h>

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
@synthesize delegate = _delegate;

- (void)performAuthorization:(NSDictionary*)authInfo {

    // lookup previous account information
    if(_account) {
        NSString* accessToken = [SSKeychain passwordForService:ProeliaKeychainServiceName
                                                       account:_account];
        if(accessToken) {
            [_delegate sessionManager:self
               authorizationSucceeded:_account];
            //            completionBlock(_account, nil);
            return;
        }
    }

    NSString* clientId = authInfo[@"clientId"];
    NSString* grantSecret = authInfo[@"grantSecret"];
    NSString* scopes = authInfo[@"scopes"];

    if(_loginView == nil) {
        _loginView = [ETPSALoginViewController new];
    }

    //    if(_account) {
    //    _loginView.usernameField.stringValue = _account;
    //    }

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
                       completion:^(NSString *accessToken, NSInteger userId, NSError* error) {

                           if(accessToken && userId) {
                               // store in keychain
                               [SSKeychain setPassword:accessToken
                                            forService:ProeliaKeychainServiceName
                                               account:username];

                               _account = [@(userId) stringValue];

                               // finish
                               [_delegate sessionManager:self
                                  dismissCredentialsView:_loginView.view];

                               [_delegate sessionManager:self
                                  authorizationSucceeded:_account];
                           }
                           else {
                               // TODO?

                               [_delegate sessionManager:self
                                     authorizationFailed:error];
                               return;
                           }
                       }];

        return YES;
    };

    [_delegate sessionManager:self
       presentCredentialsView:_loginView.view];
}

- (ETKMActiveEncounterSession*)createSession {

    NSDictionary* controlInfoDict = (@{
                                       ETPSAControlChannelId : @"",
                                       ETPSAInputChannelId : @"",
                                       ETPSAChatChannelId : @"",
                                       });
    NSError* error = nil;
    NSData* controlInfoData = [NSJSONSerialization dataWithJSONObject:controlInfoDict
                                                              options:0
                                                                error:&error];
    if(controlInfoData == nil) {
        NSLog(@"Unable to serialize JSON data: %@", error);
        return nil;
    }
    NSString* controlInfo = [[NSString alloc] initWithData:controlInfoData
                                                  encoding:NSUTF8StringEncoding];
    ETKMActiveEncounterSession* session = [[ETCVActiveEncounterService sharedActiveEncounterService] createSessionForAccount:_account
                                                                                                                 controlInfo:controlInfo
                                                                                                                 inEncounter:_encounter];

    return session;
}

- (void)startSession:(void (^)())completionBlock {

    // check if there is control info

    // validate the control info

    // create channels if necessary
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
