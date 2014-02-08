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
 * AppController.m
 * PolyViewer
 **************************************************************************/

#import "AppController.h"
#import "PolymakeFile.h"

@implementation AppController

-(id)init {
	self = [super init];
    
    pinst = [[PolymakeInstanceWrapper alloc] init];
    [pinst createScope];
    
	return self;
}

@synthesize preferencesController = _preferencesController;
@synthesize retrieveController    = _retrieveController;

-(IBAction)showPreferences:(id)sender{
  NSLog(@"[AppController showPreferences] called");
    if(!self.preferencesController) {
		self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    }
	
  [self.preferencesController showWindow:self];
  NSLog(@"[AppController showPreferences] leaving");
}

-(IBAction)showRetrieveFromDB:(id)sender {
    NSLog(@"[AppController showRetrieveFromDB] called");
    if(!self.retrieveController) {
		self.retrieveController = [[RetrieveFromDBController alloc] initWithWindowNibName:@"DatabaseAccess"];
    }
    
    [self.retrieveController showWindow:self];
    NSLog(@"[AppController showRetrieveFromDB] leaving");
}

- (void)dealloc {
    [_preferencesController release];
    [_retrieveController release];
    [pinst release];
    [super dealloc];
}


-(BOOL)applicationShouldOpenUntitledFile:(NSApplication*)theApplication {
	return NO;
}


	// closing a window should NOT close the app
- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
	return NO;
}	

-(NSArray *)databaseNames {
    return [pinst databaseNames];
}

-(NSArray *)collectionNamesOfDatabase:(NSString *)db {
    return [pinst collectionNamesofDatabase:db];
}

- (NSArray *) idsForDatabase:(NSString *)selectedDatabase
               andCollection:(NSString *)selectedCollection
     withAddtionalProperties:(NSString *)additionalProps
            restrictToAmount:(NSNumber *)amount
                  startingAt:(NSNumber *)start {
  return [pinst idsForDatabase:selectedDatabase
                 andCollection:selectedCollection
       withAddtionalProperties:additionalProps
              restrictToAmount:amount
                    startingAt:start];
}

@end
