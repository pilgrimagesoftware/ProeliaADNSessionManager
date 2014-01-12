//
//  ETPSALoginWindowController.h
//  ADNSessionManager
//
//  Created by Paul Schifferer on 1/10/14.
//  Copyright (c) 2014 Pilgrimage Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Pilgrimage/Pilgrimage.h>


typedef BOOL (^ETPSALoginHandler)(NSString* username, NSString* password);

@interface ETPSALoginViewController : NSViewController
<NSTextFieldDelegate>

@property (strong) IBOutlet PSTiledBackgroundView *backgroundView;
@property (strong) IBOutlet NSImageView *appLogoImageView;
@property (strong) IBOutlet NSImageView *adnLogoImageView;
@property (strong) IBOutlet NSTextField *loginLabel;
@property (strong) IBOutlet PSBorderedContainerView *usernameBackingView;
@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet PSBorderedContainerView *passwordBackingView;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSButton *loginButton;

@property (copy, nonatomic) ETPSALoginHandler loginHandler;

- (IBAction)inputChanged:(id)sender;
- (IBAction)loginButtonClicked:(id)sender;

@end
