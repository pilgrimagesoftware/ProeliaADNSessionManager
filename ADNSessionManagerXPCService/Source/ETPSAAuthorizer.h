//
//  ETPSAAuthorizer.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/11/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Snapper/Snapper.h>

#import "ETPSACredentials.h"


@interface ETPSAAuthorizer : NSObject

@property (strong, nonatomic) ETPSACredentials* credentials;

- (instancetype)initWithCredentials:(ETPSACredentials*)credentials;

- (NSString*)authorize:(SNPToken**)token
                 error:(NSError**)errorPtr;

@end
