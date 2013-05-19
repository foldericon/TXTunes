//
//  TPLiTunesPluginPrefs.m
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

#import "TXiTunesPlugin.h"
#import "Observer.h"

@interface TXiTunesPlugin ()
@property (nonatomic, nweak) NSView *preferencePaneView;
@end

@implementation TXiTunesPlugin
Observer *observer;
NSWindow *myWindow;

#pragma mark -
#pragma mark Memory Allocation & Deallocation

- (void)pluginLoadedIntoMemory:(IRCWorld *)world
{
     [NSBundle loadNibNamed:@"PreferencePane" owner:self];
     if(!observer){
          observer = [[Observer alloc] init];
          NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
          [center addObserver:observer selector:@selector(trackNotification:) name:@"com.apple.iTunes.playerInfo" object:nil];
     }
}

#pragma mark -
#pragma mark Preference Pane

/* Preference Pane */

- (NSView *)preferencesView
{
     return self.preferencePaneView;
}

- (NSString *)preferencesMenuItemName
{
     return @"TXTunes";
}

- (void)awakeFromNib
{
     [self.enableBox setState:([self pluginEnabled] ? NSOnState : NSOffState)];
     [self.debugBox setState:([self debugEnabled] ? NSOnState : NSOffState)];
     [self.extrasBox setState:([self extrasEnabled] ? NSOnState : NSOffState)];
     [self.awayMessageBox setState:([self awayMessageEnabled] ? NSOnState : NSOffState)];
     [self.styleRadio selectCellWithTag:self.styleValue];
     [self.connectionsRadio selectCellWithTag:self.connectionsValue];
     [self.channelsRadio selectCellWithTag:self.channelsValue];
     [self.connectionText setStringValue:self.connectionName];
     [self.channelText setStringValue:self.channelName];
     if (self.connectionsValue == 2)
          [self.connectionText setEnabled:YES];
     if (self.channelsValue == 2)
          [self.channelText setEnabled:YES];

     if ([self.formatText isNotEqualTo:@""])
          [self.formatText setObjectValue:[self separateStringIntoTokens:self.formatString]];
     else
          [self.formatText setObjectValue:[self separateStringIntoTokens:TXiTunesPluginDefaultFormatString]];
     [self.formatText setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
     [self.formatText setDelegate:self];
     [self.tokenfield_number setStringValue:TRIGGER_NUMBER];
     [self.tokenfield_number setDelegate:self];
     [self.tokenfield_track setStringValue:TRIGGER_TRACK];
     [self.tokenfield_track setDelegate:self];
     [self.tokenfield_artist setStringValue:TRIGGER_ARTIST];
     [self.tokenfield_artist setDelegate:self];
     [self.tokenfield_album setStringValue:TRIGGER_ALBUM];
     [self.tokenfield_album setDelegate:self];
     [self.tokenfield_albumartist setStringValue:TRIGGER_ALBUMARTIST];
     [self.tokenfield_albumartist setDelegate:self];
     [self.tokenfield_kind setStringValue:TRIGGER_KIND];
     [self.tokenfield_kind setDelegate:self];
     [self.tokenfield_samplerate setStringValue:TRIGGER_SAMPLERATE];
     [self.tokenfield_samplerate setDelegate:self];
     [self.tokenfield_genre setStringValue:TRIGGER_GENRE];
     [self.tokenfield_genre setDelegate:self];
     [self.tokenfield_length setStringValue:TRIGGER_LENGTH];
     [self.tokenfield_length setDelegate:self];
     [self.tokenfield_bitrate setStringValue:TRIGGER_BITRATE];
     [self.tokenfield_bitrate setDelegate:self];
     [self.tokenfield_bpm setStringValue:TRIGGER_BPM];
     [self.tokenfield_bpm setDelegate:self];
     [self.tokenfield_playedcount setStringValue:TRIGGER_PLAYEDCOUNT];
     [self.tokenfield_playedcount setDelegate:self];
     [self.tokenfield_skippedcount setStringValue:TRIGGER_SKIPPEDCOUNT];
     [self.tokenfield_skippedcount setDelegate:self];
     [self.tokenfield_comment setStringValue:TRIGGER_COMMENT];
     [self.tokenfield_comment setDelegate:self];
     [self.tokenfield_rating setStringValue:TRIGGER_RATING];
     [self.tokenfield_rating setDelegate:self];
     [self.tokenfield_year setStringValue:TRIGGER_YEAR];
     [self.tokenfield_year setDelegate:self];
     
}

- (IBAction)enable:(id)sender {
     BOOL enabled = ([self.enableBox state]==NSOnState);
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithBool:enabled] forKey:TXiTunesPluginEnabledKey];
     [self setPreferences:dict];
}

