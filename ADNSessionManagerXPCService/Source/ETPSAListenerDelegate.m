//
//  ETPSAListenerDelegate.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/12/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSAListenerDelegate.h"

#import "ETPSASessionManagerServiceProtocol.h"
#import "ETPSASessionManagerService.h"


@implementation ETPSAListenerDelegate

- (BOOL)listener:(NSXPCListener*)listener
shouldAcceptNewConnection:(NSXPCConnection*)newConnection {

    // TODO

    // setup interface
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ETPSASessionManagerService)];

    // setup session manager instance
    ETPSASessionManagerService* sessionManager = [ETPSASessionManagerService new];
    newConnection.exportedObject = sessionManager;

    [newConnection resume];

    return YES;
}

@end
