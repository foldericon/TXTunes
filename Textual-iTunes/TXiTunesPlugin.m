//
//  TPLiTunesPluginPrefs.m
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Toby P. All rights reserved.
//

#import "TXiTunesPlugin.h"
#import "Observer.h"

@interface TXiTunesPlugin ()
// @property (nonatomic, nweak) NSView *preferencesPaneView;
@property (nonatomic, nweak) NSView *preferencePaneView;
@end

@implementation TXiTunesPlugin
Observer *observer;
NSWindow *myWindow;

#pragma mark -
#pragma mark Memory Allocation & Deallocation

/* Allocation & Deallocation */
- (void)pluginLoadedIntoMemory:(IRCWorld *)world
{
     [NSBundle loadNibNamed:@"PreferencePane" owner:self];
     if(!observer){
          observer = [[Observer alloc] init];
          NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
          //                [center removeObserver:observer name:@"com.apple.iTunes.playerInfo" object:nil];
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
     return @"iTunes Plugin";
}

- (void)awakeFromNib
{
     [self.enableBox setState:([self pluginEnabled] ? NSOnState : NSOffState)];
     [self.debugBox setState:([self debugEnabled] ? NSOnState : NSOffState)];
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
          [self.formatText setStringValue:self.formatString];
     else
          [self.formatText setStringValue:TXiTunesPluginDefaultFormatString];
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

- (IBAction)style:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithLong:[self.styleRadio selectedTag]] forKey:TXiTunesPluginStyleKey];
     [self setPreferences:dict];
}

- (IBAction)setFormatString:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[_formatText stringValue] forKey:TXiTunesPluginFormatStringKey];
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

- (IBAction)donate:(id)sender {
     [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LTNFNNKFPLS6L"]];
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
//     NSString *channelName = client.worldController.selectedChannel.name;
     NSLog(@"CommandString: %@", commandString);
     if([commandString isNotEqualTo:@"ITUNES"])
          return;
     NSArray *components = [messageString componentsSeparatedByString:@" "];
     NSArray *required = [NSArray arrayWithObjects:@"stats", @"start", @"pause", @"stop", @"prev", @"next", @"shuffle", @"rate", nil];
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     if([components count] < 1){
          [observer announceToChannel:self.worldController.selectedChannel];
     } else if([components count] == 1){
          if([[components objectAtIndex:0] isEqualToString:@"help"]){
               [client printDebugInformation:@"/itunes.....................sends your current track infos to the selected channel or query"];
               [client printDebugInformation:@"/itunes <channel>...........sends your current track infos to <channel>"];
               [client printDebugInformation:@"/itunes auto................toggles auto announce on/off"];
               [client printDebugInformation:@"/itunes debug...............toggles debug messages on/off"];
               [client printDebugInformation:@"/itunes stats...............sends infos about your itunes library to the selected channel or query"];
               //            [connection processCommand:@"DEBUG ECHO /itunes start...........starts itunes if it isn't currently running and starts playback"];
               [client printDebugInformation:@"/itunes pause...............play/pause playback"];
               [client printDebugInformation:@"/itunes stop................stops playback"];
               [client printDebugInformation:@"/itunes prev................plays previous track"];
               [client printDebugInformation:@"/itunes next................plays next track"];
               [client printDebugInformation:@"/itunes shuffle.............toggles shuffle on/off"];
               [client printDebugInformation:@"/itunes rate <1-10>.........sets the rating of the current track"];
               [client printDebugInformation:@"/itunes comment <comment>...sets the comment of the current track"];
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
                    //                [connection processCommand:@"DEBUG ECHO iTunes is not running"];
                    //               return;
               }
          }
          if([[components objectAtIndex:0] hasPrefix:@"#"]){
               for(IRCChannel *channel in self.worldController.selectedClient.channels){
                    if ([[components objectAtIndex:1] isEqualToString:[channel name]]){
                         [observer announceToChannel:channel];
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
               [[itunes currentTrack] setComment:[[[components objectAtIndex:1] stringByReplacingOccurrencesOfString:@"http://www.youtube.com/watch?v=" withString:@"youtu.be/"] stringByReplacingOccurrencesOfString:@"http://youtube.com/watch?v=" withString:@"youtu.be/"]];
               [client sendCommand:[NSString stringWithFormat:@"me added comment: %@", [[itunes currentTrack] comment]]];
               if([self debugEnabled])
                    [client printDebugInformation:[NSString stringWithFormat:@"added comment: %@", [[itunes currentTrack] comment]]];
          }
          if([[components objectAtIndex:0] isEqualToString:@"rate"]){
               if([[components objectAtIndex:1] integerValue] > 0 && [[components objectAtIndex:1] integerValue] < 11){
                    [client sendCommand:[NSString stringWithFormat:@"me rated the current track to: %@", [observer getRating:([[components objectAtIndex:1] integerValue]*10)]]];
                    [[itunes currentTrack] setRating:([[components objectAtIndex:1] integerValue]*10)];
                    if([self debugEnabled])
                         [client printDebugInformation:[NSString stringWithFormat:@"rated the current track to: %@", [observer getRating:([[components objectAtIndex:1] integerValue]*10)]]];
               }
          }
     }     
     
}

@end
