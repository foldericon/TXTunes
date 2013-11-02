/*
 ===============================================================================
 Copyright (c) 2013, Tobias Pollmann (foldericon)
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
          [[NSNotificationCenter defaultCenter] removeObserver:self];
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowClosing:) name:NSWindowWillCloseNotification object:nil];
     }
}

- (void)dealloc
{
     [[NSDistributedNotificationCenter defaultCenter] removeObserver:observer name:@"com.apple.iTunes.playerInfo" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
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
     return @"iTunes";
}

- (void)awakeFromNib
{
     if([self.preferences objectForKey:TXiTunesPluginConnectionNameKey]){
          NSArray *ary = [[self.preferences objectForKey:TXiTunesPluginConnectionNameKey] componentsSeparatedByString:@","];
          for(IRCClient *client in self.worldController.clients){
               if([ary containsObjectIgnoringCase:client.name]) {
                    [self addOrRemoveConnection:client];
               }
          }
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
          [dict removeObjectForKey:TXiTunesPluginConnectionNameKey];
          [self setPreferences:dict];
     }
     
     if([self.preferences objectForKey:TXiTunesPluginChannelNameKey]){
          NSArray *ary = [[[[self.preferences objectForKey:TXiTunesPluginChannelNameKey] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@","] componentsSeparatedByString:@","];
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
          [dict setObject:ary forKey:TXiTunesPluginChannelTargetsKey];
          [dict removeObjectForKey:TXiTunesPluginChannelNameKey];
          [self setPreferences:dict];
     }
     
     [self updateConnectionsButtonTitle];
     [self updateChannelsText];
     [self.enableBox setState:([self announceEnabled] ? NSOnState : NSOffState)];
     [self.awayMessageBox setState:([self awayMessageEnabled] ? NSOnState : NSOffState)];
     [self.styleRadio selectCellWithTag:self.styleValue];
     [self.connectionsRadio selectCellWithTag:self.connectionsValue];
     [self.channelsRadio selectCellWithTag:self.channelsValue];
     if (self.connectionsValue == 2)
          [self.connectionsButton setEnabled:YES];
     if (self.channelsValue == 2) {
          [self.channelText setEnabled:YES];
          [self.channelsButton setEnabled:YES];
     }
     if (self.awayMessageEnabled)
          [self.awayFormatText setEnabled:YES];
     else
          [self.awayFormatText setEnabled:NO];
     if ([self.formatText isNotEqualTo:@""])
          [self.formatText setObjectValue:[self separateStringIntoTokens:self.formatString]];
     else
          [self.formatText setObjectValue:[self separateStringIntoTokens:TXiTunesPluginDefaultFormatString]];
     if ([self.awayFormatText isNotEqualTo:@""])
          [self.awayFormatText setObjectValue:[self separateStringIntoTokens:self.awayFormatString]];
     else
          [self.awayFormatText setObjectValue:[self separateStringIntoTokens:TXiTunesPluginDefaultAwayFormatString]];
     [self.awayFormatText setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
     [self.awayFormatText setDelegate:self];
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
     [self.tokenfield_playlist setStringValue:TRIGGER_PLAYLIST];
     [self.tokenfield_playlist setDelegate:self];
}

- (void)windowClosing:(NSNotification*)aNotification {
     NSWindow *win = [aNotification valueForKey:@"object"];
     if([win.title isEqualToString:@"Textual Preferences"]) {
          [self setAwayFormatString:self.awayFormatText];
          [self setFormatString:self.formatText];
     }
}

-(NSString*)truncateString:(NSString*)string toWidth:(CGFloat)width withAttributes:(NSDictionary*)attributes
{
     int min = 0, max = (int)string.length, mid;
     while (min < max) {
          mid = (min+max)/2;
          
          NSString *currentString = [string substringToIndex:mid];
          CGSize currentSize = [currentString sizeWithAttributes:attributes];
          
          if (currentSize.width < width){
               min = mid + 1;
          } else if (currentSize.width > width) {
               max = mid - 1;
          } else {
               min = mid;
               break;
          }
     }
     return [string substringToIndex:min];
}

- (void)updateConnectionsButtonTitle
{
     int i=0;
     NSString *title = @"pick one or more";
     for(IRCClient *client in self.worldController.clients) {
          if([self.connectionTargets containsObject:client.config.itemUUID]){
               if(i==0) title = client.name;
               else title = [NSString stringWithFormat:@"%@, %@", title, client.name];
               i++;
          }
     }
     CGSize size = [title sizeWithAttributes:self.connectionsButton.attributedTitle.attributes];
     CGFloat width = self.connectionsButton.frame.size.width-30;
     if((int)size.width > (int)width) {
          title = [self truncateString:title
                               toWidth:width
                        withAttributes:self.connectionsButton.attributedTitle.attributes];
          title = [NSString stringWithFormat:@"%@...", [title substringToIndex:title.length-3]];
     }
     [self.connectionsButton setTitle:title];
}

- (void)updateChannelsText
{
     int i=0;
     NSString *string = @"";
     for(NSString *channel in [self getChannelNames]){
          if([self.channelTargets containsObjectIgnoringCase:channel]){
               if(i==0) string = channel;
               else string = [NSString stringWithFormat:@"%@, %@", string, channel];
               i++;
          }
     }
     [self.channelText setStringValue:string];
}

- (void)addOrRemoveConnection:(IRCClient *)client
{
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     NSMutableArray *ary = [[NSMutableArray alloc] initWithArray:self.connectionTargets];
     if([ary containsObject:client.config.itemUUID]){
          [ary removeObject:client.config.itemUUID];
     } else {
          [ary addObject:client.config.itemUUID];
     }
     [dict setObject:ary forKey:TXiTunesPluginConnectionTargetsKey];
     [self setPreferences:dict];
     [self updateConnectionsButtonTitle];
}

- (NSArray*)getChannelNames
{
     NSMutableArray *channels = [[NSMutableArray alloc] init];
     if(self.connectionsValue == 0 || self.connectionsValue == 1){
          for(IRCClient *client in self.worldController.clients) {
               for(IRCChannel *channel in client.channels) {
                    if(channel.isChannel) [channels addObject:channel.name];
               }
          }
     } else {
          for(IRCClient *client in self.worldController.clients) {
               if([self.connectionTargets containsObject:client.config.itemUUID]){
                    for(IRCChannel *channel in client.channels){
                         if(channel.isChannel) [channels addObject:channel.name];
                    }
               }
          }
     }
     for(NSString *channel in self.channelTargets) {
          if([channels containsObjectIgnoringCase:channel] == NO) {
               [channels addObject:channel];
          }
     }
     return channels;
}

- (IBAction)enable:(id)sender {
     BOOL enabled = ([self.enableBox state]==NSOnState);
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithBool:enabled] forKey:TXiTunesPluginEnabledKey];
     [self setPreferences:dict];
}

- (IBAction)awayMessage:(id)sender {
     BOOL enabled = ([self.awayMessageBox state]==NSOnState);
     if(enabled)
          [self.awayFormatText setEnabled:YES];
     else
          [self.awayFormatText setEnabled:NO];
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithBool:enabled] forKey:TXiTunesPluginAwayMessageKey];
     [self setPreferences:dict];
}

- (IBAction)showHelp:(id)sender {
     [self printHelp];
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

- (IBAction)setAwayFormatString:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[[sender objectValue] componentsJoinedByString:@""] forKey:TXiTunesPluginAwayFormatStringKey];
     [self setPreferences:dict];
}

- (IBAction)showConnections:(id)sender {
     NSRect frame = [(NSButton *)sender frame];
     NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x+5, frame.origin.y)
                                                                toView:nil];
     
     NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                          location:menuOrigin
                                     modifierFlags:NSLeftMouseDownMask
                                         timestamp:0
                                      windowNumber:[[(NSButton *)sender window] windowNumber]
                                           context:[[(NSButton *)sender window] graphicsContext]
                                       eventNumber:0
                                        clickCount:1
                                          pressure:1];
     
     NSMenu *menu = [[NSMenu alloc] init];
     menu.autoenablesItems=NO;
     NSArray *clients = self.worldController.clients;
     for(int i=(int)clients.count-1; i>-1; i--) {
          NSMenuItem *item = [[NSMenuItem alloc] init];
          item.representedObject = clients[i];
          item.title = [clients[i] name];
          item.action = @selector(addConnectionTarget:);
          item.keyEquivalent = @"";
          item.target = self;
          if([self.connectionTargets containsObject:[[clients[i] config] itemUUID]]) {
               [item setState:NSOnState];
          }
          [menu insertItem:item atIndex:0];
     }
     [NSMenu popUpContextMenu:menu withEvent:event forView:(NSButton *)sender];
}

- (IBAction)showChannels:(id)sender {
     NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[self getChannelNames]];
     NSArray *copy = [channels copy];
     NSInteger index = [copy count] - 1;
     for (id object in [copy reverseObjectEnumerator]) {
          if ([channels indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
               [channels removeObjectAtIndex:index];
          }
          index--;
     }
     NSRect frame = [(NSTextField *)self.channelText frame];
     NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y-7)
                                                                toView:nil];
     
     NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                          location:menuOrigin
                                     modifierFlags:NSLeftMouseDownMask
                                         timestamp:0
                                      windowNumber:[[(NSButton *)sender window] windowNumber]
                                           context:[[(NSButton *)sender window] graphicsContext]
                                       eventNumber:0
                                        clickCount:1
                                          pressure:1];
     
     NSMenu *menu = [[NSMenu alloc] init];
     menu.autoenablesItems=NO;
     for(NSString *channel in [channels reverseObjectEnumerator]) {
          NSMenuItem *item = [[NSMenuItem alloc] init];
          item.title = channel;
          item.action = @selector(addChannelTarget:);
          item.keyEquivalent = @"";
          item.target = self;
          if([self.channelTargets containsObjectIgnoringCase:channel]) {
               [item setState:NSOnState];
          }
          [menu insertItem:item atIndex:0];
     }
     [NSMenu popUpContextMenu:menu withEvent:event forView:(NSButton *)sender];
}

- (IBAction)setConnections:(id)sender {
     if ([self.connectionsRadio selectedTag] == 2){
          [self.connectionsButton setEnabled:YES];
     } else {
          [self.connectionsButton setEnabled:NO];
     }
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithLong:[self.connectionsRadio selectedTag]] forKey:TXiTunesPluginConnectionsKey];
     [self setPreferences:dict];
}

- (IBAction)setChannels:(id)sender {
     if ([self.channelsRadio selectedTag] == 2){
          [self.channelText setEnabled:YES];
          [self.channelsButton setEnabled:YES];
     } else {
          [self.channelText setEnabled:NO];
          [self.channelsButton setEnabled:NO];
     }
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:[NSNumber numberWithLong:[self.channelsRadio selectedTag]] forKey:TXiTunesPluginChannelsKey];
     [self setPreferences:dict];
}

- (IBAction)setChannelTargets:(id)sender {
     NSArray *ary = [[[self.channelText.stringValue lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     [dict setObject:ary forKey:TXiTunesPluginChannelTargetsKey];
     [self setPreferences:dict];
     [self updateChannelsText];
}

- (IBAction)addConnectionTarget:(id)sender {
     [self addOrRemoveConnection:[sender representedObject]];
}

- (IBAction)addChannelTarget:(id)sender {
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
     NSMutableArray *ary = [[NSMutableArray alloc] initWithArray:self.channelTargets];
     if([ary containsObjectIgnoringCase:[(NSMenuItem*)sender title]]){
          [ary removeObject:[[(NSMenuItem*)sender title] lowercaseString]];
     } else {
          [ary addObject:[[(NSMenuItem*)sender title] lowercaseString]];
     }
     [dict setObject:ary forKey:TXiTunesPluginChannelTargetsKey];
     [self setPreferences:dict];
     [self updateChannelsText];
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
          return @"Play Count";
     } else if ([representedObject isEqualToString:TRIGGER_SKIPPEDCOUNT]) {
          return @"Skip Count";
     } else if ([representedObject isEqualToString:TRIGGER_COMMENT]) {
          return @"Comment";
     } else if ([representedObject isEqualToString:TRIGGER_RATING]) {
          return @"Rating";
     } else if ([representedObject isEqualToString:TRIGGER_YEAR]) {
          return @"Year";
     } else if ([representedObject isEqualToString:TRIGGER_PLAYLIST]) {
          return @"Playlist";
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
                } else if ([substringFromIndex hasPrefix:TRIGGER_PLAYLIST]) {
                     i += [TRIGGER_PLAYLIST length];
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

- (void)echo:(NSString *)msg
{
     [self.worldController.selectedClient printDebugInformation:msg forCommand:@"-100"];
}

- (void)printHelp
{
     IRCClient *client = self.worldController.selectedClient;
     [client printDebugInformation:@"\00311   __________         __________ " forCommand:@"375"];
     [client printDebugInformation:@"\00311  |___    ___|__    _|___    ___|" forCommand:@"372"];
     [client printDebugInformation:@"\00311      |  |  \\   \\  /   / |  | __  __  ______  ______   _______" forCommand:@"372"];
     [client printDebugInformation:@"\00311      |  |   \\   \\/   /  |  ||  ||  ||  __  \\/  __  \\ /  _____|" forCommand:@"372"];
     [client printDebugInformation:@"\00311      |  |    /      \\   |  ||  ||  ||  ||  ||  |_|  ||  |____" forCommand:@"372"];
     [client printDebugInformation:@"\00311      |  |   /   /\\   \\  |  ||  ||  ||  ||  || _____/ \\____   \\" forCommand:@"372"];
     [client printDebugInformation:@"\00311______|__|__/___/__\\___\\_|__|_\\____/_|__||__|\\______|______|  |______________________________" forCommand:@"372"];
     [client printDebugInformation:@"\00311\037___________Advanced iTunes extension for Textual______________\037/                 is.gd/P9Fgri \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes\002                    \026sends your current track infos to the selected channel or query   \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes <channel>\002          \026sends your current track infos to <channel>                       \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes stats\002              \026sends itunes library statistics to the selected channel or query  \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes url\002                \026sends the itunes store url of the current track                   \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes auto\002               \026toggles auto announce on/off                                      \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes pause\002              \026play/pause playback                                               \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes stop\002               \026stops playback                                                    \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes prev\002               \026plays previous track                                              \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes next\002               \026plays next track                                                  \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes rate <1-10>\002        \026sets the rating of the current track                              \003\00311|" forCommand:@"372"];
     [client printDebugInformation:@"\00315\002/itunes comment <comment>\002  \026sets the comment of the current track                             \003\00311|" forCommand:@"376"];
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
     NSArray *required = [NSArray arrayWithObjects:@"stats", @"start", @"pause", @"stop", @"prev", @"next", @"rate", nil];
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     if([components count] == 1){
          if([[components objectAtIndex:0] isEqualToString:@""]){
               if(itunes.isRunning == NO) {
                    [client printDebugInformation:@"iTunes is not running."];
                    return;
               } else if([itunes playerState] != 'kPSP') {
                    [client printDebugInformation:@"iTunes is not playing."];
                    return;
               }
               [observer announceToChannel:self.worldController.selectedChannel];
          }
          if([[components objectAtIndex:0] isEqualToString:@"help"]){
               [self printHelp];
          }
          if([[components objectAtIndex:0] isEqualToString:@"auto"]){
               if(self.announceEnabled){
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
                    [dict setObject:[NSNumber numberWithBool:NO] forKey:TXiTunesPluginEnabledKey];
                    [self setPreferences:dict];
                    [self.enableBox setState:NSOffState];
                    [self echo:@"auto announce disabled"];
               } else {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
                    [dict setObject:[NSNumber numberWithBool:YES] forKey:TXiTunesPluginEnabledKey];
                    [self setPreferences:dict];
                    [self.enableBox setState:NSOnState];
                    [self echo:@"auto announce enabled"];
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
          if([[components objectAtIndex:0] isEqualToString:@"url"]){
               NSString *storeurl = @"";
               NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
               NSString *searchTerm = [NSString stringWithFormat:@"%@ %@", itunes.currentTrack.artist, itunes.currentTrack.name];
               searchTerm = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) searchTerm, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
               [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=song", searchTerm]]];
               NSHTTPURLResponse *urlResponse = nil;
               NSError *error = [[NSError alloc] init];
               NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
               if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
                    if(responseData != nil && NSClassFromString(@"NSJSONSerialization"))
                    {
                         NSError *error = nil;
                         id object = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                         if(error) { [self echo:@"Error while fetching iTunes store url"]; return; }
                         if([object isKindOfClass:[NSDictionary class]])
                         {
                              NSDictionary *results = object;
                              for (NSDictionary *result in [results objectForKey:@"results"]) {
                                   if([[result objectForKey:@"trackViewUrl"] isNotEqualTo:@""]) {
                                        storeurl = [result objectForKey:@"trackViewUrl"];
                                        if([[result objectForKey:@"collectionName"] isEqualIgnoringCase:itunes.currentTrack.album]) break;
                                   }
                              }
                         }
                    }
               }
               if([storeurl isNotEqualTo:@""]) [client sendCommand:[NSString stringWithFormat:@"MSG %@ %@", [self.worldController.selectedChannel name], storeurl]];
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
     } else if([components count] == 2){
          if([[components objectAtIndex:0] isEqualToString:@"comment"]){
               [[itunes currentTrack] setComment:[components objectAtIndex:1]];
               [self echo:[NSString stringWithFormat:@"added comment: %@", [[itunes currentTrack] comment]]];
          }
          if([[components objectAtIndex:0] isEqualToString:@"rate"]){
               if([[components objectAtIndex:1] integerValue] > 0 && [[components objectAtIndex:1] integerValue] < 11){
                    [[itunes currentTrack] setRating:([[components objectAtIndex:1] integerValue]*10)];
                         [self echo:[NSString stringWithFormat:@"rated the current track to: %@", [observer getRating:([[components objectAtIndex:1] integerValue]*10)]]];
               }
          }
     }     
     
}

@end
