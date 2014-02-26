/***********************************************************************
 * Created by Andreas Paffenholz on 24/02/14.
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
 * MainController.h
 * PolyViewer
 **************************************************************************/

#import "MainController.h"

@implementation MainController

@synthesize preferencesController = _preferencesController;
@synthesize retrieveController    = _retrieveController;
@synthesize databaseConnection    = _databaseConnection;
@synthesize configuredExtensions  = _configuredExtensions;


# pragma mark init

/****************************************************************/
-(id)init {
    NSLog(@"[Appcontroller init] called");
	self = [super init];
    
    pinst = [[PolymakeInstanceWrapper alloc] init];
    [pinst createScope];
    _configuredExtensions = [pinst configuredExtensions];
    
    if ( [_configuredExtensions containsObject:@"poly_db"] ) {
        _databaseConnection = [[DatabaseAccess alloc] init];
    } else {
        _databaseConnection = nil;
    }
    
    
    
	return self;
}

/****************************************************************/
- (void)dealloc {
    [_preferencesController release];
    [_retrieveController release];
    [pinst release];
    [super dealloc];
}




/****************************************************************
 *
 * methods overwritten form base class
 *
 ****************************************************************/

/****************************************************************/
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)menuItem {
    

    SEL menuAction = [menuItem action];
    NSLog(@"[AppController validateUserInterfaceItem] called checking %@", NSStringFromSelector(menuAction));
    if (menuAction == @selector(showRetrieveFromDB:)) {
        NSLog(@"[AppController validateUserInterfaceItem] checking for database");
        if ( _databaseConnection == nil ) {
            NSLog(@"[AppController validateUserInterfaceItem] database not found");
            return NO;
        } else
            return YES;
    }
    return YES;
}



/****************************************************************/
-(BOOL)applicationShouldOpenUntitledFile:(NSApplication*)theApplication {
	return NO;
}



/****************************************************************/
// closing a window should NOT close the app
- (BOOL)applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
	return NO;
}




/****************************************************************
 *
 * open menu dialogs
 *
 ****************************************************************/


/****************************************************************/
-(IBAction)showPreferences:(id)sender{
    NSLog(@"[AppController showPreferences] called");
    if(!self.preferencesController) {
		self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    }
	
    [self.preferencesController showWindow:self];
    NSLog(@"[AppController showPreferences] leaving");
}

/****************************************************************/
-(IBAction)showRetrieveFromDB:(id)sender {
    NSLog(@"[AppController showRetrieveFromDB] called");
    if(!self.retrieveController) {
		self.retrieveController = [[RetrieveFromDBController alloc] initWithWindowNibName:@"DatabaseAccess"];
    }
    
    [self.retrieveController showWindow:self];
    NSLog(@"[AppController showRetrieveFromDB] leaving");
}




# pragma mark PolymakeInstanceWrapper

/****************************************************************
 *
 * the following methods pass requests to the polymake instance to the instance wrapper
 *
 ****************************************************************/
-(NSArray *)databaseNames {
    return [pinst databaseNames];
}


/****************************************************************/
-(NSArray *)collectionNamesOfDatabase:(NSString *)db {
    return [pinst collectionNamesofDatabase:db];
}

/****************************************************************/
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

/****************************************************************/
- (NSInteger) countForDatabase:(NSString *)selectedDatabase
                 andCollection:(NSString *)selectedCollection
       withAddtionalProperties:(NSString *)additionalProps {
    return [pinst countForDatabase:selectedDatabase
                     andCollection:selectedCollection
           withAddtionalProperties:additionalProps];
}


@end
