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
#import "PolymakeObjectController.h"
#import "AppController.h"
#import "PolymakeInstanceWrapper.h"
#import "DatabaseAccess.h"

@implementation RetrieveFromDBController

@synthesize database = _database;
@synthesize collection = _collection;
@synthesize ID = _ID;
@synthesize databases = _databases;
@synthesize collections = _collections;
@synthesize reportNumberOfResults = _reportNumberOfResults;


-(id)init {
	self = [super init];
	if (self) {
        _database = nil;
        _collection = nil;
        _ID = nil;
        _databases = nil;
        _collections = nil;
        _reportNumberOfResults = nil;
        _IDs = nil;
    }
    
	return self;
}


-(void)dealloc {
	[_database release];
    [_collection dealloc];
    [_ID dealloc];
    [_IDs dealloc];
    
	[super dealloc];
}


- (void)windowDidLoad {
	NSLog(@"[RetrieveFromDBController windowDidLoad] called");
    
    // start with some example values to prevent the obvious crash
    // as we currently don't do any value checking
    _database = nil;
    _collection = nil;
    _ID = nil;
    [self setReportNumberOfResults:@"no results"];
    [_reportNumberOfResultsLabel setStringValue:_reportNumberOfResults];
    
    _databases = [[[NSApp delegate] databaseNames] retain];
    [databaseSelection addItemsWithObjectValues:_databases];
    if ( [_databases count] > 0 ) {
        [databaseSelection selectItemAtIndex:0];
        [databaseSelection setObjectValue:[databaseSelection objectValueOfSelectedItem]];
    }
    
    NSString * selectedDatabase = [_databases objectAtIndex:[databaseSelection selectedTag]];

    
	NSLog(@"[RetrieveFromDBController windowDidLoad] got db: %@", selectedDatabase);
    NSLog(@"[RetrieveFromDBController windowDidLoad] database names are %@",_databases);
}
    

- (IBAction)retrieveFromDB:(id)sender {
    NSLog(@"[RetrieveFromDBController retrieveFromDB] called");

    NSLog(@"[RetrieveFromDBController retrieveFromDB] index of selected item: %ld",(long)[databaseSelection indexOfSelectedItem]);
    
    _database = (NSString *)[_databases objectAtIndex:[databaseSelection indexOfSelectedItem]];
    _collection = (NSString *)[_collections objectAtIndex:[collectionSelection indexOfSelectedItem]];
    _ID = (NSString *)[_IDs objectAtIndex:[idSelection indexOfSelectedItem]];
  
    NSLog(@"[RetrieveFromDBController retrieveFromDB] selected item: %@",_database);
    PolymakeObjectController * pf = [[PolymakeObjectController alloc] init];
    [pf readFromDatabase:_database andCollection:_collection withID:_ID];
    
    [pf makeWindowControllers];
    [pf showWindows];
    [[NSDocumentController sharedDocumentController] addDocument:pf];
    [pf release];
    //[[self window] orderOut:nil];
}
 
// action if the query button is pressed
- (IBAction)queryDB:(id)sender {
    NSLog(@"[RetrieveFromDBController queryDB:sender] entered");    
    NSInteger count = [self queryDB];
    NSString * numberReportTotal = [NSString stringWithFormat:@"database elements satisfying given properties: %ld", count];
    [_reportTotalNumberOfResultsLabel setStringValue:numberReportTotal];
    if ( count > [[[[NSApp delegate] databaseConnection] amount] intValue] )
        [_reportTotalNumberOfResultsLabel setTextColor:[NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1]];

}
    
- (IBAction) getIdsForCurrentSelections:(id)sender {
    [self updateCollection];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {

    NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] entered");
    
    id myObject = [notification object];
    if ( myObject == databaseSelection ) {    // the selected database has changed, so we retrieve the list of collections
        [self updateCollectionList];
    } else {
        // currently do nothing if other sections change
    }
}
    
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"[RetrieveDromDBController controlTextDidChange] %@", [textField stringValue]);
}


- (void) updateCollectionList {
    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSLog(@"[RetrieveFromDBController updateCollectionList] selected database: %@", selectedDatabase);

    if ( _collections != nil )
        [_collections release];
    _collections = [[[NSApp delegate] collectionNamesOfDatabase:selectedDatabase] retain];

    NSLog(@"[RetrieveFromDBController updateCollectionList] got collections: %@", _collections);
    NSLog(@"[RetrieveFromDBController updateCollectionList] of size: %lu", (unsigned long)[_collections count]);

    [collectionSelection removeAllItems];
    [collectionSelection addItemsWithObjectValues:_collections];

    if ( [_collections count] > 0 ) {
        [collectionSelection selectItemAtIndex:0];
        [collectionSelection setObjectValue:[collectionSelection objectValueOfSelectedItem]];
    }
}
    
- (NSInteger)queryDB {
    
    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSString * selectedCollection = [collectionSelection objectValueOfSelectedItem];
    
    NSLog(@"[RetrieveFromDBController updateCollection] selected database: %@", selectedDatabase);
    NSLog(@"[RetrieveFromDBController updateCollection] selected collection: %@", selectedCollection);
    
    NSInteger count = 0;
    
    if ( [selectedCollection length] != 0 && selectedCollection != NULL && selectedCollection != nil )
        count = [[NSApp delegate] countForDatabase:selectedDatabase
                                     andCollection:selectedCollection
                           withAddtionalProperties:[[[NSApp delegate] databaseConnection] additionalPropertiesAsString]];
    
    return count;
}
    
    
- (void)updateCollection {

    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSString * selectedCollection = [collectionSelection objectValueOfSelectedItem];

    NSLog(@"[RetrieveFromDBController updateCollection] selected database: %@", selectedDatabase);
    NSLog(@"[RetrieveFromDBController updateCollection] selected collection: %@", selectedCollection);
    
    if ( [selectedCollection length] != 0 && selectedCollection != NULL && selectedCollection != nil ) {
        
        /*
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter release];
*/
        
        
        NSLog(@"[RetrieveFromDBController updateCollection] skip: %@ and amount %@", [[[NSApp delegate] databaseConnection] skip], [[[NSApp delegate] databaseConnection] amount]);
        

        
        if ( _IDs != nil )
            [_IDs release];
        _IDs = [[NSApp delegate] idsForDatabase:selectedDatabase
                                   andCollection:selectedCollection
                         withAddtionalProperties:[[[NSApp delegate] databaseConnection] additionalPropertiesAsString]
                                restrictToAmount:[[[[NSApp delegate] databaseConnection] amount] intValue]
                                      startingAt:[[[[NSApp delegate] databaseConnection] skip] intValue]];
        [_IDs retain];
        
        NSString * numberReport = [NSString stringWithFormat:@"number of results in query: %lu",(unsigned long)[_IDs count]];
        
        [self setReportNumberOfResults:(NSString *)numberReport];
        [_reportTotalNumberOfResultsLabel setTextColor:[NSColor colorWithCalibratedWhite:0 alpha:1.0]];
        
        [_reportNumberOfResultsLabel setStringValue:_reportNumberOfResults];
        
        
        [idSelection deselectItemAtIndex:[idSelection indexOfSelectedItem]];
        [idSelection removeAllItems];
        [idSelection addItemsWithObjectValues:_IDs];
        if ( [idSelection numberOfItems] > 0 ) {
            [idSelection selectItemAtIndex:0];
            [idSelection setObjectValue:[idSelection objectValueOfSelectedItem]];
        }
    } else {
        [idSelection removeAllItems];
    }
    
}

@end
