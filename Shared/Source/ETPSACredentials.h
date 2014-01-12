//
//  ETPSACredentials.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETPSACredentials : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString* clientId;
@property (nonatomic, copy) NSString* grantSecret;
@property (nonatomic, copy) NSString* scopes;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* password;

@end
