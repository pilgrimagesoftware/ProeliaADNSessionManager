//
//  ETPSASessionManagerService.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ETPSACredentials, ETPSASecurityContext;
@class ETPSAParticipant, ETPSARegion;
@class ETPSAMap, ETPSAMapTile;

@protocol ETPSASessionManagerService <NSObject>

/**
 * Perform authorization, if necessary, with the service that backs this session manager.
 */
- (void)authorize:(ETPSACredentials*)credentials
       completion:(void (^)(ETPSASecurityContext* securityContext, NSError* error))completionBlock;
/**
 * Finish setting up the provided security context, such as filling in the apiId property, if
 * needed.
 */
- (void)initializeSecurityContext:(ETPSASecurityContext*)securityContext
                       completion:(void (^)(NSError* error))completionBlock;

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
           completion:(void (^)(NSInteger channelId, NSError* error))completionBlock;

- (void)validateChannel:(NSInteger)channelId
                   type:(NSString*)type
      sessionIdentifier:(NSString*)sessionId
    encounterIdentifier:(NSString*)encounterId
        securityContext:(ETPSASecurityContext*)securityContext
             completion:(void (^)(BOOL valid, NSError* error))completionBlock;

- (void)resetIfNecessary:(NSInteger)channelId
         securityContext:(ETPSASecurityContext*)securityContext
              completion:(void (^)(BOOL success, NSError* error))completionBlock;

- (void)uploadFile:(NSString*)name
              data:(NSData*)data
   securityContext:(ETPSASecurityContext*)securityContext
        completion:(void (^)(BOOL success, NSError* error))completionBlock;

- (void)sendParticipantInfo:(ETPSAParticipant*)participantInfo
                    channel:(NSInteger)channelId
            securityContext:(ETPSASecurityContext*)securityContext
                 completion:(void (^)(BOOL success, NSError* error))completionBlock;

- (void)sendRegionInfo:(ETPSARegion*)regionInfo
               channel:(NSInteger)channelId
       securityContext:(ETPSASecurityContext*)securityContext
            completion:(void (^)(BOOL success, NSError* error))completionBlock;

- (void)sendMapInfo:(ETPSAMap*)mapInfo
            channel:(NSInteger)channelId
    securityContext:(ETPSASecurityContext*)securityContext
         completion:(void (^)(BOOL success, NSError* error))completionBlock;

- (void)sendTileInfo:(ETPSAMapTile*)tileInfo
             channel:(NSInteger)channelId
     securityContext:(ETPSASecurityContext*)securityContext
          completion:(void (^)(BOOL success, NSError* error))completionBlock;

@end
