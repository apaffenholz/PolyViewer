/***********************************************************************
 * Created by Andreas Paffenholz on 04/18/12.
 * Copyright 2012-2014 by Andreas Paffenholz. 
 
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl.txt.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * AppWindowController.m
 * PolyViewer
 **************************************************************************/


#import "AppWindowController.h"
#import "PolymakeFile.h"

@implementation AppWindowController


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	NSString * title = @"<no name given>";
	if ( [self document] != nil ) {
		title = [[[self document] polymakeObject] name];
	}

	return title;	
}

@end
