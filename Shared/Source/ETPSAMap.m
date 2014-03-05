//
//  ETPSAMap.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/20/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSAMap.h"


@implementation ETPSAMap

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _width = [[decoder decodeObjectOfClass:[NSNumber class]
                                        forKey:@"width"] integerValue];
        _height = [[decoder decodeObjectOfClass:[NSNumber class]
                                         forKey:@"height"] integerValue];
        _depth = [[decoder decodeObjectOfClass:[NSNumber class]
                                        forKey:@"depth"] integerValue];
        _backgroundFile = [decoder decodeObjectOfClass:[NSString class]
                                                forKey:@"backgroundFile"];
        _backgroundScale = [[decoder decodeObjectOfClass:[NSNumber class]
                                                  forKey:@"backgroundScale"] doubleValue];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {

    [coder encodeObject:@(_width)
                 forKey:@"width"];
    [coder encodeObject:@(_height)
                 forKey:@"height"];
    [coder encodeObject:@(_depth)
                 forKey:@"depth"];
    [coder encodeObject:_backgroundFile
                 forKey:@"backgroundFile"];
    [coder encodeObject:@(_backgroundScale)
                 forKey:@"backgroundScale"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ <%p>: { width: %ld, height: %ld, depth: %ld, backgroundFile: %@, backgroundScale: %f }",
            NSStringFromClass([self class]),
            self,
            (long)_width, (long)_height, (long)_depth,
            _backgroundFile,
            _backgroundScale];
}

@end
