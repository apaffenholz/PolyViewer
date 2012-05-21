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
 * AppController.m
 * PolyViewer
 **************************************************************************/

#import "AppController.h"
#import "PolymakeFile.h"

@implementation AppController

-(id)init {
	self = [super init];
	return self;
	
}

@synthesize preferencesController = _preferencesController;

-(IBAction)showPreferences:(id)sender{
  if(!self.preferencesController)
		self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
	
  [self.preferencesController showWindow:self];
}

- (void)dealloc {
  [_preferencesController release];
  [super dealloc];
}


-(BOOL)applicationShouldOpenUntitledFile:(NSApplication*)theApplication {
	return NO;
}


	// closing a window should close the app
- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
	return YES;
}	


@end
