//
//  TPLiTunesPluginPrefs.h
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Toby P. All rights reserved.
//

extern NSString *TXiTunesPluginEnabledKey;
extern NSString *TXiTunesPluginDebugKey;
extern NSString *TXiTunesPluginExtrasKey;
extern NSString *TXiTunesPluginAwayMessageKey;
extern NSString *TXiTunesPluginConnectionsKey;
extern NSString *TXiTunesPluginChannelsKey;
extern NSString *TXiTunesPluginConnectionNameKey;
extern NSString *TXiTunesPluginChannelNameKey;
extern NSString *TXiTunesPluginStyleKey;
extern NSString *TXiTunesPluginFormatStringKey;
extern NSString *TXiTunesPluginDefaultFormatString;

@interface NSObject (TXiTunesPluginPrefs)

@property (assign) NSDictionary *preferences;
@property (readonly) NSString *preferencesPath;
@property (readonly) BOOL pluginEnabled;
@property (readonly) BOOL debugEnabled;
@property (readonly) BOOL extrasEnabled;
@property (readonly) BOOL awayMessageEnabled;
@property (readonly) NSString *formatString;
@property (readonly) NSInteger styleValue;
@property (readonly) NSInteger connectionsValue;
@property (readonly) NSInteger channelsValue;
@property (readonly) NSString *connectionName;
@property (readonly) NSString *channelName;
@end
