/*
 ===============================================================================
 Copyright (c) 2013-2014, Tobias Pollmann (foldericon)
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
#import "MediaInfo.h"

@implementation Observer

-(void)sendMessage:(NSString *)message toChannel:(IRCChannel *)channel withStyle:(NSInteger)style
{
   if (style == 0)
        [channel.associatedClient sendAction:message toChannel:channel];
   else
        [channel.associatedClient sendPrivmsg:message toChannel:channel];
}

- (void)announceToChannel:(IRCChannel *)channel
{
     self.mediaInfo = [[MediaInfo alloc] initWithFormat:self.formatString];
     NSAssertReturn(self.mediaInfo != nil);
     [self sendMessage:self.mediaInfo.announceString toChannel:channel withStyle:self.styleValue];
}

- (NSArray*)getConnections
{
     NSMutableArray *conns = [[NSMutableArray alloc] init];
     switch (self.connectionsValue) {
          case 0:
               for(IRCClient *client in self.masterController.worldController.clientList){
                    if(client.isConnected) [conns addObject:client];
               }
          break;
          case 1:
               if(self.masterController.mainWindow.selectedClient.isConnected) [conns addObject:self.masterController.mainWindow.selectedClient];
          break;
          case 2:
               for(IRCClient *client in self.masterController.worldController.clientList) {
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
     NSString *announceString = self.mediaInfo.announceString;
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
     NSInteger style = action ? 0 : self.styleValue;     
     switch (self.channelsValue) {
          case 0:
               for(IRCClient *client in [self getConnections]) {
                    for (IRCChannel *channel in client.channelList) {
                         if(channel.isChannel && channel.isActive) [self sendMessage:announceString toChannel:channel withStyle:style];
                    }
               }
               break;
          case 1:
               if(self.masterController.mainWindow.selectedChannel.isActive && self.masterController.mainWindow.selectedChannel.isChannel)
                    [self sendMessage:announceString toChannel:self.masterController.mainWindow.selectedChannel withStyle:style];
               break;
          case 2:
               for(IRCClient *client in [self getConnections]) {
                    for (IRCChannel *channel in client.channelList) {
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
          if(self.mediaInfo) {
               // Avoid spam.
               if(self.mediaInfo.created > [[NSDate date] timeIntervalSince1970]-10 ||
                    ([itunes.currentTrack.artist isEqualToString:self.mediaInfo.infoDict[@"artist"]] &&
                     [itunes.currentTrack.name isEqualToString:self.mediaInfo.infoDict[@"track"]] &&
                     self.mediaInfo.created > [[NSDate date] timeIntervalSince1970]-30)) {
                        return;
               }
          }
          self.mediaInfo = [[MediaInfo alloc] initWithFormat:self.formatString];
          NSAssertReturn(self.mediaInfo != nil);
          if ([self announceEnabled]){
               if ([itunes playerState] == 'kPSP'){
                    [self sendAnnounceString:self.mediaInfo.announceString asAction:NO];
               }

          }
          if(self.awayMessageEnabled) {
               self.mediaInfo = [[MediaInfo alloc] initWithFormat:self.awayFormatString];
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
