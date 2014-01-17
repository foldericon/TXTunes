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
     if (channel.isChannel && channel.numberOfMembers > 0) {
        if (style == 0){
            [channel.client sendLine:[NSString stringWithFormat:@"privmsg %@ :%cACTION %@%c", channel.name, _action, message, _action]];
            [channel.client print:channel
                             type:TVCLogLineActionType
                             nick:channel.client.localNickname
                             text:message
                        encrypted:NSObjectIsNotEmpty(channel.config.encryptionKey)
                       receivedAt:[NSDate date]
                          command:@"ME"];
        } else {
            [channel.client sendLine:[NSString stringWithFormat:@"privmsg %@ :%@", channel.name, message]];
            [channel.client print:channel
                             type:TVCLogLinePrivateMessageType
                             nick:channel.client.localNickname
                             text:message
                        encrypted:NSObjectIsNotEmpty(channel.config.encryptionKey)
                       receivedAt:[NSDate date]
                          command:@"MSG"];
        }
    }
}


-(BOOL)isNullValue:(NSString *)string
{
     if(!string || [string isEqualToString:@""] || [string isEqualToString:@"(null)"]) {
          return YES;
     }
     return NO;
}

-(NSString *)getAnnounceString:(iTunesApplication *)itunes withFormat:(NSString *)formatString
{
     if ([self isNullValue:itunes.currentTrack.name] || [self isNullValue:itunes.currentTrack.artist]) {
          return @"";
     }
     
     NSDictionary *infoDict = @{ @"number"        : [NSString stringWithFormat:@"%ld", (long)itunes.currentTrack.trackNumber],
                                 @"track"         : [NSString stringWithFormat:@"%@", itunes.currentTrack.name],
                                 @"artist"        : [NSString stringWithFormat:@"%@", itunes.currentTrack.artist],
                                 @"albumArtist"   : [self isNullValue:itunes.currentTrack.albumArtist] ? @"n/a" : [NSString stringWithFormat:@"%@", itunes.currentTrack.albumArtist],
                                 @"album"         : [self isNullValue:itunes.currentTrack.album] ? @"n/a" : [NSString stringWithFormat:@"%@", itunes.currentTrack.album],
                                 @"genre"         : [self isNullValue:itunes.currentTrack.genre] ? @"n/a" : [NSString stringWithFormat:@"%@", itunes.currentTrack.genre],
                                 @"year"          : itunes.currentTrack.year == 0 ? @"n/a" : [NSString stringWithFormat:@"%ld", (long)itunes.currentTrack.year],
                                 @"playcount"     : [NSString stringWithFormat:@"%ld", (long)itunes.currentTrack.playedCount],
                                 @"skipcount"     : [NSString stringWithFormat:@"%ld", (long)itunes.currentTrack.skippedCount],
                                 @"kind"          : [NSString stringWithFormat:@"%@", itunes.currentTrack.kind],
                                 @"comment"       : [self isNullValue:itunes.currentTrack.comment] ? @"n/a" : [NSString stringWithFormat:@"%@", itunes.currentTrack.comment],
                                 @"playlist"      : [self isNullValue:itunes.currentPlaylist.name] ? @"n/a" : [NSString stringWithFormat:@"%@", itunes.currentPlaylist.name],
                                 @"bitrate"       : [NSString stringWithFormat:@"%ldkbps (VBR)", (long) itunes.currentTrack.bitRate],
                                 @"length"        : [NSString stringWithFormat:@"%@", itunes.currentTrack.time],
                                 @"bpm"           : [NSString stringWithFormat:@"%ld", (long) itunes.currentTrack.bpm],
                                 @"samplerate"    : [NSString stringWithFormat:@"%ld", (long) itunes.currentTrack.sampleRate],
                                 @"rating"        : [self getRating:itunes.currentTrack.rating],
                               };
     
     NSMutableDictionary *mediaInfo = [infoDict mutableCopy];
     
     mediaInfo[@"kind"] = [mediaInfo[@"kind"] isEqualToString:@"MPEG audio file"] ? @"MP3" : [mediaInfo[@"kind"] isEqualToString:@"Apple Lossless audio file"] ? @"ALAC" : [mediaInfo[@"kind"] isEqualToString:@"AAC audio file"] || [mediaInfo[@"kind"] isEqualToString:@"Purchased AAC audio file"] ? @"AAC" : mediaInfo[@"kind"];
     
     if ([self isNullValue:itunes.currentStreamTitle] == NO) {
          NSArray *info = [itunes.currentStreamTitle componentsSeparatedByString:@" - "];
          if(info.count > 1) {
               mediaInfo[@"artist"] = [info objectAtIndex:0];
               mediaInfo[@"track"] = [info objectAtIndex:1];
          }
          mediaInfo[@"kind"] = @"Internet Radio";
     } else if(itunes.currentTrack.size == 0 && [self isNullValue:itunes.currentTrack.kind]) {
          // Don't post advertising
          if([self isNullValue:mediaInfo[@"album"]]) return @"";
          mediaInfo[@"kind"] = @"iTunes Radio";
     }
     
     if ([mediaInfo[@"kind"] isEqualToString:@"MP3"] || [mediaInfo[@"kind"] isEqualToString:@"AAC"]){
          if (itunes.currentTrack.bitRate % 16 != 0){
               mediaInfo[@"bitrate"] = [NSString stringWithFormat:@"%ldkbps (VBR)", (long) itunes.currentTrack.bitRate];
          }
     }
     
     return [[[[[[[[[[[[[[[[[[[formatString
                          stringByReplacingOccurrencesOfString:@"%_number" withString:mediaInfo[@"number"]]
                          stringByReplacingOccurrencesOfString:@"%_track" withString:mediaInfo[@"track"]]
                          stringByReplacingOccurrencesOfString:@"%_artist" withString:mediaInfo[@"artist"]]
                          stringByReplacingOccurrencesOfString:@"%_aartist" withString:mediaInfo[@"albumArtist"]]
                          stringByReplacingOccurrencesOfString:@"%_album" withString:mediaInfo[@"album"]]
                          stringByReplacingOccurrencesOfString:@"%_genre" withString:mediaInfo[@"genre"]]
                          stringByReplacingOccurrencesOfString:@"%_year" withString:mediaInfo[@"year"]]
                          stringByReplacingOccurrencesOfString:@"%_bitrate" withString:mediaInfo[@"bitrate"]]
                          stringByReplacingOccurrencesOfString:@"%_length" withString:mediaInfo[@"length"]]
                          stringByReplacingOccurrencesOfString:@"%_rating" withString:mediaInfo[@"rating"]]
                          stringByReplacingOccurrencesOfString:@"%_playedcount" withString:mediaInfo[@"playcount"]]
                          stringByReplacingOccurrencesOfString:@"%_skippedcount" withString:mediaInfo[@"skipcount"]]
                          stringByReplacingOccurrencesOfString:@"%_bpm" withString:mediaInfo[@"bpm"]]
                          stringByReplacingOccurrencesOfString:@"%_samplerate" withString:mediaInfo[@"samplerate"]]
                          stringByReplacingOccurrencesOfString:@"%_comment" withString:mediaInfo[@"comment"]]
                          stringByReplacingOccurrencesOfString:@"%_kind" withString:mediaInfo[@"kind"]]
                          stringByReplacingOccurrencesOfString:@"%_playlist" withString:mediaInfo[@"playlist"]]
                          stringByReplacingOccurrencesOfString:@"%c" withString:[NSString stringWithFormat:@"%c", _color]]
                          stringByReplacingOccurrencesOfString:@"%b" withString:[NSString stringWithFormat:@"%c", _bold]];
}

