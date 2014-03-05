//
//  ETPSARegion.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETPSARegion : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) NSInteger z;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, copy) NSString* color;
@property (nonatomic, copy) NSString* conditions;

@end
