//
//  ETPSASecurityContext.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/14/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETPSASecurityContext : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString* accessToken;
@property (nonatomic, copy) NSString* tokenType;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString* apiId;

@end
