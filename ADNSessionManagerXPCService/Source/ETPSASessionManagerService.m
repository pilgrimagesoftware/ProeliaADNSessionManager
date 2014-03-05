//
//  ETPSASessionManagerService.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSASessionManagerService.h"

#import <Snapper/Snapper.h>

#import "ETPSAAuthorizer.h"

#import "ETPSAParticipant.h"
#import "ETPSARegion.h"
#import "ETPSAMap.h"
#import "ETPSAMapTile.h"

#import "ETPSAConstants.h"


@implementation ETPSASessionManagerService {

@private
    ETPSAAuthorizer* _authorizer;
    NSOperationQueue* _operationQueue;

}

- (id)init {
    self = [super init];
    if(self) {
        _operationQueue = [NSOperationQueue new];
    }

    return self;
}


#pragma mark - API

- (void)authorize:(ETPSACredentials*)credentials
       completion:(void (^)(ETPSASecurityContext* securityContext, NSError* error))completionBlock {

    NSLog(@"Performing authorization with credentials: %@", credentials);

    _authorizer = [[ETPSAAuthorizer alloc] initWithCredentials:credentials];

    [_authorizer authorize:^(NSString *accessToken, SNPToken *token, NSError *error) {

        if(accessToken && token) {
            ETPSASecurityContext* context = [ETPSASecurityContext new];
            context.accessToken = accessToken;
            context.userId = token.user.userId;
            context.tokenType = @"Bearer";

            SNPAccount* account = [[SNPAccountManager sharedAccountManager] createAccountWithName:token.user.name
                                                                                         username:token.user.username
                                                                                           userId:token.user.userId
                                                                                      accessToken:accessToken
                                                                                        tokenType:context.tokenType];
            context.apiId = account.accountId;

            completionBlock(context, nil);
        }
        else {
            completionBlock(nil, error);
        }
    }];
}

- (void)initializeSecurityContext:(ETPSASecurityContext*)securityContext
                       completion:(void (^)(NSError* error))completionBlock {

    SNPCurrentTokenOperation* tokenOp = [[SNPCurrentTokenOperation alloc] initWithAccessToken:securityContext.accessToken
                                                                                    tokenType:securityContext.tokenType
                                                                                  finishBlock:^(SNPResponse *response) {

                                                                                      if(response.metadata.errorId) {
                                                                                          NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                                                                                                               code:[response.metadata.errorId integerValue]
                                                                                                                           userInfo:(@{
                                                                                                                                       ETPSAErrorMessage : response.metadata.errorMessage,
                                                                                                                                       })];

                                                                                          completionBlock(error);
                                                                                          return;
                                                                                      }

                                                                                      SNPToken* token = response.data;

                                                                                      securityContext.name = token.user.name;
                                                                                      securityContext.username = token.user.username;
                                                                                      securityContext.userId = token.user.userId;

                                                                                      SNPAccount* account = [[SNPAccountManager sharedAccountManager] createAccountWithName:securityContext.name
                                                                                                                                                                   username:securityContext.username
                                                                                                                                                                     userId:securityContext.userId
                                                                                                                                                                accessToken:securityContext.accessToken
                                                                                                                                                                  tokenType:securityContext.tokenType];
                                                                                      securityContext.apiId = account.accountId;

                                                                                      completionBlock(nil);
                                                                                  }];
    [_operationQueue addOperation:tokenOp];
}

- (void)createChannel:(NSString*)sessionId
        encounterName:(NSString*)encounterName
           gameSystem:(NSString*)gameSystem
  encounterIdentifier:(NSString*)encounterId
                 type:(NSString*)type
              writers:(NSArray*)writers
         writeMutable:(BOOL)writeMutable
              readers:(NSArray*)readers
          readMutable:(BOOL)readMutable
      securityContext:(ETPSASecurityContext*)securityContext
           completion:(void (^)(NSInteger channelId, NSError* error))completionBlock {

    SNPACL* writersACL = [self configureACLWithUsers:writers
                                          mutability:writeMutable];

    SNPACL* readersACL = [self configureACLWithUsers:readers
                                          mutability:readMutable];

    NSString* accountId = [self resolveAccountId:securityContext];

    SNPAnnotation* channelTypeAnnotation = [SNPAnnotation new];
    channelTypeAnnotation.type = ProeliaChannelAnnotationTypeChannelType;
    channelTypeAnnotation.value = (@{
                                     ProeliaChannelAnnotationTypeKey : type,
                                     ProeliaChannelAnnotationSessionIdentifierKey : sessionId,
                                     });

    SNPAnnotation* encounterAnnotation = [SNPAnnotation new];
    encounterAnnotation.type = ProeliaChannelAnnotationTypeEncounter;
    encounterAnnotation.value = (@{
                                   ProeliaChannelAnnotationEncounterNameKey : encounterName,
                                   ProeliaChannelAnnotationGameSystemKey : gameSystem,
                                   ProeliaChannelAnnotationEncounterIdentifierKey : encounterId,
                                   });

    SNPCreateChannelOperation* createOp = [[SNPCreateChannelOperation alloc] initWithType:ProeliaChannelType
                                                                                  readers:readersACL
                                                                                  writers:writersACL
                                                                              annotations:(@[
                                                                                             channelTypeAnnotation,
                                                                                             encounterAnnotation,
                                                                                             ])
                                                                                accountId:accountId
                                                                              finishBlock:^(SNPResponse *response) {

                                                                                  if(response.metadata.errorId) {
                                                                                      NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                                                                                                           code:[response.metadata.errorId integerValue]
                                                                                                                       userInfo:(@{
                                                                                                                                   ETPSAErrorMessage : response.metadata.errorMessage,
                                                                                                                                   })];

                                                                                      completionBlock(0, error);
                                                                                      return;
                                                                                  }

                                                                                  SNPChannel* channel = response.data;
                                                                                  NSInteger channelId = channel.channelId;

                                                                                  completionBlock(channelId, nil);
                                                                              }];
    [_operationQueue addOperation:createOp];
}

