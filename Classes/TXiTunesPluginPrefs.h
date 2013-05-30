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

extern NSString *TXiTunesPluginEnabledKey;
extern NSString *TXiTunesPluginExtrasKey;
extern NSString *TXiTunesPluginAwayMessageKey;
extern NSString *TXiTunesPluginConnectionsKey;
extern NSString *TXiTunesPluginChannelsKey;
extern NSString *TXiTunesPluginConnectionNameKey;
extern NSString *TXiTunesPluginChannelNameKey;
extern NSString *TXiTunesPluginStyleKey;
extern NSString *TXiTunesPluginFormatStringKey;
extern NSString *TXiTunesPluginAwayFormatStringKey;
extern NSString *TXiTunesPluginDefaultFormatString;
extern NSString *TXiTunesPluginDefaultAwayFormatString;

@interface NSObject (TXiTunesPluginPrefs)

@property (assign) NSDictionary *preferences;
@property (readonly) NSString *preferencesPath;
@property (readonly) BOOL pluginEnabled;
@property (readonly) BOOL extrasEnabled;
@property (readonly) BOOL awayMessageEnabled;
@property (readonly) NSString *awayFormatString;
@property (readonly) NSString *formatString;
@property (readonly) NSInteger styleValue;
@property (readonly) NSInteger connectionsValue;
@property (readonly) NSInteger channelsValue;
@property (readonly) NSString *connectionName;
@property (readonly) NSString *channelName;
@end
