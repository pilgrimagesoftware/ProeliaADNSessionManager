//
//  main.m
//  SessionManagerService
//
//  Created by Paul Schifferer on 1/11/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ProeliaCore/ETCConstants.h>

#import "ETPSAListenerDelegate.h"
#import "ETPSAAuthorizer.h"


int main(int argc, const char *argv[]) {
    NSLog(@"Session manager service starting...");

    ETPSAListenerDelegate* delegate = [ETPSAListenerDelegate new];
    NSXPCListener *listener = [NSXPCListener serviceListener];

    listener.delegate = delegate;
    [listener resume];

    // The resume method never returns.
    NSLog(@"Session manager service exiting.");
    return EXIT_FAILURE;
}
