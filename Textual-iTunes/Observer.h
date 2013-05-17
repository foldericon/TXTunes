//
//  Observer.h
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

#import "iTunes.h"
#import "TextualApplication.h"

@interface Observer : NSObject

- (NSString *)getRating:(NSInteger)rating;
-(void)sendAnnounceString:(NSString *)announceString asAction:(BOOL)action;
-(void)trackNotification:(NSNotification*)notif;
-(void)announceToChannel:(IRCChannel *)channel;

@end

