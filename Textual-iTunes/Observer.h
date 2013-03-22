//
//  Observer.h
//  Textual-iTunes
//
//  Created by Toby P on 3/15/13.
//  Copyright (c) 2013 Toby P. All rights reserved.
//

#import "iTunes.h"
#import "TextualApplication.h"

@interface Observer : NSObject

- (NSString *)getRating:(NSInteger)rating;
-(void)trackNotification:(NSNotification*)notif;
-(void)announceToChannel:(IRCChannel *)channel;

@end

