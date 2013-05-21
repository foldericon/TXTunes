//
//  Observer.m
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

#import "Observer.h"
#import "TXiTunesPlugin.h"

@implementation Observer

unichar _action = 0x01;
unichar _bold = 0x02;        
unichar _color = 0x03;    

- (NSString *)getRating:(NSInteger)rating
{
    NSString *rstring;
    rstring = @"";
    int r = [[NSNumber numberWithInteger:rating] intValue];
    if (r > 0){
        for (int i=0; i<(int)round(r/20); i++){
            rstring = [rstring stringByAppendingString:@"✮"];
        }
        if ((int)round(r/10)%2 > 0){
            rstring = [rstring stringByAppendingString:@"½"];
        }
        for (int i=0; i<10-(int)round(r/10); i+=2){
            if(i != 0 || (int)round(r/10)%2 == 0)
                rstring = [rstring stringByAppendingString:@"✩"];
        }
    }
    return rstring;
}

-(void)sendMessage:(NSString *)message toChannel:(IRCChannel *)channel withStyle:(NSInteger)style
{
    if ([channel isChannel] && [[channel memberList] count] > 0){
        if (style == 0){
            if([self debugEnabled]){
                 [[channel client] printDebugInformation:[NSString stringWithFormat:@"(action) %@", message] channel:channel];
            } 
            if ([self pluginEnabled]) {
                 [[channel client] sendCommand:[NSString stringWithFormat:@"me %@", message] completeTarget:YES target:[channel name]];                 
            }
        } else {
            if([self debugEnabled]){
                 [[channel client] printDebugInformation:[NSString stringWithFormat:@"%@", message] channel:channel];
            }
            if ([self pluginEnabled]) {
                 [[channel client] sendCommand:[NSString stringWithFormat:@"msg %@ %@", [channel name], message]];
            }
        }
    }
}

-(NSString *)getAnnounceString:(iTunesApplication *)itunes
{
     NSString *number = [NSString stringWithFormat:@"%ld", (long)[[itunes currentTrack] trackNumber]];
     NSString *track = [NSString stringWithFormat:@"%@", [[itunes currentTrack] name]];
     NSString *artist = [NSString stringWithFormat:@"%@", [[itunes currentTrack] artist]];
     NSString *albumArtist = [NSString stringWithFormat:@"%@", [[itunes currentTrack] albumArtist]];
     NSString *album = [NSString stringWithFormat:@"%@", [[itunes currentTrack] album]];
     NSString *genre = [NSString stringWithFormat:@"%@", [[itunes currentTrack] genre]];
     NSString *year = [NSString stringWithFormat:@"%ld", (long)[[itunes currentTrack] year]];
     NSString *playcount = [NSString stringWithFormat:@"%ld", (long)[[itunes currentTrack] playedCount]];
     NSString *skipcount = [NSString stringWithFormat:@"%ld", (long)[[itunes currentTrack] skippedCount]];
     NSString *kind = [NSString stringWithFormat:@"%@", [[itunes currentTrack] kind]];
     NSString *comment = [NSString stringWithFormat:@"%@", [[itunes currentTrack] comment]];

     if([track isEqualToString:@""])
          track = @"n/a";
     if([artist isEqualToString:@""])
          artist = @"n/a";
     if([albumArtist isEqualToString:@""])
          albumArtist = @"n/a";
     if([album isEqualToString:@""])
          album = @"n/a";
     if([genre isEqualToString:@""])
          genre = @"n/a";
     if([year isEqualToString:@"0"])
          year = @"n/a";
     if([comment isEqualToString:@""])
          comment = @"n/a";
     
    NSString *skind;
    if([kind isEqualToString:@"MPEG audio file"]){
        skind=@"MP3";
    } else if([kind isEqualToString:@"Apple Lossless audio file"]){
        skind=@"ALAC";
    } else if([kind isEqualToString:@"AAC audio file"] || [kind isEqualToString:@"Purchased AAC audio file"]){
        skind=@"AAC";
    } else {
        skind=@"unknown";        
    }
    NSString *bitrate;
    bitrate = [NSString stringWithFormat:@"%ldkbps", (long) [[itunes currentTrack] bitRate]];
    if ([skind isEqualToString:@"MP3"]){
        if ([[itunes currentTrack] bitRate] % 16 != 0){
            bitrate = [NSString stringWithFormat:@"%ldkbps (VBR)", (long) [[itunes currentTrack] bitRate]];
        }
    }
    NSString *length = [NSString stringWithFormat:@"%@", [[itunes currentTrack] time]];
    NSString *bpm = [NSString stringWithFormat:@"%ld", (long) [[itunes currentTrack] bpm]];
    NSString *samplerate = [NSString stringWithFormat:@"%ld", (long) [[itunes currentTrack] sampleRate]];
    NSString *rating = [self getRating:[[itunes currentTrack] rating]];
    NSString *output = [NSString stringWithString:[[[[[[[[[[[[[[[[[[[self formatString] stringByReplacingOccurrencesOfString:@"%_number" withString:number] stringByReplacingOccurrencesOfString:@"%_track" withString:track]  stringByReplacingOccurrencesOfString:@"%_aartist" withString:albumArtist] stringByReplacingOccurrencesOfString:@"%_artist" withString:artist] stringByReplacingOccurrencesOfString:@"%_album" withString:album] stringByReplacingOccurrencesOfString:@"%_genre" withString:genre] stringByReplacingOccurrencesOfString:@"%_year" withString:year] stringByReplacingOccurrencesOfString:@"%_bitrate" withString:bitrate] stringByReplacingOccurrencesOfString:@"%_length" withString:length] stringByReplacingOccurrencesOfString:@"%_playedcount" withString:playcount] stringByReplacingOccurrencesOfString:@"%_rating" withString:rating] stringByReplacingOccurrencesOfString:@"%_skippedcount" withString:skipcount] stringByReplacingOccurrencesOfString:@"%_bpm" withString:bpm]
        stringByReplacingOccurrencesOfString:@"%_comment" withString:comment] stringByReplacingOccurrencesOfString:@"%_samplerate" withString:samplerate]
        stringByReplacingOccurrencesOfString:@"%c" withString:[NSString stringWithFormat:@"%c", _color]]
        stringByReplacingOccurrencesOfString:@"%b" withString:[NSString stringWithFormat:@"%c", _bold]]
        stringByReplacingOccurrencesOfString:@"%_kind" withString:skind]];
    
    return output;
}

