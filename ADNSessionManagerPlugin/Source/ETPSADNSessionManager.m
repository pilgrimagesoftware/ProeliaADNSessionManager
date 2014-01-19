//
//  ADNSessionManager.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/7/13.
//  Copyright (c) 2013 Pilgrimage Software. All rights reserved.
//

#import "ETPSADNSessionManager.h"

#import "SSKeychain.h"
#import <Snapper/Snapper.h>

#import "ETPSALoginViewController.h"

#import <ProeliaCore/ETCConstants.h>
#import <ProeliaCore/ETCVActiveEncounterService.h>

#import "ETPSASessionManagerServiceProtocol.h"
#import "ETPSAConstants.h"


@implementation ETPSADNSessionManager {

@private
    ETPSALoginViewController* _loginView;
    ETKMActiveEncounter* _encounter;
    NSString* _account;

    ETPSASecurityContext* _securityContext;

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
            _securityContext = [ETPSASecurityContext new];
            _securityContext.accessToken = accessToken;
            _securityContext.tokenType = @"Bearer";

            NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(ETPSASessionManagerService)];
            NSXPCConnection* connection = [[NSXPCConnection alloc] initWithServiceName:@"com.pilgrimagesoftware.proelia.xpc.ADNSessionManager"];
            connection.remoteObjectInterface = interface;
            [connection resume];

            id<ETPSASessionManagerService> sessionManager = (id<ETPSASessionManagerService>)connection.remoteObjectProxy;
            [sessionManager initializeSecurityContext:_securityContext
                                           completion:^(NSError* error) {
                                               if(error) {
                                                   [_delegate sessionManager:self
                                                         authorizationFailed:error];
                                               }
                                               else {
                                                   [_delegate sessionManager:self
                                                      authorizationSucceeded:_account
                                                                 accountType:[self name]];
                                               }
                                           }];
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
                       completion:^(ETPSASecurityContext* securityContext, NSError* error) {

                           if(securityContext) {
                               _securityContext = securityContext;

                               NSString *accessToken = securityContext.accessToken;
                               NSInteger userId = securityContext.userId;

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
                                      authorizationSucceeded:_account
                                                 accountType:[self name]];
                                   return;
                               }
                           }

                           // TODO?

                           [_delegate sessionManager:self
                                 authorizationFailed:error];
                       }];

        return YES;
    };

    [_delegate sessionManager:self
       presentCredentialsView:_loginView.view];
}

//- (ETKMActiveEncounterSession*)createSession {
//
//    NSDictionary* controlInfoDict = (@{
//                                       ETPSAControlChannelId : @"",
//                                       ETPSAInputChannelId : @"",
//                                       ETPSAChatChannelId : @"",
//                                       });
//    NSError* error = nil;
//    NSData* controlInfoData = [NSJSONSerialization dataWithJSONObject:controlInfoDict
//                                                              options:0
//                                                                error:&error];
//    if(controlInfoData == nil) {
//        NSLog(@"Unable to serialize JSON data: %@", error);
//        return nil;
//    }
//    NSString* controlInfo = [[NSString alloc] initWithData:controlInfoData
//                                                  encoding:NSUTF8StringEncoding];
//    ETKMActiveEncounterSession* session = [[ETCVActiveEncounterService sharedActiveEncounterService] createSessionForAccount:_account
//                                                                                                                 controlInfo:controlInfo
//                                                                                                                 inEncounter:_encounter];
//
//    return session;
//}

