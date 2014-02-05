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
 * RetrieveFromDBController.m
 * PolyViewer
 **************************************************************************/

#import "RetrieveFromDBController.h"
#import "PolymakeFile.h"
#import "AppController.h"
#import "PolymakeInstanceWrapper.h"

@implementation RetrieveFromDBController

@synthesize database = _database;
@synthesize collection = _collection;
@synthesize ID = _ID;
@synthesize databases = _databases;
@synthesize collections = _collections;


-(id)init {
	self = [super init];
	if (self) {
        _database = nil;
        _collection = nil;
        _ID = nil;
        _databases = nil;
        _collections = nil;


    }
    
	return self;
}


-(void)dealloc {
	[_database release];
    [_collection dealloc];
    [_ID dealloc];
    
	[super dealloc];
}


- (void)windowDidLoad {
	NSLog(@"[RetrieveFromDBController windowDidLoad] called");
    
    // start with some example values to prevent the obvious crash
    // as we currently don't do any value checking
    _database = @"Tropical";
    _collection = @"SmoothReflexive";
    _ID = @"F.4D.0123";
    [databaseTextfield setStringValue:_database];
    [collectionTextfield setStringValue:_collection];
    [IDTextfield setStringValue:_ID];
    
    _databases = [[[NSApp delegate] databaseNames] retain];
    [databaseSelection addItemsWithObjectValues:_databases];
    [databaseSelection selectItemWithObjectValue:_database];
    
    NSString * selectedDatabase = [_databases objectAtIndex:[databaseSelection selectedTag]];
	NSLog(@"[RetrieveFromDBController windowDidLoad] got db: %@", selectedDatabase);
    _collections = [[[NSApp delegate] collectionNamesOfDatabase:selectedDatabase] retain];
    NSLog(@"[RetrieveFromDBController windowDidLoad] got collections: %@", _collections);
    [collectionSelection removeAllItems];
    [collectionSelection addItemsWithObjectValues:_collections];
    [collectionSelection selectItemAtIndex:0];
    [collectionSelection setObjectValue:[collectionSelection objectValueOfSelectedItem]];
    
    NSLog(@"[RetrieveFromDBController windowDidLoad] database names are %@",_databases);
}

- (IBAction)retrieveFromDB:(id)sender {
    NSLog(@"[RetrieveFromDBController retrieveFromDB] called");

    NSLog(@"[RetrieveFromDBController retrieveFromDB] index of selected item: %ld",(long)[databaseSelection indexOfSelectedItem]);
    
    _database = (NSString *)[_databases objectAtIndex:[databaseSelection indexOfSelectedItem]];
    NSLog(@"[RetrieveFromDBController retrieveFromDB] selected item: %@",_database);
    PolymakeFile * pf = [[PolymakeFile alloc] init];
    [pf readFromDatabase:_database andCollection:_collection withID:_ID];
    
    [pf makeWindowControllers];
    [pf showWindows];
    [[NSDocumentController sharedDocumentController] addDocument:pf];
    [pf release];
    [[self window] orderOut:nil];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {

    id myObject = [notification object];
    if ( myObject == databaseSelection ) {
    
        NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] entered");
        
        NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
        
        NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] selected database: %@", selectedDatabase);
        if ( _collections != nil )
            [_collections release];
        _collections = [[[NSApp delegate] collectionNamesOfDatabase:selectedDatabase] retain];
        NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] got collections: %@", _collections);
        NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] of size: %lu", (unsigned long)[_collections count]);
        [collectionSelection removeAllItems];
        [collectionSelection addItemsWithObjectValues:_collections];
        [collectionSelection selectItemAtIndex:0];
        [collectionSelection setObjectValue:[collectionSelection objectValueOfSelectedItem]];
    }
}

- (IBAction)updateCollection:(id)sender {
}

@end
