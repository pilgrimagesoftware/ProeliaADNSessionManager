//
//  ETPSAConstants.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const ProeliaKeychainServiceName;

extern NSString* const ProeliaChannelType;

extern NSString* const ProeliaChannelAnnotationTypeChannelType;
extern NSString* const ProeliaChannelAnnotationTypeKey;
extern NSString* const ProeliaChannelAnnotationSessionIdentifierKey;

extern NSString* const ProeliaChannelAnnotationTypeEncounter;
extern NSString* const ProeliaChannelAnnotationEncounterNameKey;
extern NSString* const ProeliaChannelAnnotationGameSystemKey;
extern NSString* const ProeliaChannelAnnotationEncounterIdentifierKey;

extern NSString* const ProeliaChannelTypeControl;
extern NSString* const ProeliaChannelTypeInput;
extern NSString* const ProeliaChannelTypeChat;

extern NSString* const ETPSAControlChannelId;
extern NSString* const ETPSAInputChannelId;
extern NSString* const ETPSAChatChannelId;

extern NSString* const ProeliaXPCErrorDomain;
extern NSString* const ProeliaXPCErrorMessage;

extern NSString* const ETPSAErrorDomain;
extern NSString* const ETPSAErrorMessage;
extern NSString* const ETPSAErrorEncounter;

typedef NS_ENUM(NSInteger, ETPSAErrorCode) {
    ETPSAErrorCodeInvalidSession,
    ETPSAErrorCodeChannelCreation,
    ETPSAErrorCodeChannelValidation,
};