- (void)validateChannel:(NSInteger)channelId
                   type:(NSString*)type
      sessionIdentifier:(NSString*)sessionId
    encounterIdentifier:(NSString*)encounterId
        securityContext:(ETPSASecurityContext*)securityContext
             completion:(void (^)(BOOL, NSError *))completionBlock {

    NSLog(@"Validate channel: %ld; type: %@; session-id: %@, encounter-id: %@", (long)channelId, type, sessionId, encounterId);

    NSString* accountId = [self resolveAccountId:securityContext];

    NSLog(@"Calling ADN get channel API with account: %@", accountId);
    SNPGetChannelOperation* fetchOp = [[SNPGetChannelOperation alloc] initWithChannelId:channelId
                                                                              accountId:accountId
                                                                            finishBlock:^(SNPResponse *response) {

                                                                                if(response.metadata.errorId) {
                                                                                    NSLog(@"Error while invoking ADN get channel API: %@", response.metadata.errorId);
                                                                                    NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                                                                                                         code:[response.metadata.errorId integerValue]
                                                                                                                     userInfo:(@{
                                                                                                                                 ETPSAErrorMessage : response.metadata.errorMessage,
                                                                                                                                 })];

                                                                                    completionBlock(NO, error);
                                                                                    return;
                                                                                }

                                                                                SNPChannel* channel = response.data;
                                                                                NSLog(@"Got channel: %@", channel);

                                                                                // check channel type
                                                                                NSString* channelType = channel.type;
                                                                                if(![channelType isEqualToString:ProeliaChannelType]) {
                                                                                    NSLog(@"Channel type is incorrect: got '%@', expected '%@'", channelType, ProeliaChannelType);
                                                                                    NSError* error = [NSError errorWithDomain:ETPSAErrorMessage
                                                                                                                         code:ETPSAErrorCodeChannelValidation
                                                                                                                     userInfo:(@{
                                                                                                                                 ETPSAErrorMessage : NSLocalizedString(@"Channel type is incorrect", nil),
                                                                                                                                 })];
                                                                                    completionBlock(NO, error);
                                                                                    return;
                                                                                }

                                                                                // check for proper annotation with type value
                                                                                NSArray* annotations = channel.annotations;
                                                                                if([annotations count] == 0) {
                                                                                    NSLog(@"No annotations found on channel.");
                                                                                    NSError* error = [NSError errorWithDomain:ETPSAErrorMessage
                                                                                                                         code:ETPSAErrorCodeChannelValidation
                                                                                                                     userInfo:(@{
                                                                                                                                 ETPSAErrorMessage : NSLocalizedString(@"Channel is missing expected annotations", nil),
                                                                                                                                 })];
                                                                                    completionBlock(NO, error);
                                                                                    return;
                                                                                }

                                                                                BOOL validType = NO;
                                                                                BOOL validEncounterInfo = NO;

                                                                                for(SNPAnnotation* annotation in annotations) {
                                                                                    NSString* annoType = annotation.type;
                                                                                    if([annoType isEqualToString:ProeliaChannelAnnotationTypeChannelType]) {
                                                                                        NSLog(@"Checking channel type annotation.");
                                                                                        if([annotation.value[ProeliaChannelAnnotationTypeKey] isEqualToString:type] &&
                                                                                           [annotation.value[ProeliaChannelAnnotationSessionIdentifierKey] isEqualToString:sessionId]) {
                                                                                            NSLog(@"Found correct type and session identifier on channel type annotation.");
                                                                                            validType = YES;
                                                                                        }
                                                                                    }
                                                                                    else if([annoType isEqualToString:ProeliaChannelAnnotationTypeEncounter]) {
                                                                                        NSLog(@"Checking channel encounter annotation.");
                                                                                        if(annotation.value[ProeliaChannelAnnotationEncounterNameKey] &&
                                                                                           annotation.value[ProeliaChannelAnnotationGameSystemKey] &&
                                                                                           [annotation.value[ProeliaChannelAnnotationEncounterIdentifierKey] isEqualToString:encounterId]) {
                                                                                            NSLog(@"Found correct encounter, game system and identifier on channel encounter annotation.");
                                                                                            validEncounterInfo = YES;
                                                                                        }
                                                                                    }
                                                                                }

                                                                                if(!validType) {
                                                                                    NSError* error = [NSError errorWithDomain:ETPSAErrorMessage
                                                                                                                         code:ETPSAErrorCodeChannelValidation
                                                                                                                     userInfo:(@{
                                                                                                                                 ETPSAErrorMessage : NSLocalizedString(@"Channel type annotation is missing or invalid", nil),
                                                                                                                                 })];
                                                                                    completionBlock(NO, error);
                                                                                    return;
                                                                                }
                                                                                if(!validEncounterInfo) {
                                                                                    NSError* error = [NSError errorWithDomain:ETPSAErrorMessage
                                                                                                                         code:ETPSAErrorCodeChannelValidation
                                                                                                                     userInfo:(@{
                                                                                                                                 ETPSAErrorMessage : NSLocalizedString(@"Channel encounter annotation is missing or invalid", nil),
                                                                                                                                 })];
                                                                                    completionBlock(NO, error);
                                                                                    return;
                                                                                }

                                                                                completionBlock(YES, nil);
                                                                            }];
    [_operationQueue addOperation:fetchOp];
}

