//
//  ETPSASessionManagerService.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ETPSACredentials.h"


@protocol ETPSASessionManagerService <NSObject>

- (void)authorize:(ETPSACredentials*)credentials
       completion:(void (^)(NSString* accessToken, NSInteger userId, NSError* error))completionBlock;

@end