- (IBAction)debug:(id)sender {
     BOOL enabled = ([self.debugBox state]==NSOnState);
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithBool:enabled] forKey:TXiTunesPluginDebugKey];
     [self setPreferences:dict];
}

- (IBAction)extras:(id)sender {
     BOOL enabled = ([self.extrasBox state]==NSOnState);
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithBool:enabled] forKey:TXiTunesPluginExtrasKey];
     [self setPreferences:dict];
}

- (IBAction)awayMessage:(id)sender {
     BOOL enabled = ([self.awayMessageBox state]==NSOnState);
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithBool:enabled] forKey:TXiTunesPluginAwayMessageKey];
     [self setPreferences:dict];
}

- (IBAction)style:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithLong:[self.styleRadio selectedTag]] forKey:TXiTunesPluginStyleKey];
     [self setPreferences:dict];
}

- (IBAction)setFormatString:(id)sender {
     
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[[sender objectValue] componentsJoinedByString:@""] forKey:TXiTunesPluginFormatStringKey];
     [self setPreferences:dict];
}

- (IBAction)setConnections:(id)sender {
     if ([self.connectionsRadio selectedTag] == 2){
          [self.connectionText setEnabled:YES];
     } else {
          [self.connectionText setEnabled:NO];
     }
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithLong:[self.connectionsRadio selectedTag]] forKey:TXiTunesPluginConnectionsKey];
     [self setPreferences:dict];
}

- (IBAction)setChannels:(id)sender {
     if ([self.channelsRadio selectedTag] == 2){
          [self.channelText setEnabled:YES];
     } else {
          [self.channelText setEnabled:NO];
     }
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithLong:[self.channelsRadio selectedTag]] forKey:TXiTunesPluginChannelsKey];
     [self setPreferences:dict];
}

- (IBAction)setConnectionName:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[self.connectionText stringValue] forKey:TXiTunesPluginConnectionNameKey];
     [self setPreferences:dict];
}

- (IBAction)setChannelName:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[self.channelText stringValue] forKey:TXiTunesPluginChannelNameKey];
     [self setPreferences:dict];
}

