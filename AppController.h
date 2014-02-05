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
 * AppController.h
 * PolyViewer
 **************************************************************************/

#import <Cocoa/Cocoa.h>
#import "PreferencesController.h"
#import "RetrieveFromDBController.h"
#import "PolymakeInstanceWrapper.h"

@interface AppController : NSDocumentController {

	PreferencesController * _preferencesController;
    RetrieveFromDBController * _retrieveController;
    
    PolymakeInstanceWrapper *pinst;
	
}



@property (retain) PreferencesController *preferencesController;
@property (retain) RetrieveFromDBController *retrieveController;

-(IBAction)showPreferences:(id)sender;
-(IBAction)showRetrieveFromDB:(id)sender;

-(BOOL)applicationShouldOpenUntitledFile:(NSApplication*)app;

-(NSArray *)databaseNames;
-(NSArray *)collectionNamesOfDatabase:(NSString *)db;

@end
