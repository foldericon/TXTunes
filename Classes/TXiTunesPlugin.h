//
//  TPLiTunesPluginPrefs.h
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Tobias Pollmann. All rights reserved.

/*
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Cocoa/Cocoa.h>
#import "TextualApplication.h"
#import "TXiTunesPluginPrefs.h"

#define TRIGGER_NUMBER              @"%_number"
#define TRIGGER_TRACK				@"%_track"
#define TRIGGER_ARTIST				@"%_artist"
#define TRIGGER_ALBUM				@"%_album"
#define TRIGGER_ALBUMARTIST			@"%_aartist"
#define TRIGGER_KIND                @"%_kind"
#define TRIGGER_SAMPLERATE          @"%_samplerate"
#define TRIGGER_GENRE				@"%_genre"
#define TRIGGER_LENGTH				@"%_length"
#define TRIGGER_BITRATE             @"%_bitrate"
#define TRIGGER_BPM                 @"%_bpm"
#define TRIGGER_PLAYEDCOUNT         @"%_playedcount"
#define TRIGGER_SKIPPEDCOUNT        @"%_skippedcount"
#define TRIGGER_COMMENT             @"%_comment"
#define TRIGGER_RATING              @"%_rating"
#define TRIGGER_YEAR				@"%_year"

@interface TXiTunesPlugin : NSObject <THOPluginProtocol, NSTokenFieldDelegate> {
     __weak NSButton *_enableBox;
     __weak NSButton *_extrasBox;
     __weak NSButton *_awayMessageBox;    
     __weak NSMatrix *_channelsRadio;
     __weak NSMatrix *_connectionsRadio;
     __weak NSMatrix *_styleRadio;
     __weak NSTextField *_connectionText;
     __weak NSTextField *_channelText;
     __weak NSTokenField *_formatText;
     __weak NSTokenField *_awayFormatText;
     __weak NSTokenField *_tokenfield_number;
     __weak NSTokenField *_tokenfield_track;
     __weak NSTokenField *_tokenfield_artist;
     __weak NSTokenField *_tokenfield_album;
     __weak NSTokenField *_tokenfield_albumartist;
     __weak NSTokenField *_tokenfield_kind;
     __weak NSTokenField *_tokenfield_samplerate;
     __weak NSTokenField *_tokenfield_genre;
     __weak NSTokenField *_tokenfield_length;
     __weak NSTokenField *_tokenfield_bitrate;
     __weak NSTokenField *_tokenfield_bpm;
     __weak NSTokenField *_tokenfield_playedcount;
     __weak NSTokenField *_tokenfield_skippedcount;
     __weak NSTokenField *_tokenfield_comment;
     __weak NSTokenField *_tokenfield_rating;
     __weak NSTokenField *_tokenfield_year;
}

- (IBAction)enable:(id)sender;
- (IBAction)extras:(id)sender;
- (IBAction)style:(id)sender;
- (IBAction)setConnections:(id)sender;
- (IBAction)setChannels:(id)sender;
- (IBAction)setConnectionName:(id)sender;
- (IBAction)setChannelName:(id)sender;
- (IBAction)setFormatString:(id)sender;
- (IBAction)awayMessage:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)setAwayFormatString:(id)sender;

- (void)messageSentByUser:(IRCClient *)client
				  message:(NSString *)messageString
				  command:(NSString *)commandString;

- (NSArray *)pluginSupportsUserInputCommands;
- (void)pluginLoadedIntoMemory:(IRCWorld *)world;
- (NSView *)preferencesView;
- (NSString *)preferencesMenuItemName;

@property (weak) IBOutlet NSButton *enableBox;
@property (weak) IBOutlet NSButton *extrasBox;
@property (weak) IBOutlet NSButton *awayMessageBox;
@property (weak) IBOutlet NSMatrix *channelsRadio;
@property (weak) IBOutlet NSMatrix *styleRadio;
@property (weak) IBOutlet NSTextField *channelText;
@property (weak) IBOutlet NSMatrix *connectionsRadio;
@property (weak) IBOutlet NSTextField *connectionText;
@property (weak) IBOutlet NSTokenField *formatText;
@property (weak) IBOutlet NSTokenField *awayFormatText;
@property (weak) IBOutlet NSTokenField *tokenfield_number;
@property (weak) IBOutlet NSTokenField *tokenfield_track;
@property (weak) IBOutlet NSTokenField *tokenfield_artist;
@property (weak) IBOutlet NSTokenField *tokenfield_album;
@property (weak) IBOutlet NSTokenField *tokenfield_albumartist;
@property (weak) IBOutlet NSTokenField *tokenfield_kind;
@property (weak) IBOutlet NSTokenField *tokenfield_samplerate;
@property (weak) IBOutlet NSTokenField *tokenfield_genre;
@property (weak) IBOutlet NSTokenField *tokenfield_length;
@property (weak) IBOutlet NSTokenField *tokenfield_bitrate;
@property (weak) IBOutlet NSTokenField *tokenfield_bpm;
@property (weak) IBOutlet NSTokenField *tokenfield_playedcount;
@property (weak) IBOutlet NSTokenField *tokenfield_skippedcount;
@property (weak) IBOutlet NSTokenField *tokenfield_comment;
@property (weak) IBOutlet NSTokenField *tokenfield_rating;
@property (weak) IBOutlet NSTokenField *tokenfield_year;
@end