- (void)startSession:(void (^)(BOOL success, NSError* error))completionBlock {

    // check if the encounter has an ID
    if(_encounter.encounterIdentifier == nil) {
        _encounter.encounterIdentifier = [[NSUUID UUID] UUIDString];
    }

    // check if there is control info
    ETKMActiveEncounterSession* session = _encounter.currentSession;
    if(session == nil) {
        NSLog(@"Cannot start session; no current session set for encounter: %@", _encounter);
        NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                             code:ETPSAErrorCodeInvalidSession
                                         userInfo:(@{
                                                     ETPSAErrorMessage : @"Cannot start session; no current session set for encounter",
                                                     ETPSAErrorEncounter : _encounter,
                                                     })];
        completionBlock(NO, error);
        return;
    }

    // convert control info to JSON
    NSString* controlInfoString = session.controlInfo;
    NSData* controlInfoData = [controlInfoString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary* controlInfo = [NSJSONSerialization JSONObjectWithData:controlInfoData
                                                                options:0
                                                                  error:&error];
    NSMutableDictionary* updatedControlInfo = nil;
    if(controlInfo == nil) {
        // no control info, so we need to create the channels
        updatedControlInfo = [NSMutableDictionary new];

        if(![self createChannelsIfNecessary:session.sessionIdentifier
                                controlInfo:updatedControlInfo]) {
            NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                                 code:ETPSAErrorCodeChannelCreation
                                             userInfo:(@{
                                                         ETPSAErrorMessage : @"Error whlie creating channels",
                                                         ETPSAErrorEncounter : _encounter,
                                                         })];

            completionBlock(NO, error);
        }
    }
    else {
        // validate the control info
        updatedControlInfo = [controlInfo mutableCopy];

        if(![self validateChannel:[updatedControlInfo[ETPSAControlChannelId] integerValue]
                             type:ProeliaChannelTypeControl
             sessionIdentifier:session.sessionIdentifier
              encounterIdentifier:_encounter.encounterIdentifier]) {
            NSLog(@"Validation check failed for control channel '%@'; marking for replacement.", updatedControlInfo[ETPSAControlChannelId]);
            [updatedControlInfo removeObjectForKey:ETPSAControlChannelId];
        }
        if(![self validateChannel:[updatedControlInfo[ETPSAInputChannelId] integerValue]
                             type:ProeliaChannelTypeInput
                sessionIdentifier:session.sessionIdentifier
              encounterIdentifier:_encounter.encounterIdentifier]) {
            NSLog(@"Validation check failed for input channel '%@'; marking for replacement.", updatedControlInfo[ETPSAInputChannelId]);
            [updatedControlInfo removeObjectForKey:ETPSAInputChannelId];
        }
        if(![self validateChannel:[updatedControlInfo[ETPSAChatChannelId] integerValue]
                             type:ProeliaChannelTypeChat
                sessionIdentifier:session.sessionIdentifier
              encounterIdentifier:_encounter.encounterIdentifier]) {
            NSLog(@"Validation check failed for chat channel '%@'; marking for replacement.", updatedControlInfo[ETPSAChatChannelId]);
            [updatedControlInfo removeObjectForKey:ETPSAChatChannelId];
        }

        // create channels if necessary
        if(![self createChannelsIfNecessary:session.sessionIdentifier
                                controlInfo:updatedControlInfo]) {
            NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                                 code:ETPSAErrorCodeChannelCreation
                                             userInfo:(@{
                                                         ETPSAErrorMessage : @"Error whlie creating channels",
                                                         ETPSAErrorEncounter : _encounter,
                                                         })];

            completionBlock(NO, error);
        }
    }

    if(updatedControlInfo) {
        error = nil;
        NSData* controlInfoData = [NSJSONSerialization dataWithJSONObject:updatedControlInfo
                                                                  options:0
                                                                    error:&error];
        if(controlInfoData) {
            NSString* controlInfoString = [[NSString alloc] initWithData:controlInfoData
                                                                encoding:NSUTF8StringEncoding];

            session.controlInfo = controlInfoString;
        }
    }
    else {
        NSLog(@"No updated control info; something is wrong.");
    }
}

- (void)stopSession:(void (^)(NSError* error))completionBlock {

    // TODO: other stuff (delete/unsubscribe channels?)

    _encounter.currentSession = nil;
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


#pragma mark - Worker methods

- (BOOL)validateChannel:(NSInteger)channelId
                   type:(NSString*)type
      sessionIdentifier:(NSString*)sessionId
    encounterIdentifier:(NSString*)encounterId {

    NSLog(@"Validate channel %ld; type: %@", (long)channelId, type);

    if(channelId == 0) {
        NSLog(@"Channel ID is 0; definitely not valid.");
        return NO;
    }

    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(ETPSASessionManagerService)];
    NSXPCConnection* connection = [[NSXPCConnection alloc] initWithServiceName:@"com.pilgrimagesoftware.proelia.xpc.ADNSessionManager"];
    connection.remoteObjectInterface = interface;
    [connection resume];

    id<ETPSASessionManagerService> sessionManager = (id<ETPSASessionManagerService>)connection.remoteObjectProxy;

    NSLock* validationLock = [NSLock new];
    __block BOOL done = NO;
    __block BOOL channelValid = NO;

    NSLog(@"Invoking channel validation on XPC service.");
    [sessionManager validateChannel:channelId
                               type:type
                  sessionIdentifier:sessionId
                encounterIdentifier:encounterId
                    securityContext:_securityContext
                         completion:^(BOOL valid, NSError *error) {
                             if(error) {
                                 NSLog(@"Error response from channel validation: %@", error);
                             }

                             @synchronized(validationLock) {
                                 channelValid = valid;
                                 done = YES;
                             }
                         }];

    for(;;) {
        NSLog(@"Sleeping for half a second before checking channel validation status.");
        [NSThread sleepForTimeInterval:.5];

        @synchronized(validationLock) {
            NSLog(@"Lock obtained; done = %d", done);
            if(done)
                break;
        }
    }

    return channelValid;
}

