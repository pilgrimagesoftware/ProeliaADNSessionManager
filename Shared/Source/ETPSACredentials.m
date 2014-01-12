//
//  ETPSACredentials.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSACredentials.h"


@implementation ETPSACredentials

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _clientId = [decoder decodeObjectOfClass:[NSString class]
                                          forKey:@"clientId"];
        _grantSecret = [decoder decodeObjectOfClass:[NSString class]
                                             forKey:@"grantSecret"];
        _scopes = [decoder decodeObjectOfClass:[NSString class]
                                        forKey:@"scopes"];
        _username = [decoder decodeObjectOfClass:[NSString class]
                                          forKey:@"username"];
        _password = [decoder decodeObjectOfClass:[NSString class]
                                          forKey:@"password"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {

    [coder encodeObject:_clientId
                 forKey:@"clientId"];
    [coder encodeObject:_grantSecret
                 forKey:@"grantSecret"];
    [coder encodeObject:_scopes
                 forKey:@"scopes"];
    [coder encodeObject:_username
                 forKey:@"username"];
    [coder encodeObject:_password
                 forKey:@"password"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ <%p>: { clientId: %@, scopes: %@, username: %@ }",
            NSStringFromClass([self class]),
            self,
            _clientId,
            _scopes,
            _username];
}

@end
