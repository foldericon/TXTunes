//
//  MediaInfo.m
//  TXTunes
//
//  Created by Toby P on 26/01/14.
//  Copyright (c) 2014 Toby P. All rights reserved.
//

#import "MediaInfo.h"

@implementation MediaInfo

+ (NSString *)getRating:(NSInteger)rating
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

-(BOOL)isNullValue:(NSString *)string
{
     if(!string || [string isEqualToString:@""] || [string isEqualToString:@"(null)"]) {
          return YES;
     }
     return NO;
}

-(MediaInfo *)initWithFormat:(NSString *)formatString
{
     iTunesApplication *itunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
     
     if(!self) self = [super init];
     
     if ([self isNullValue:itunes.currentTrack.name] || [self isNullValue:itunes.currentTrack.artist]) {
          return nil;
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
                                 @"rating"        : [MediaInfo getRating:itunes.currentTrack.rating],
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
          if([self isNullValue:itunes.currentTrack.album]) return nil;
          mediaInfo[@"kind"] = @"iTunes Radio";
     }
     
     if ([mediaInfo[@"kind"] isEqualToString:@"MP3"] || [mediaInfo[@"kind"] isEqualToString:@"AAC"]){
          if (itunes.currentTrack.bitRate % 16 != 0){
               mediaInfo[@"bitrate"] = [NSString stringWithFormat:@"%ldkbps (VBR)", (long) itunes.currentTrack.bitRate];
          }
     }
     
     self.announceString = [[[[[[[[[[[[[[[[[formatString
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
                                        stringByReplacingOccurrencesOfString:@"%_playlist" withString:mediaInfo[@"playlist"]];

     
     
     return self;
}

@end
