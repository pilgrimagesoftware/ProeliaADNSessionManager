//
//  ETPSAParticipant.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETPSAParticipant : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString* color;
@property (nonatomic, copy) NSInteger x;
@property (nonatomic, copy) NSInteger y;
@property (nonatomic, copy) NSInteger z;

@end
