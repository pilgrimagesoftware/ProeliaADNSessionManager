//
//  ETPSAMap.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ETPSAMap : NSObject <NSSecureCoding>

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, copy) NSString* backgroundFile;
@property (nonatomic, assign) CGFloat backgroundScale;

@end
