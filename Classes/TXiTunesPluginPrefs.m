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


#import "TXiTunesPluginPrefs.h"

NSString *TXiTunesPluginEnabledKey = @"TXiTunesPluginEnabled";
NSString *TXiTunesPluginExtrasKey = @"TXiTunesPluginExtras";
NSString *TXiTunesPluginAwayMessageKey = @"TXiTunesPluginAwayMessage";
NSString *TXiTunesPluginConnectionsKey =  @"TXiTunesPluginConnections";
NSString *TXiTunesPluginConnectionNameKey =  @"TXiTunesPluginConnectionName";
NSString *TXiTunesPluginConnectionTargetsKey =  @"TXiTunesPluginConnectionTargets";
NSString *TXiTunesPluginChannelsKey =  @"TXiTunesPluginChannels";
NSString *TXiTunesPluginChannelNameKey =  @"TXiTunesPluginChannelName";
NSString *TXiTunesPluginStyleKey =  @"TXiTunesPluginStyle";
NSString *TXiTunesPluginAwayFormatStringKey =  @"TXiTunesPluginAwayFormatString";
NSString *TXiTunesPluginDefaultAwayFormatString = @"♬ %_artist - %_track";
NSString *TXiTunesPluginFormatStringKey =  @"TXiTunesPluginFormatString";
NSString *TXiTunesPluginDefaultFormatString = @"is listening to %_track by %_artist from the album %_album";


@implementation NSObject (TXiTunesPluginPrefs)


- (NSDictionary *)preferences
{
     if (![[NSFileManager defaultManager] fileExistsAtPath:[self preferencesPath]])
     {
          NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"NO", TXiTunesPluginEnabledKey, @"NO", TXiTunesPluginExtrasKey, @"NO", TXiTunesPluginAwayMessageKey, @"1", TXiTunesPluginConnectionsKey, @"1", TXiTunesPluginChannelsKey, [NSArray array], TXiTunesPluginConnectionNameKey, @"", TXiTunesPluginChannelNameKey, @"0", TXiTunesPluginStyleKey, TXiTunesPluginDefaultAwayFormatString, TXiTunesPluginAwayFormatStringKey, TXiTunesPluginDefaultFormatString, TXiTunesPluginFormatStringKey, nil];
          [self setPreferences:dict];
     }
     NSMutableDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self preferencesPath]];
     if([[dict allKeys] containsObject:TXiTunesPluginConnectionTargetsKey] == NO) {
          [dict setObject:[NSArray array] forKey:TXiTunesPluginConnectionTargetsKey];
          [self setPreferences:dict];
     }
     return [NSDictionary dictionaryWithContentsOfFile:[self preferencesPath]];
}

- (void)setPreferences:(NSDictionary *)dictionary
{
     [dictionary writeToFile:[self preferencesPath] atomically:YES];
}

- (NSString *)preferencesPath
{
     return [[NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(), [[NSBundle bundleForClass:[self class]] bundleIdentifier]] stringByExpandingTildeInPath];
}

- (BOOL)announceEnabled
{
     return [[self.preferences objectForKey:TXiTunesPluginEnabledKey] boolValue];
}

- (BOOL)extrasEnabled
{
     return [[self.preferences objectForKey:TXiTunesPluginExtrasKey] boolValue];
}

- (BOOL)awayMessageEnabled
{
     return [[self.preferences objectForKey:TXiTunesPluginAwayMessageKey] boolValue];
}

- (NSString *)formatString
{
     return [self.preferences objectForKey:TXiTunesPluginFormatStringKey];
}

- (NSString *)awayFormatString
{
     return [self.preferences objectForKey:TXiTunesPluginAwayFormatStringKey];
}

- (NSInteger)styleValue
{
     return [[self.preferences objectForKey:TXiTunesPluginStyleKey] integerValue];
}

- (NSInteger)connectionsValue
{
     return [[self.preferences objectForKey:TXiTunesPluginConnectionsKey] integerValue];
}

- (NSInteger)channelsValue
{
     return [[self.preferences objectForKey:TXiTunesPluginChannelsKey] integerValue];
}

- (NSArray *)connectionTargets
{
     return [self.preferences objectForKey:TXiTunesPluginConnectionTargetsKey];
}

- (NSString *)channelName
{
     return [self.preferences objectForKey:TXiTunesPluginChannelNameKey];
}


@end