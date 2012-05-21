/***********************************************************************
 * Created by Andreas Paffenholz on 04/18/12.
 * Copyright 2012 by Andreas Paffenholz. 
 
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl.txt.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * PropertyView.m
 * PolyViewer
 **************************************************************************/

#import "PropertyView.h"


@implementation PropertyView

- (id)init {
	NSLog(@"[PropertyView] init]");
	self = [super init];
	return self;	
}


-(id)_highlightColorForCell:(NSCell *)cell {
  return [NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1];
}
 

@end
