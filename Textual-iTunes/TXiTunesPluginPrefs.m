//
//  TPLiTunesPluginPrefs.m
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Toby P. All rights reserved.
//

#import "TXiTunesPluginPrefs.h"

NSString *TXiTunesPluginEnabledKey = @"TXiTunesPluginEnabled";
NSString *TXiTunesPluginDebugKey =  @"TXiTunesPluginDebug";
NSString *TXiTunesPluginExtrasKey = @"TXiTunesPluginExtras";
NSString *TXiTunesPluginConnectionsKey =  @"TXiTunesPluginConnections";
NSString *TXiTunesPluginConnectionNameKey =  @"TXiTunesPluginConnectionName";
NSString *TXiTunesPluginChannelsKey =  @"TXiTunesPluginChannels";
NSString *TXiTunesPluginChannelNameKey =  @"TXiTunesPluginChannelName";
NSString *TXiTunesPluginStyleKey =  @"TXiTunesPluginStyle";
NSString *TXiTunesPluginFormatStringKey =  @"TXiTunesPluginFormatString";
NSString *TXiTunesPluginDefaultFormatString = @"I'm currently listening to: %_track by %_artist from the album %_album";

@implementation NSObject (TXiTunesPluginPrefs)


- (NSDictionary *)preferences
{
     if (![[NSFileManager defaultManager] fileExistsAtPath:[self preferencesPath]])
     {
          NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", TXiTunesPluginEnabledKey, @"NO", TXiTunesPluginDebugKey, @"NO", TXiTunesPluginExtrasKey, @"1", TXiTunesPluginConnectionsKey, @"1", TXiTunesPluginChannelsKey, @"", TXiTunesPluginConnectionNameKey, @"", TXiTunesPluginChannelNameKey, @"1", TXiTunesPluginStyleKey, TXiTunesPluginDefaultFormatString, TXiTunesPluginFormatStringKey, nil];
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

- (BOOL)pluginEnabled
{
     return [[self.preferences objectForKey:TXiTunesPluginEnabledKey] boolValue];
}

- (BOOL)debugEnabled
{
     return [[self.preferences objectForKey:TXiTunesPluginDebugKey] boolValue];
}

- (BOOL)extrasEnabled
{
     return [[self.preferences objectForKey:TXiTunesPluginExtrasKey] boolValue];
}

- (NSString *)formatString
{
     return [self.preferences objectForKey:TXiTunesPluginFormatStringKey];
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

- (NSString *)connectionName
{
     return [self.preferences objectForKey:TXiTunesPluginConnectionNameKey];
}

- (NSString *)channelName
{
     return [self.preferences objectForKey:TXiTunesPluginChannelNameKey];
}
@end