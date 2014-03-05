//
//  ETPSARegion.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSARegion.h"


@implementation ETPSARegion

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
        _width = [[decoder decodeObjectOfClass:[NSNumber class]
                                        forKey:@"width"] integerValue];
        _height = [[decoder decodeObjectOfClass:[NSNumber class]
                                         forKey:@"height"] integerValue];
        _depth = [[decoder decodeObjectOfClass:[NSNumber class]
                                        forKey:@"depth"] integerValue];
        _color = [decoder decodeObjectOfClass:[NSString class]
                                      forKey:@"color"];
        _conditions = [decoder decodeObjectOfClass:[NSString class]
                                      forKey:@"conditions"];
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
    [coder encodeObject:@(_width)
                 forKey:@"width"];
    [coder encodeObject:@(_height)
                 forKey:@"height"];
    [coder encodeObject:@(_depth)
                 forKey:@"depth"];
    [coder encodeObject:_color
                 forKey:@"color"];
    [coder encodeObject:_conditions
                 forKey:@"conditions"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ <%p>: { name: %@, x: %ld, y: %ld, z: %ld, width: %ld, height: %ld, depth: %ld, color: %@, conditions: %@ }",
            NSStringFromClass([self class]),
            self,
            _name,
            _x, _y, _z,
            _width, _height, _depth,
            _color,
            _conditions];
}

@end