#pragma mark Token Field Delegate

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index
{
     NSString *tokenString = [tokens componentsJoinedByString:@""];
     return [self separateStringIntoTokens:tokenString];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField readFromPasteboard:(NSPasteboard *)pboard
{
     return [self separateStringIntoTokens:[pboard stringForType:NSStringPboardType]];
}

- (BOOL)tokenField:(NSTokenField *)tokenField writeRepresentedObjects:(NSArray *)objects toPasteboard:(NSPasteboard *)pboard
{
     [pboard setString:[objects componentsJoinedByString:@""] forType:NSStringPboardType];
     return YES;
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
{
     if ([representedObject hasPrefix:@"%_"]) {
          return NSRoundedTokenStyle;
     } else {
          return NSPlainTextTokenStyle;
     }
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
     if ([representedObject isEqualToString:TRIGGER_NUMBER]) {
          return @"Number";
     } else if ([representedObject isEqualToString:TRIGGER_TRACK]) {
          return @"Title";
     } else if ([representedObject isEqualToString:TRIGGER_ARTIST]) {
          return @"Artist";
     } else if ([representedObject isEqualToString:TRIGGER_ALBUMARTIST]) {
          return @"Album Artist";
     } else if ([representedObject isEqualToString:TRIGGER_ALBUM]) {
          return @"Album";
     } else if ([representedObject isEqualToString:TRIGGER_KIND]) {
          return @"Kind";
     } else if ([representedObject isEqualToString:TRIGGER_SAMPLERATE]) {
          return @"Sample Rate";
     } else if ([representedObject isEqualToString:TRIGGER_GENRE]) {
          return @"Genre";
     } else if ([representedObject isEqualToString:TRIGGER_LENGTH]) {
          return @"Length";
     } else if ([representedObject isEqualToString:TRIGGER_BITRATE]) {
          return @"Bitrate";
     } else if ([representedObject isEqualToString:TRIGGER_BPM]) {
          return @"BPM";
     } else if ([representedObject isEqualToString:TRIGGER_PLAYEDCOUNT]) {
          return @"Played Count";
     } else if ([representedObject isEqualToString:TRIGGER_SKIPPEDCOUNT]) {
          return @"Skipped Count";
     } else if ([representedObject isEqualToString:TRIGGER_COMMENT]) {
          return @"Comment";
     } else if ([representedObject isEqualToString:TRIGGER_RATING]) {
          return @"Rating";
     } else if ([representedObject isEqualToString:TRIGGER_YEAR]) {
          return @"Year";
     } else {
          return nil;
     }}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
     return editingString;
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject
{
     return nil;
}

- (NSArray *)separateStringIntoTokens:(NSString *)string
{
     NSMutableArray *tokens = [NSMutableArray array];
     
     int i = 0;
     while (i < [string length]) {
          unsigned int start = i;
          
          if ([[string substringFromIndex:i] hasPrefix:@"%_"]) {
                NSString *substringFromIndex = [string substringFromIndex:i];
                if ([substringFromIndex hasPrefix:TRIGGER_NUMBER]) {
                    i += [TRIGGER_NUMBER length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_TRACK]) {
                    i += [TRIGGER_TRACK length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_ARTIST]) {
                    i += [TRIGGER_ARTIST length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_ALBUM]) {
                    i += [TRIGGER_ALBUM length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_ALBUMARTIST]) {
                    i += [TRIGGER_ALBUMARTIST length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_KIND]) {
                    i += [TRIGGER_KIND length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_SAMPLERATE]) {
                    i += [TRIGGER_SAMPLERATE length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_GENRE]) {
                    i += [TRIGGER_GENRE length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_LENGTH]) {
                    i += [TRIGGER_LENGTH length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_BITRATE]) {
                    i += [TRIGGER_BITRATE length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_BPM]) {
                    i += [TRIGGER_BPM length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_PLAYEDCOUNT]) {
                    i += [TRIGGER_PLAYEDCOUNT length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_SKIPPEDCOUNT]) {
                    i += [TRIGGER_SKIPPEDCOUNT length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_COMMENT]) {
                    i += [TRIGGER_COMMENT length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_RATING]) {
                    i += [TRIGGER_RATING length];
                } else if ([substringFromIndex hasPrefix:TRIGGER_YEAR]) {
                    i += [TRIGGER_YEAR length];
                } else {
                    for (; i < [string length]; i++) {
                         if ([[string substringFromIndex:(i + 1)] hasPrefix:@"%_"]) {
                              i++;
                              break;
                         }
                    }
                }
          } else {
               for (; i < [string length]; i++) {
                    if ([[string substringFromIndex:(i + 1)] hasPrefix:@"%_"]) {
                         i++;
                         break;
                    }
               }
          }
          
          [tokens addObject:[string substringWithRange:NSMakeRange(start, i - start)]];
     }
     
     return tokens;
}

#pragma mark -
#pragma mark Helpers

-(NSString *)removePretendingZero:(NSString *)string
{
     if([string hasPrefix:@"0"]){
          string = [string substringFromIndex:1];
     }
     return string;
}

-(NSString *)getStringOfDuration:(NSString *)duration
{
     NSArray *dur = [duration componentsSeparatedByString:@":"];
     NSString *output = @"";
     
     if ([dur count] == 4){
          output = [NSString stringWithFormat:@"%@ days, %@ hours, %@ minutes and %@ seconds", [self removePretendingZero:[dur objectAtIndex:0]], [self removePretendingZero:[dur objectAtIndex:1]], [self removePretendingZero:[dur objectAtIndex:2]], [self removePretendingZero:[dur objectAtIndex:3]]];
     } else if ([dur count] == 3){
          output = [NSString stringWithFormat:@"%@ hours, %@ minutes and %@ seconds", [self removePretendingZero:[dur objectAtIndex:0]], [self removePretendingZero:[dur objectAtIndex:1]], [self removePretendingZero:[dur objectAtIndex:2]]];
     } else if ([dur count] == 2){
          output = [NSString stringWithFormat:@"%@ minutes and %@ seconds", [self removePretendingZero:[dur objectAtIndex:0]], [self removePretendingZero:[dur objectAtIndex:1]]];
     }
     return output;
}

-(NSString *)getStringOfSize:(long long)size
{
     NSString *masure;
     float tsize = [[NSNumber numberWithLongLong:size] floatValue];
     if(tsize > 1024) {
          // KB
          tsize = tsize/1024;
          masure = @"KB";
     }
     if(tsize > 1024) {
          // MB
          tsize = tsize/1024;
          masure = @"MB";
     }
     if(tsize > 1024) {
          // GB
          tsize = tsize/1024;
          masure = @"GB";
     }
     if(tsize > 1024) {
          // TB
          tsize = tsize/1024;
          masure = @"TB";
     }
     tsize = round(tsize*100)/100;
     
     NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
     [formatter setMaximumFractionDigits:2];
     [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
     
     NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:tsize]];
     
     return [NSString stringWithFormat:@"%@ %@", numberString, masure];
}

#pragma mark -
#pragma mark User Input

- (NSArray *)pluginSupportsUserInputCommands
{
     return @[@"itunes"];
}

- (void)messageSentByUser:(IRCClient *)client
				  message:(NSString *)messageString
				  command:(NSString *)commandString
{
     if([commandString isNotEqualTo:@"ITUNES"])
          return;
     NSArray *components = [[messageString stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "];
     NSArray *required = [NSArray arrayWithObjects:@"stats", @"start", @"pause", @"stop", @"prev", @"next", @"shuffle", @"rate", nil];
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     if([components count] == 1){
          if([[components objectAtIndex:0] isEqualToString:@""]){
               [observer announceToChannel:self.worldController.selectedChannel];
          }
          if([[components objectAtIndex:0] isEqualToString:@"help"]){
               [client printDebugInformation:@"/itunes                     sends your current track infos to the selected channel or query"];
               [client printDebugInformation:@"/itunes <channel>           sends your current track infos to <channel>"];
               [client printDebugInformation:@"/itunes auto                toggles auto announce on/off"];
               [client printDebugInformation:@"/itunes debug               toggles debug messages on/off"];
               [client printDebugInformation:@"/itunes stats               sends infos about your itunes library to the selected channel or query"];
               [client printDebugInformation:@"/itunes pause               play/pause playback"];
               [client printDebugInformation:@"/itunes stop                stops playback"];
               [client printDebugInformation:@"/itunes prev                plays previous track"];
               [client printDebugInformation:@"/itunes next                plays next track"];
               [client printDebugInformation:@"/itunes shuffle             toggles shuffle on/off"];
               [client printDebugInformation:@"/itunes rate <1-10>         sets the rating of the current track"];
               [client printDebugInformation:@"/itunes comment <comment>   sets the comment of the current track"];
          }
          if([[components objectAtIndex:0] isEqualToString:@"auto"]){
               if(self.pluginEnabled){
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:TXiTunesPluginEnabledKey];
                    [self setPreferences:dict];
                    [client printDebugInformation:@"auto announce disabled"];
               } else {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:TXiTunesPluginEnabledKey];
                    [self setPreferences:dict];
                    [client printDebugInformation:@"auto announce enabled"];
               }
          }
          if([[components objectAtIndex:0] isEqualToString:@"debug"]){
               if(self.debugEnabled){
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:TXiTunesPluginDebugKey];
                    [self setPreferences:dict];
                    [client printDebugInformation:@"debug messages disabled"];
               } else {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:TXiTunesPluginDebugKey];
                    [self setPreferences:dict];
                    [client printDebugInformation:@"debug messages enabled"];
               }
          }
          
          if ([required containsObject:[components objectAtIndex:0]]){
               if(![itunes isRunning]){
                    [itunes run];
               }
          }
          if([[components objectAtIndex:0] hasPrefix:@"#"]){
               for(IRCClient *client in [self.worldController clients]) {
                    for(IRCChannel *channel in [client channels]){
                         if ([[components objectAtIndex:0] isEqualToString:[channel name]]){
                              [observer announceToChannel:channel];
                         }
                    }
               }
          }
          if([[components objectAtIndex:0] isEqualToString:@"stats"]){
               iTunesSource *library = [[[[itunes sources] get] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kind == %i", iTunesESrcLibrary]] objectAtIndex:0];
               iTunesLibraryPlaylist *lp = [[[[library playlists] get] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"specialKind == %i", iTunesESpKMusic]] objectAtIndex:0];
               NSString *stats = [NSString stringWithFormat:@"I have %ld tracks in my iTunes library (%@ in size) (Total Playtime: %@)", (long) [[lp tracks] count], [self getStringOfSize:[lp size]], [self getStringOfDuration:[lp time]]];
               [client sendCommand:[NSString stringWithFormat:@"MSG %@ %@", [self.worldController.selectedChannel name], stats]];
          }
          if([[components objectAtIndex:0] isEqualToString:@"pause"]){
               [itunes playpause];
          }
          if([[components objectAtIndex:0] isEqualToString:@"stop"]){
               [itunes stop];
          }
          if([[components objectAtIndex:0] isEqualToString:@"next"]){
               [itunes nextTrack];
          }
          if([[components objectAtIndex:0] isEqualToString:@"prev"]){
               [itunes previousTrack];
          }
          if([[components objectAtIndex:0] isEqualToString:@"shuffle"]){
               if ([[itunes currentPlaylist] shuffle]){
                    [client printDebugInformation:@"iTunes Shuffle OFF"];
                    [[itunes currentPlaylist] setShuffle:NO];
               } else {
                    [client printDebugInformation:@"iTunes Shuffle ON"];
                    [[itunes currentPlaylist] setShuffle:YES];
               }
          }
     } else if([components count] == 2){
          if([[components objectAtIndex:0] isEqualToString:@"comment"]){
               [[itunes currentTrack] setComment:[components objectAtIndex:1]];
               if([self extrasEnabled])
                    [observer sendAnnounceString:[NSString stringWithFormat:@"added comment: %@", [[itunes currentTrack] comment]] asAction:YES];
               if([self debugEnabled])
                    [client printDebugInformation:[NSString stringWithFormat:@"added comment: %@", [[itunes currentTrack] comment]]];
          }
          if([[components objectAtIndex:0] isEqualToString:@"rate"]){
               if([[components objectAtIndex:1] integerValue] > 0 && [[components objectAtIndex:1] integerValue] < 11){
                    [[itunes currentTrack] setRating:([[components objectAtIndex:1] integerValue]*10)];
                    if([self extrasEnabled])
                         [observer sendAnnounceString:[NSString stringWithFormat:@"rated the current track to: %@", [observer getRating:([[components objectAtIndex:1] integerValue]*10)]] asAction:YES];
                    if([self debugEnabled])
                         [client printDebugInformation:[NSString stringWithFormat:@"rated the current track to: %@", [observer getRating:([[components objectAtIndex:1] integerValue]*10)]]];
               }
          }
     }     
     
}

@end
