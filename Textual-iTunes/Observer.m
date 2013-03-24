//
//  Observer.m
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Toby P. All rights reserved.
//

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
    if([comment isEqualToString:@""]){
        comment = @"n/a";
    }
    NSString *skind;
//    NSLog(@"CATEGORY: %@", [[itunes currentTrack] category]);
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
    NSString *output = [NSString stringWithString:[[[[[[[[[[[[[[[[[[[self formatString] stringByReplacingOccurrencesOfString:@"%number" withString:number] stringByReplacingOccurrencesOfString:@"%track" withString:track]  stringByReplacingOccurrencesOfString:@"%albumartist" withString:albumArtist] stringByReplacingOccurrencesOfString:@"%artist" withString:artist] stringByReplacingOccurrencesOfString:@"%album" withString:album] stringByReplacingOccurrencesOfString:@"%genre" withString:genre] stringByReplacingOccurrencesOfString:@"%year" withString:year] stringByReplacingOccurrencesOfString:@"%bitrate" withString:bitrate] stringByReplacingOccurrencesOfString:@"%length" withString:length] stringByReplacingOccurrencesOfString:@"%playedcount" withString:playcount] stringByReplacingOccurrencesOfString:@"%rating" withString:rating] stringByReplacingOccurrencesOfString:@"%skippedcount" withString:skipcount] stringByReplacingOccurrencesOfString:@"%bpm" withString:bpm]
        stringByReplacingOccurrencesOfString:@"%comment" withString:comment] stringByReplacingOccurrencesOfString:@"%samplerate" withString:samplerate]
        stringByReplacingOccurrencesOfString:@"%c" withString:[NSString stringWithFormat:@"%c", _color]]
        stringByReplacingOccurrencesOfString:@"%b" withString:[NSString stringWithFormat:@"%c", _bold]]
        stringByReplacingOccurrencesOfString:@"%kind" withString:skind]];
    
    return output;
}

-(void)announceToChannel:(IRCChannel *)channel
{

    iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSString *output = [self getAnnounceString:itunes];
     IRCClient *client = self.worldController.selectedClient;
    if (self.styleValue == 0) {
        if (self.debugEnabled)
             [client printDebugInformation:[NSString stringWithFormat:@"(action) %@", output] channel:channel];
         [client sendCommand:[NSString stringWithFormat:@"me %@", output] completeTarget:YES target:[channel name]];
    } else {
        if (self.debugEnabled)
             [client printDebugInformation:[NSString stringWithFormat:@"%@", output] channel:channel];
         [client sendCommand:[NSString stringWithFormat:@"msg %@ %@", [channel name], output]];
    }

}

-(void)sendAnnounceString:(NSString *)announceString asAction:(BOOL)action
{
     NSArray *connections, *channels;
     NSInteger style = action ? 0 : self.styleValue;
     
     if (self.connectionsValue == 2){
          connections = [[self.connectionName lowercaseString] componentsSeparatedByString:@" "];
     }
     if (self.channelsValue == 2){
          channels = [[self.channelName lowercaseString] componentsSeparatedByString:@" "];
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
    if ([self pluginEnabled] || [self debugEnabled]){
        iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if ([itunes playerState] == 'kPSP' && [itunes playerPosition] < 3 && [[itunes currentTrack] size] > 0){
             NSString *output = [self getAnnounceString:itunes];
             [self sendAnnounceString:output asAction:NO];
        }
 
    }
}

@end
