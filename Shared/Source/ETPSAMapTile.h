//
//  ETPSAMapTile.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETPSAMapTile : NSObject <NSSecureCoding>

@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) NSInteger z;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* file;

@end
