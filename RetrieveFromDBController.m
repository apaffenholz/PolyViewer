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

@synthesize databases = _databases;
@synthesize collections = _collections;

        /***************************************************************/
// initialization, deallocation, window loading
-(id)init {
	self = [super init];
	if (self) {
        _databases = nil;
        _collections = nil;
        _IDs = nil;
    }
    
	return self;
}


    
    /***************************************************************/
-(void)dealloc {
    [_databases dealloc];
    [_collections dealloc];
    [_IDs dealloc];
    
	[super dealloc];
}


    
    /***************************************************************/
- (void)windowDidLoad {
	NSLog(@"[RetrieveFromDBController windowDidLoad] called");
    
    [_reportNumberOfResultsLabel setStringValue:@"no results"];
    
    _databases = [[[NSApp delegate] databaseNames] retain];
    
	NSLog(@"[RetrieveFromDBController windowDidLoad] adding databases");
    if ( [_databases count] > 0 ) {
        [databaseSelection addItemsWithObjectValues:_databases];
        [databaseSelection selectItemAtIndex:0];
        [databaseSelection setObjectValue:[databaseSelection objectValueOfSelectedItem]];
    }
    
    NSLog(@"[RetrieveFromDBController windowDidLoad] database names are %@",_databases);
}
    

    
    /***************************************************************/
// window actions
- (IBAction)retrieveFromDB:(id)sender {
    NSLog(@"[RetrieveFromDBController retrieveFromDB] called");

    NSLog(@"[RetrieveFromDBController retrieveFromDB] index of selected item: %ld",(long)[databaseSelection indexOfSelectedItem]);
    
    NSString * _database = (NSString *)[_databases objectAtIndex:[databaseSelection indexOfSelectedItem]];
    NSString * _collection = (NSString *)[_collections objectAtIndex:[collectionSelection indexOfSelectedItem]];
    NSString * _ID = (NSString *)[_IDs objectAtIndex:[_idTableView selectedRow]];
  
    NSLog(@"[RetrieveFromDBController retrieveFromDB] selected item: %@",_database);
    PolymakeObjectController * pf = [[PolymakeObjectController alloc] init];
    if ( [pf readFromDatabase:_database andCollection:_collection withID:_ID] ) {
        [pf makeWindowControllers];
        [pf showWindows];
        [[NSDocumentController sharedDocumentController] addDocument:pf];
    }
    
    [pf release];
}
 
    /***************************************************************/
// action if the query button is pressed
- (IBAction)queryDB:(id)sender {
    NSLog(@"[RetrieveFromDBController queryDB:sender] entered");
    
    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSString * selectedCollection = [collectionSelection objectValueOfSelectedItem];
    
    NSInteger count = 0;
    
    if ( [selectedCollection length] != 0 ) {
        count = [[[NSApp delegate] databaseConnection] queryDBwithDatabase:selectedDatabase
                                                             andCollection:selectedCollection];
        NSString * numberReportTotal = [NSString stringWithFormat:@"elements in database: %ld", count];
        [_reportTotalNumberOfResultsLabel setStringValue:numberReportTotal];
        if ( count > [[[[NSApp delegate] databaseConnection] amount] intValue] )
            [_reportTotalNumberOfResultsLabel setTextColor:[NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1]];

    }
    
    _IDs = nil;
}
    
    /***************************************************************/
- (IBAction) getIdsForCurrentSelections:(id)sender {
    [self updateCollection];
    NSLog(@"[RetrieveFromDBController GetIdsForCurrentSelections] starting table reload");
    [_idTableView reloadData];
}

    
    /***************************************************************/
// combo boxes:
// - databases :                 _databases
// - collections in databases:   _collections
// - IDs of objects in database: _IDs
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {

    NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] entered");
    
    id myObject = [notification object];
    if ( myObject == databaseSelection ) {    // the selected database has changed, so we retrieve the list of collections
        [self updateCollectionList];
    } else {
        // currently do nothing if other sections change
    }
}
    
        /***************************************************************/
// editing of text fields
// currently does nothing
// amount and skip attached via bindings
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"[RetrieveDromDBController controlTextDidChange] %@", [textField stringValue]);
}


// other methods
    
    /***************************************************************/
- (void) updateCollectionList {
    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSLog(@"[RetrieveFromDBController updateCollectionList] selected database: %@", selectedDatabase);

    if ( _collections != nil )
        [_collections release];
    
    if ( _databases != nil ) {
        _collections = [[[NSApp delegate] collectionNamesOfDatabase:selectedDatabase] retain];

        NSLog(@"[RetrieveFromDBController updateCollectionList] got collections: %@", _collections);
        NSLog(@"[RetrieveFromDBController updateCollectionList] of size: %lu", (unsigned long)[_collections count]);

        [collectionSelection removeAllItems];
        [collectionSelection addItemsWithObjectValues:_collections];

        if ( [_collections count] > 0 ) {
            [collectionSelection selectItemAtIndex:0];
            [collectionSelection setObjectValue:[collectionSelection objectValueOfSelectedItem]];
            if ( [_IDs count] > 0 ) {
                _IDs = nil;
                [_idTableView reloadData];
            }
        }
    }
}
    
    
    /***************************************************************/
- (void)updateCollection {
        
    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSString * selectedCollection = [collectionSelection objectValueOfSelectedItem];
        
    NSLog(@"[RetrieveFromDBController updateCollection] selected database: %@", selectedDatabase);
    NSLog(@"[RetrieveFromDBController updateCollection] selected collection: %@", selectedCollection);
        
        if ( [selectedCollection length] != 0 ) {
            
            /*
             NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
             [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
             [formatter release];
             */
            
            if ( _IDs != nil )
                [_IDs release];
            _IDs = [[NSApp delegate] idsForDatabase:selectedDatabase
                                      andCollection:selectedCollection
                            withAddtionalProperties:[[[NSApp delegate] databaseConnection] additionalPropertiesAsString]
                                   restrictToAmount:[[[[NSApp delegate] databaseConnection] amount] intValue]
                                         startingAt:[[[[NSApp delegate] databaseConnection] skip] intValue]];
            [_IDs retain];
            
            // report how many IDs actually match the query
            NSString * numberReport = [NSString stringWithFormat:@"query size: %lu",(unsigned long)[_IDs count]];
            [_reportTotalNumberOfResultsLabel setTextColor:[NSColor colorWithCalibratedWhite:0 alpha:1.0]];
            [_reportNumberOfResultsLabel setStringValue:numberReport];
        }
    }
    


    /***************************************************************/
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tv {
    NSLog(@"[RetrieveFromDBController numberOfRowsInTableView] called");
	
	return [_IDs count];
}
    
    /***************************************************************/
- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger) row {
    NSLog(@"[RetrieveFromDBController tableView ObjectValueTableColumn column row] called for row %ld", (long)row);
    
	NSString * value = _IDs[row];
	return value;
}

/****************/
- (void) tableViewSelectionDidChange: (NSNotification *) notification {
    NSLog(@"[RetrieveFromDBController tableViewSelectionDidChange] called");
	int row = [_idTableView selectedRow];
	
	if ( row != -1 ) {
	}
}

@end
