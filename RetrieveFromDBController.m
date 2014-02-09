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

        //[self addObserver:_reportNumberOfResults forKeyPath:@"reportNumberOfresults" options:NSKeyValueChangeSetting context:nil];
        //[_noOfRes addObserver:self forKeyPath:@"reportNumberOfResults" options:NSKeyValueChangeNewKey context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self forKeyPath:@"skip" options:NSKeyValueObservingOptionNew context:nil];
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
    _database = @"Tropical";
    _collection = @"SmoothReflexive";
    _ID = @"F.4D.0123";
    [self setReportNumberOfResults:@"no results"];
    [_reportNumberOfResultsLabel setStringValue:_reportNumberOfResults];
    
    _databases = [[[NSApp delegate] databaseNames] retain];
    [databaseSelection addItemsWithObjectValues:_databases];
    [databaseSelection selectItemWithObjectValue:_database];
    
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
    PolymakeFile * pf = [[PolymakeFile alloc] init];
    [pf readFromDatabase:_database andCollection:_collection withID:_ID];
    
    [pf makeWindowControllers];
    [pf showWindows];
    [[NSDocumentController sharedDocumentController] addDocument:pf];
    [pf release];
    [[self window] orderOut:nil];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {

    NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] entered");
    
    id myObject = [notification object];
    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] selected database: %@", selectedDatabase);
    if ( myObject == databaseSelection ) {    // the selected database has changed, so we retrieve the list of collections
        
        
        if ( _collections != nil )
            [_collections release];
        _collections = [[[NSApp delegate] collectionNamesOfDatabase:selectedDatabase] retain];
        NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] got collections: %@", _collections);
        NSLog(@"[RetrieveFromDBController comboBoxSelectionDidChange] of size: %lu", (unsigned long)[_collections count]);
        [collectionSelection removeAllItems];
        [collectionSelection addItemsWithObjectValues:_collections];
        [collectionSelection selectItemAtIndex:0];
        [collectionSelection setObjectValue:[collectionSelection objectValueOfSelectedItem]];
    } else {
        if ( myObject == collectionSelection ) {
            // the selected collection has changed, so we retrieve ids
            // current decision: we only get the first 1000
            // FIXME enhancement: add text field to narrow search by fixing properties,
            // and provide fields for max number of retrieved and number of results to skip from start of result list

            [self updateCollection];

        }
    }
}
    
- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"[RetrieveDromDBController controlTextDidChange] %@", [textField stringValue]);
    [self updateCollection];
    
}

- (void)updateCollection {

    NSString * selectedDatabase = [databaseSelection objectValueOfSelectedItem];
    NSString * selectedCollection = [collectionSelection objectValueOfSelectedItem];

    NSLog(@"[RetrieveFromDBController updateCollection] selected database: %@", selectedDatabase);
    NSLog(@"[RetrieveFromDBController updateCollection] selected collection: %@", selectedCollection);
    
    if ( [selectedCollection length] != 0 && selectedCollection != NULL && selectedCollection != nil ) {
        
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter release];

        
        
        NSLog(@"[RetrieveFromDBController updateCollection] skip: %@ and amount %@", [[[NSApp delegate] databaseConnection] skip], [[[NSApp delegate] databaseConnection] amount]);
        

        
        NSInteger count = [[NSApp delegate] countForDatabase:selectedDatabase
                                                andCollection:selectedCollection
                                      withAddtionalProperties:[[[NSApp delegate] databaseConnection] additionalPropertiesAsString]];
        
        _IDs = [[NSApp delegate] idsForDatabase:selectedDatabase
                                   andCollection:selectedCollection
                         withAddtionalProperties:[[[NSApp delegate] databaseConnection] additionalPropertiesAsString]
                                restrictToAmount:[[[[NSApp delegate] databaseConnection] amount] intValue]
                                      startingAt:[[[[NSApp delegate] databaseConnection] skip] intValue]];
        
        NSString * numberReportTotal = [NSString stringWithFormat:@"database elements satisfying given properties: %ld", count];
        NSString * numberReport = [NSString stringWithFormat:@"number of results in query: %lu",(unsigned long)[_IDs count]];
        
        [self setReportNumberOfResults:(NSString *)numberReport];
        [_reportTotalNumberOfResultsLabel setStringValue:numberReportTotal];
        [_reportTotalNumberOfResultsLabel setTextColor:[NSColor colorWithCalibratedWhite:0 alpha:1.0]];
        if ( count > [[[[NSApp delegate] databaseConnection] amount] intValue] )
            [_reportTotalNumberOfResultsLabel setTextColor:[NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1]];

        
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
