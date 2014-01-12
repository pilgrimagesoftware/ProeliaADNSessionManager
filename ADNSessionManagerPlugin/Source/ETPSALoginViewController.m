//
//  ETPSALoginWindowController.m
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/10/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import "ETPSALoginViewController.h"

#import <ProeliaSDK/ETKSSessionManager.h>
#import <ProeliaCore/ETCConstants.h>


@implementation ETPSALoginViewController

- (id)init {
    self = [super initWithNibName:@"LoginView"
                           bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        // Initialization code here.
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [_loginButton setEnabled:NO];

    _usernameBackingView.backgroundColor = [NSColor colorWithWhite:0.9
                                                             alpha:0.5];
    _usernameBackingView.borderColor = [NSColor clearColor];
    _passwordBackingView.backgroundColor = [NSColor colorWithWhite:0.9
                                                             alpha:0.5];
    _passwordBackingView.borderColor = [NSColor clearColor];

    [_usernameField becomeFirstResponder];
}

- (IBAction)inputChanged:(id)sender {

}

- (IBAction)loginButtonClicked:(id)sender {

    NSString* username = [_usernameField stringValue];
    NSString* password = [_passwordField stringValue];

  BOOL success = _loginHandler(username, password);

    if(success) {
        // dismiss from here?
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {

    NSString* username = [_usernameField stringValue];
    NSString* password = [_passwordField stringValue];
    
    [_loginButton setEnabled:([username length] > 0 &&
                              [password length] > 0)];
}

@end