- (void)announceToChannel:(IRCChannel *)channel
{
    iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     NSString *announceString = [self getAnnounceString:itunes withFormat:self.formatString];
     NSAssertReturn([announceString isNotEqualTo:@""]);
     if (self.styleValue == 0)
          [[channel client] sendCommand:[NSString stringWithFormat:@"me %@", announceString] completeTarget:YES target:[channel name]];
     else
          [[channel client] sendCommand:[NSString stringWithFormat:@"msg %@ %@", [channel name], announceString]];
}

- (NSArray*)getConnections
{
     NSMutableArray *conns = [[NSMutableArray alloc] init];
     switch (self.connectionsValue) {
          case 0:
               for(IRCClient *client in self.worldController.clients){
                    if(client.isConnected) [conns addObject:client];
               }
          break;
          case 1:
               if(self.worldController.selectedClient.isConnected) [conns addObject:self.worldController.selectedClient];
          break;
          case 2:
               for(IRCClient *client in self.worldController.clients) {
                    if(client.isConnected && [self.connectionTargets containsObject:client.config.itemUUID]){
                         [conns addObject:client];
                    }
               }
          break;
     }
     return conns;
}

- (void)setAway
{
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     NSString *announceString = [self getAnnounceString:itunes withFormat:self.awayFormatString];
     NSAssertReturn([announceString isNotEqualTo:@""]);
     for (IRCClient *client in [self getConnections]) {
          if([itunes playerState] == 'kPSP' && [itunes.currentTrack.name isNotEqualTo:@"(null)"]){
               [client toggleAwayStatus:YES withReason:announceString];
          } else if(client.isAway) {
               [client toggleAwayStatus:NO];
          }
     }
}

-(void)sendAnnounceString:(NSString *)announceString asAction:(BOOL)action
{
     NSAssertReturn([announceString isNotEqualTo:@""]);
     NSInteger style = action ? 0 : self.styleValue;     
     switch (self.channelsValue) {
          case 0:
               for(IRCClient *client in [self getConnections]) {
                    for (IRCChannel *channel in client.channels) {
                         if(channel.isChannel && channel.isActive) [self sendMessage:announceString toChannel:channel withStyle:style];
                    }
               }
               break;
          case 1:
               if(self.worldController.selectedChannel.isActive && self.worldController.selectedChannel.isChannel)
                    [self sendMessage:announceString toChannel:self.worldController.selectedChannel withStyle:style];
               break;
          case 2:
               for(IRCClient *client in [self getConnections]) {
                    for (IRCChannel *channel in client.channels) {
                         if(channel.isChannel && channel.isActive && [self.channelTargets containsObjectIgnoringCase:channel.name])
                              [self sendMessage:announceString toChannel:channel withStyle:style];
                    }
               }
               break;
     }
}

-(void)trackNotification:(NSNotification *)notif
{
     NSString *playerState = [notif.userInfo objectForKey:@"Player State"];
     NSAssertReturn([playerState isNotEqualTo:@"Stopped"]);
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     if(itunes.isRunning) {
          if ([self announceEnabled]){
               if ([itunes playerState] == 'kPSP'){
                    [self sendAnnounceString:[self getAnnounceString:itunes withFormat:self.formatString] asAction:NO];
               }

          }
          if(self.awayMessageEnabled) {
               if([playerState isEqualToString:@"Playing"]) {
                    [self setAway];
               } else if ([playerState isEqualToString:@"Paused"]) {
                    for (IRCClient *client in [self getConnections]) {
                         if(client.isAway) {
                              [client toggleAwayStatus:NO];
                         }
                    }
               }
          }
     }
}

@end