- (void)resetIfNecessary:(NSInteger)channelId
         securityContext:(ETPSASecurityContext*)securityContext
              completion:(void (^)(BOOL success, NSError* error))completionBlock {

    NSString* accountId = [self resolveAccountId:securityContext];

    NSLog(@"Calling ADN get channel API with account: %@", accountId);
    SNPGetChannelOperation* fetchOp = [[SNPGetChannelOperation alloc] initWithChannelId:channelId
                                                                              accountId:accountId
                                                                            finishBlock:^(SNPResponse *response) {

                                                                                if(response.metadata.errorId) {
                                                                                    NSLog(@"Error while invoking ADN get channel API: %@", response.metadata.errorId);
                                                                                    NSError* error = [NSError errorWithDomain:ETPSAErrorDomain
                                                                                                                         code:[response.metadata.errorId integerValue]
                                                                                                                     userInfo:(@{
                                                                                                                                 ETPSAErrorMessage : response.metadata.errorMessage,
                                                                                                                                 })];

                                                                                    completionBlock(NO, error);
                                                                                    return;
                                                                                }

                                                                                SNPChannel* channel = response.data;
                                                                                NSLog(@"Got channel: %@", channel);

                                                                                NSInteger messageCount = channel.
                                                                            }];
    [_operationQueue addOperation:fetchOp];
}

- (void)uploadFile:(NSString*)name
              data:(NSData*)data
   securityContext:(ETPSASecurityContext*)securityContext
        completion:(void (^)(BOOL success, NSError* error))completionBlock {

}

- (void)sendParticipantInfo:(ETPSAParticipant*)participantInfo
                    channel:(NSInteger)channelId
            securityContext:(ETPSASecurityContext*)securityContext
                 completion:(void (^)(BOOL success, NSError* error))completionBlock {

}

- (void)sendRegionInfo:(ETPSARegion*)regionInfo
               channel:(NSInteger)channelId
       securityContext:(ETPSASecurityContext*)securityContext
            completion:(void (^)(BOOL success, NSError* error))completionBlock {

}

- (void)sendMapInfo:(ETPSAMap*)mapInfo
            channel:(NSInteger)channelId
    securityContext:(ETPSASecurityContext*)securityContext
         completion:(void (^)(BOOL success, NSError* error))completionBlock {

}

- (void)sendTileInfo:(ETPSAMapTile*)tileInfo
             channel:(NSInteger)channelId
     securityContext:(ETPSASecurityContext*)securityContext
          completion:(void (^)(BOOL success, NSError* error))completionBlock {

}


#pragma mark - Worker methods

- (SNPACL*)configureACLWithUsers:(NSArray*)users
                      mutability:(BOOL)mutable {
    
    SNPACL* acl = [SNPACL new];
    
    acl.immutable = !mutable;
    acl.userIds = @[]; 
    
    // no array specified at all means "public"
    if(users == nil) {
        acl.public_ = YES;
    }
    // empty array means "any_user"
    else if([users count] == 0) {
        acl.anyUser = YES;
    }
    // non-empty array means specific users
    else {
        acl.userIds = users;
    }
    
    return acl;
}

- (NSString*)resolveAccountId:(ETPSASecurityContext*)securityContext {
    
    SNPAccountManager* manager = [SNPAccountManager sharedAccountManager];
    
    // check if account already exists (because it's possible that this XPC process was killed,
    // thus losing any account information)
    NSString* snapperId = securityContext.apiId;
    SNPAccount* account = nil;
    
    if(snapperId) {
        account = [manager accountForId:snapperId];
    }
    
    if(account == nil) {
        // no ID, so create one with info from the context
        account = [manager createAccountWithName:securityContext.name
                                        username:securityContext.username
                                          userId:securityContext.userId
                                     accessToken:securityContext.accessToken
                                       tokenType:@"Bearer"];
    }
    
    return account.accountId;
}

@end
