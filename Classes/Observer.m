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
    if ([channel isChannel] && [[channel memberList] count] > 0){
        if (style == 0){
            if ([self announceEnabled]) {
                 [channel.client sendLine:[NSString stringWithFormat:@"privmsg %@ :%cACTION %@%c", channel.name, _action, message, _action]];
                 [channel.client print:channel
                                  type:TVCLogLineActionType
                                  nick:channel.client.localNickname
                                  text:message
                             encrypted:NSObjectIsNotEmpty(channel.config.encryptionKey)
                            receivedAt:[NSDate date]
                               command:@"ME"];
            }
        } else {
            if ([self announceEnabled]) {
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
}

-(NSString *)getAnnounceString:(iTunesApplication *)itunes withFormat:(NSString *)formatString
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

     if ([itunes.currentStreamTitle isNotEqualTo:@""]) {
          NSArray *info = [itunes.currentStreamTitle componentsSeparatedByString:@" - "];
          if(info.count > 1) {
               artist = [info objectAtIndex:0];
               track = [info objectAtIndex:1];
          }
          kind = @"Internet Radio";
     } else {
          if(itunes.currentTrack.size == 0 && [itunes.currentTrack.kind isEqualTo:@""]) {
               kind = @"iTunes Radio";
          }
     }
     
     if ([track isEqualTo:@""] || [artist isEqualTo:@""]) {
          return @"";
     }
     
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
    } else if ([kind isNotEqualTo:@""]){
         skind=kind;
    } else {
         skind=@"n/a";
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
    NSString *output = [NSString stringWithString:[[[[[[[[[[[[[[[[[[formatString stringByReplacingOccurrencesOfString:@"%_number" withString:number] stringByReplacingOccurrencesOfString:@"%_track" withString:track]  stringByReplacingOccurrencesOfString:@"%_aartist" withString:albumArtist] stringByReplacingOccurrencesOfString:@"%_artist" withString:artist] stringByReplacingOccurrencesOfString:@"%_album" withString:album] stringByReplacingOccurrencesOfString:@"%_genre" withString:genre] stringByReplacingOccurrencesOfString:@"%_year" withString:year] stringByReplacingOccurrencesOfString:@"%_bitrate" withString:bitrate] stringByReplacingOccurrencesOfString:@"%_length" withString:length] stringByReplacingOccurrencesOfString:@"%_playedcount" withString:playcount] stringByReplacingOccurrencesOfString:@"%_rating" withString:rating] stringByReplacingOccurrencesOfString:@"%_skippedcount" withString:skipcount] stringByReplacingOccurrencesOfString:@"%_bpm" withString:bpm]
        stringByReplacingOccurrencesOfString:@"%_comment" withString:comment] stringByReplacingOccurrencesOfString:@"%_samplerate" withString:samplerate]
        stringByReplacingOccurrencesOfString:@"%c" withString:[NSString stringWithFormat:@"%c", _color]]
        stringByReplacingOccurrencesOfString:@"%b" withString:[NSString stringWithFormat:@"%c", _bold]]
        stringByReplacingOccurrencesOfString:@"%_kind" withString:skind]];
    
    output = [output stringByReplacingOccurrencesOfString:@"(null)" withString:@"n/a"];
    return output;
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
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     if(itunes.isRunning) {
          if ([self announceEnabled]){
             if ([itunes playerState] == 'kPSP' && [itunes playerPosition] < 3){
                  [self sendAnnounceString:[self getAnnounceString:itunes withFormat:self.formatString] asAction:NO];
             }

          }
          if(self.awayMessageEnabled) {
               [self setAway];
          }
     }
}

@end
