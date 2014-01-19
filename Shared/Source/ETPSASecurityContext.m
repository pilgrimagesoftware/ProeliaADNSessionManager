//
//  ETPSASecurityContext.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/14/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSASecurityContext.h"


@implementation ETPSASecurityContext

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _accessToken = [decoder decodeObjectOfClass:[NSString class]
                                             forKey:@"accessToken"];
        _tokenType = [decoder decodeObjectOfClass:[NSString class]
                                             forKey:@"tokenType"];
        _name = [decoder decodeObjectOfClass:[NSString class]
                                      forKey:@"name"];
        _username = [decoder decodeObjectOfClass:[NSString class]
                                          forKey:@"username"];
        _userId = [[decoder decodeObjectOfClass:[NSNumber class]
                                         forKey:@"userId"] integerValue];
        _apiId = [decoder decodeObjectOfClass:[NSString class]
                                       forKey:@"apiId"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {

    [coder encodeObject:_accessToken
                 forKey:@"accessToken"];
    [coder encodeObject:_tokenType
                 forKey:@"tokenType"];
    [coder encodeObject:_name
                 forKey:@"name"];
    [coder encodeObject:_username
                 forKey:@"username"];
    [coder encodeObject:@(_userId)
                 forKey:@"userId"];
    [coder encodeObject:_apiId
                 forKey:@"apiId"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ <%p>: { accessToken: %@, tokenType: %@, name: %@, username: %@, userId: %ld, apiId: %@ }",
            NSStringFromClass([self class]),
            self,
            _accessToken,
            _tokenType,
            _name,
            _username,
            (long)_userId,
            _apiId];
}

@end