- (BOOL)createChannelsIfNecessary:(NSString*)sessionId
                      controlInfo:(NSMutableDictionary*)controlInfo {

    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(ETPSASessionManagerService)];
    NSXPCConnection* connection = [[NSXPCConnection alloc] initWithServiceName:@"com.pilgrimagesoftware.proelia.xpc.ADNSessionManager"];
    connection.remoteObjectInterface = interface;
    [connection resume];

    id<ETPSASessionManagerService> sessionManager = (id<ETPSASessionManagerService>)connection.remoteObjectProxy;

    NSLock* controlLock = [NSLock new];
    __block BOOL abort = NO;

    // control channel
    if(controlInfo[ETPSAControlChannelId] == nil) {
        // - writable by GM (immutable)
        // - readable by user IDs (mutable)
        [sessionManager createChannel:sessionId
                        encounterName:_encounter.name
                           gameSystem:_encounter.gameSystemName
                  encounterIdentifier:_encounter.encounterIdentifier
                                 type:ProeliaChannelTypeControl
                              writers:@[@(_securityContext.userId)] // only the GM
                         writeMutable:NO
                              readers:@[@(_securityContext.userId)] // start with just the GM
                          readMutable:YES
                      securityContext:_securityContext
                           completion:^(NSInteger channelId, NSError *error) {

                               if(error) {
                                   NSLog(@"Error while creating control channel: %@", error);

                                   @synchronized(controlLock) {
                                       abort = YES;
                                   }
                                   return;
                               }

                               @synchronized(controlLock) {
                                   controlInfo[ETPSAControlChannelId] = @(channelId);
                               }
                           }];
    }

    // input channel
    if(controlInfo[ETPSAInputChannelId] == nil) {
        // - writable by any user (immutable)
        // - readable by GM (immutable)
        [sessionManager createChannel:sessionId
                        encounterName:_encounter.name
                           gameSystem:_encounter.gameSystemName
                  encounterIdentifier:_encounter.encounterIdentifier
                                 type:ProeliaChannelTypeInput
                              writers:@[]
                         writeMutable:NO
                              readers:@[@(_securityContext.userId)]
                          readMutable:NO
                      securityContext:_securityContext
                           completion:^(NSInteger channelId, NSError *error) {

                               if(error) {
                                   NSLog(@"Error while creating input channel: %@", error);

                                   @synchronized(controlLock) {
                                       abort = YES;
                                   }
                                   return;
                               }

                               @synchronized(controlLock) {
                                   controlInfo[ETPSAInputChannelId] = @(channelId);
                               }
                           }];
    }

    // chat channel
    if(controlInfo[ETPSAChatChannelId] == nil) {
        // - writable by user IDs (mutable)
        // - readable by user IDs (mutable)
        [sessionManager createChannel:sessionId
                        encounterName:_encounter.name
                           gameSystem:_encounter.gameSystemName
                  encounterIdentifier:_encounter.encounterIdentifier
                                 type:ProeliaChannelTypeChat
                              writers:@[@(_securityContext.userId)] // only the GM
                         writeMutable:YES
                              readers:@[@(_securityContext.userId)] // start with just the GM
                          readMutable:YES
                      securityContext:_securityContext
                           completion:^(NSInteger channelId, NSError *error) {

                               if(error) {
                                   NSLog(@"Error while creating chat channel: %@", error);

                                   @synchronized(controlLock) {
                                       abort = YES;
                                   }
                                   return;
                               }
                               
                               @synchronized(controlLock) {
                                   controlInfo[ETPSAChatChannelId] = @(channelId);
                               }
                           }];
    }
    
    // spin-lock and wait for channel creation to finish, or abort
    for(;;) {
        // sleep for half a second
        [NSThread sleepForTimeInterval:.5];
        
        @synchronized(controlLock) {
            
            // check abort
            if(abort)
                break;
            
            // check channels
            if(controlInfo[ETPSAControlChannelId] &&
               controlInfo[ETPSAInputChannelId] &&
               controlInfo[ETPSAChatChannelId])
                break;
        }
    }
    
    if(abort) {
        NSLog(@"Received abort signal during channel creation; aborting.");
        return NO;
    }
    
    return YES;
}

@end
