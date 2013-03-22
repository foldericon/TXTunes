//
//  TPLiTunesPluginPrefs.h
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Toby P. All rights reserved.
//

#import "TextualApplication.h"
#import "TXiTunesPluginPrefs.h"

@interface TXiTunesPlugin : NSObject <THOPluginProtocol> {
     
     __weak NSButton *_enableBox;
     __weak NSButton *_debugBox;
     __weak NSMatrix *_channelsRadio;
     __weak NSMatrix *_connectionsRadio;
     __weak NSMatrix *_styleRadio;
     __weak NSTextField *_formatText;
    __weak NSTextField *_connectionText;
     __weak NSTextField *_channelText;
}

- (IBAction)enable:(id)sender;
- (IBAction)debug:(id)sender;
- (IBAction)style:(id)sender;
- (IBAction)setFormatString:(id)sender;
- (IBAction)setConnections:(id)sender;
- (IBAction)setChannels:(id)sender;
- (IBAction)setConnectionName:(id)sender;
- (IBAction)setChannelName:(id)sender;
- (IBAction)donate:(id)sender;

- (void)messageSentByUser:(IRCClient *)client
				  message:(NSString *)messageString
				  command:(NSString *)commandString;

- (NSArray *)pluginSupportsUserInputCommands;
- (void)pluginLoadedIntoMemory:(IRCWorld *)world;
- (NSView *)preferencesView;
- (NSString *)preferencesMenuItemName;

@property (weak) IBOutlet NSButton *enableBox;
@property (weak) IBOutlet NSButton *debugBox;
@property (weak) IBOutlet NSMatrix *channelsRadio;
@property (weak) IBOutlet NSMatrix *styleRadio;
@property (weak) IBOutlet NSTextField *formatText;
@property (weak) IBOutlet NSTextField *channelText;
@property (weak) IBOutlet NSMatrix *connectionsRadio;
@property (weak) IBOutlet NSTextField *connectionText;
@end