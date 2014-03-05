//
//  ETPSAMapTile.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSAMapTile.h"


@implementation ETPSAMapTile

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _name = [decoder decodeObjectOfClass:[NSString class]
                                      forKey:@"name"];
        _x = [[decoder decodeObjectOfClass:[NSNumber class]
                                    forKey:@"x"] integerValue];
        _y = [[decoder decodeObjectOfClass:[NSNumber class]
                                    forKey:@"y"] integerValue];
        _z = [[decoder decodeObjectOfClass:[NSNumber class]
                                    forKey:@"z"] integerValue];
        _scale = [[decoder decodeObjectOfClass:[NSString class]
                                        forKey:@"scale"] doubleValue];
        _file = [decoder decodeObjectOfClass:[NSString class]
                                      forKey:@"file"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {

    [coder encodeObject:_name
                 forKey:@"name"];
    [coder encodeObject:@(_x)
                 forKey:@"x"];
    [coder encodeObject:@(_y)
                 forKey:@"y"];
    [coder encodeObject:@(_z)
                 forKey:@"z"];
    [coder encodeObject:@(_scale)
                 forKey:@"scale"];
    [coder encodeObject:_file
                 forKey:@"file"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ <%p>: { name: %@, x: %ld, y: %ld, z: %ld, scale: %f, file: %@ }",
            NSStringFromClass([self class]),
            self,
            _name,
            _x, _y, _z,
            _scale,
            _file];
}

@end
