//
//  MediaInfo.h
//  TXTunes
//
//  Created by Toby P on 26/01/14.
//  Copyright (c) 2014 Toby P. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

@interface MediaInfo : NSObject

+(NSString *)getRating:(NSInteger)rating;
-(MediaInfo *)initWithFormat:(NSString *)formatString;

@property (nonatomic) NSString *announceString;
@end
