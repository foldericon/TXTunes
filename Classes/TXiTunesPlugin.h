/*
 ===============================================================================
 Copyright (c) 2013-2014, Tobias Pollmann (foldericon)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the <organization> nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ===============================================================================
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
#define TRIGGER_PLAYLIST            @"%_playlist"

@interface TXiTunesPlugin : NSObject <THOPluginProtocol, NSTokenFieldDelegate> {
     __weak NSButton *_enableBox;
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
     __weak NSTokenField *_tokenfield_playlist;
}

- (IBAction)enable:(id)sender;
- (IBAction)style:(id)sender;
- (IBAction)setConnections:(id)sender;
- (IBAction)showConnections:(id)sender;
- (IBAction)showChannels:(id)sender;
- (IBAction)setChannels:(id)sender;
- (IBAction)setChannelTargets:(id)sender;

- (IBAction)setFormatString:(id)sender;
- (IBAction)awayMessage:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)setAwayFormatString:(id)sender;

- (void)userInputCommandInvokedOnClient:(IRCClient *)client
                          commandString:(NSString *)commandString
                          messageString:(NSString *)messageString;

- (NSArray *)subscribedUserInputCommands;
- (void)pluginLoadedIntoMemory;
- (NSView *)pluginPreferencesPaneView;
- (NSString *)pluginPreferencesPaneMenuItemName;

@property (weak) IBOutlet NSButton *enableBox;
@property (weak) IBOutlet NSButton *awayMessageBox;
@property (weak) IBOutlet NSMatrix *channelsRadio;
@property (weak) IBOutlet NSMatrix *styleRadio;
@property (weak) IBOutlet NSTextField *channelText;
@property (weak) IBOutlet NSMatrix *connectionsRadio;
@property (weak) IBOutlet NSButton *connectionsButton;
@property (weak) IBOutlet NSButton *channelsButton;
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
@property (weak) IBOutlet NSTokenField *tokenfield_playlist;
@end