-(void)announceToChannel:(IRCChannel *)channel
{
    iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     NSString *message = [self getAnnounceString:itunes];
     if (self.debugEnabled)
          [channel.client printDebugInformation:[NSString stringWithFormat:@"%@", message] channel:channel];
     if (self.styleValue == 0)
          [[channel client] sendCommand:[NSString stringWithFormat:@"me %@", message] completeTarget:YES target:[channel name]];
     else
          [[channel client] sendCommand:[NSString stringWithFormat:@"msg %@ %@", [channel name], message]];
}

-(void)setAway
{
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     NSString *artist = [NSString stringWithFormat:@"%@", [[itunes currentTrack] artist]];
     NSString *title = [NSString stringWithFormat:@"%@", [[itunes currentTrack] name]];
     NSMutableArray *connections = [NSMutableArray array];
     NSArray *untrimmedConnections;     
     if (self.connectionsValue == 2){
          untrimmedConnections = [[[self.connectionName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@","];
          for(NSString *string in untrimmedConnections) {
               [connections addObject:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
          }
     }

     NSString *reason = [NSString stringWithFormat:@"♬ %@ - %@", artist, title];
     switch (self.connectionsValue) {
          case 0:
               // all connections
               for(IRCClient *client in self.worldController.clients){
                    if([itunes playerState] == 'kPSP' && [title isNotEqualTo:@"(null)"]){
                         [client toggleAwayStatus:YES withReason:reason];
                    } else if (client.isAway) {
                         [client toggleAwayStatus:NO];
                    }
               }
          break;
          case 1:
               // selected connection
               if([itunes playerState] == 'kPSP' && [title isNotEqualTo:@"(null)"]){
                    [self.worldController.selectedClient toggleAwayStatus:YES withReason:reason];
               } else if (self.worldController.selectedClient.isAway) {
                    [self.worldController.selectedClient toggleAwayStatus:NO];
               }
          break;
          case 2:
               // connection with name
               for(IRCClient *client in self.worldController.clients){
                    if([connections containsObject:[[client name] lowercaseString]]){
                         if([itunes playerState] == 'kPSP' && [title isNotEqualTo:@"(null)"]){
                              [client toggleAwayStatus:YES withReason:reason];
                         } else if (client.isAway) {
                              [client toggleAwayStatus:NO];
                         }
                    }
               }
          break;
     }
}

-(void)sendAnnounceString:(NSString *)announceString asAction:(BOOL)action
{
     NSMutableArray *connections = [NSMutableArray array];
     NSMutableArray *channels = [NSMutableArray array];
     NSArray *untrimmedChannels, *untrimmedConnections;
     NSInteger style = action ? 0 : self.styleValue;
     
     if (self.connectionsValue == 2){
          untrimmedConnections = [[[self.connectionName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@","];
          for(NSString *string in untrimmedConnections) {
               [connections addObject:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
          }
     }
     if (self.channelsValue == 2){
          untrimmedChannels = [[[self.channelName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@","];
          for(NSString *string in untrimmedChannels) {
               [channels addObject:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
          }
     }
     
     switch (self.connectionsValue) {
          case 0:
               // All Connections
               switch ([self channelsValue]) {
                    case 0:
                         // All Channels
                         for(IRCClient *client in self.worldController.clients){
                              for(IRCChannel *channel in [client channels]){
                                   if([channel isChannel]){
                                        [self sendMessage:announceString toChannel:channel withStyle:style];
                                   }
                              }
                         }
                         break;
                    case 1:
                         // Selected Channel
                         for(IRCClient *client in self.worldController.clients){
                              if ([self.worldController.selectedChannel client] == client){
                                   [self sendMessage:announceString toChannel:self.worldController.selectedChannel withStyle:style];
                              }
                         }
                         break;
                    case 2:
                         // Channel with Name
                         for(IRCClient *client in self.worldController.clients){
                              if([client isClient] && [client isConnected]){
                                   for(IRCChannel *channel in [client channels]){
                                        if([channels containsObject:[[channel name] lowercaseString]]){
                                             [self sendMessage:announceString toChannel:channel withStyle:style];
                                        }
                                   }
                              }
                         }
                         break;
               }
               break;
          case 1:
               // Selected Connection
               switch ([self channelsValue]) {
                    case 0:
                         // ALl Channels
                         for(IRCChannel *channel in self.worldController.selectedClient.channels){
                              [self sendMessage:announceString toChannel:channel withStyle:style];
                         }
                         break;
                    case 1:
                         // Selected Channel
                         [self sendMessage:announceString toChannel:self.worldController.selectedChannel withStyle:style];
                         break;
                    case 2:
                         // Channel with Name
                         for(IRCChannel *channel in self.worldController.selectedClient.channels){
                              if([channels containsObject:[[channel name] lowercaseString]]){
                                   [self sendMessage:announceString toChannel:channel withStyle:style];
                              }
                         }
                         break;
               }
               break;
          case 2:
               // Connection with Name
               switch ([self channelsValue]) {
                    case 0:
                         // All Channels
                         for(IRCClient *client in self.worldController.clients){
                              if([connections containsObject:[[client name] lowercaseString]]){
                                   for(IRCChannel *channel in [client channels]){
                                        [self sendMessage:announceString toChannel:channel withStyle:style];
                                   }
                              }
                         }
                         break;
                    case 1:
                         // Selected Channel
                         for(IRCClient *client in self.worldController.clients){
                              if([connections containsObject:[[client name] lowercaseString]]){
                                   [self sendMessage:announceString toChannel:self.worldController.selectedChannel withStyle:style];
                              }
                         }
                         break;
                    case 2:
                         // Channel with Name
                         for(IRCClient *client in self.worldController.clients){
                              if([connections containsObject:[[client name] lowercaseString]]){
                                   for(IRCChannel *channel in [client channels]){
                                        if([channels containsObject:[[channel name] lowercaseString]]){
                                             [self sendMessage:announceString toChannel:channel withStyle:style];
                                        }
                                   }
                              }
                         }
                         break;
               }
               break;
     }
}

-(void)trackNotification:(NSNotification *)notif
{
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     if ([self pluginEnabled] || [self debugEnabled]){
        if ([itunes playerState] == 'kPSP' && [itunes playerPosition] < 3 && [[itunes currentTrack] size] > 0){
             [self sendAnnounceString:[self getAnnounceString:itunes] asAction:NO];
        }

     }
     if(self.awayMessageEnabled) {
          [self setAway];
     }
}

@end