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
        _additionalProperties = nil;
        amount = nil;
        skip = nil;

        //[self addObserver:_reportNumberOfResults forKeyPath:@"reportNumberOfresults" options:NSKeyValueChangeSetting context:nil];
        //[_noOfRes addObserver:self forKeyPath:@"reportNumberOfResults" options:NSKeyValueChangeNewKey context:nil];
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
    [self setReportNumberOfResults:@"no results"];
    [_reportNumberOfResultsLabel setStringValue:_reportNumberOfResults];
    
    _additionalProperties = @"";
    amount = [NSNumber numberWithInt:1000];
    skip = [NSNumber numberWithInt:0];
    [_amountTextfield setStringValue:[amount stringValue]];
    [_skipTextfield setStringValue:[skip stringValue]];
    [_additionalPropertiesTextfield setStringValue:_additionalProperties];
    
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
    if ( myObject == databaseSelection ) {    // the selected databas has changed, so we retrieve the list of collections
        
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
        
        if ( _IDs != nil )
        [_IDs release];
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        amount = [formatter numberFromString:[_amountTextfield stringValue]];
        skip = [formatter numberFromString:[_skipTextfield stringValue]];
        _additionalProperties = [_additionalPropertiesTextfield stringValue];
        
        NSLog(@"[RetrieveFromDBController updateCollection] additional properties: %@", _additionalProperties);
        
        [formatter release];
        _IDs = [[[NSApp delegate] idsForDatabase:selectedDatabase
                                   andCollection:selectedCollection
                         withAddtionalProperties:_additionalProperties
                                restrictToAmount:[amount intValue]
                                      startingAt:[skip intValue]] retain];
        
        [self setReportNumberOfResults:[NSString stringWithFormat:@"number of results in query: %lu",(unsigned long)[_IDs count]]];
        [_reportNumberOfResultsLabel setStringValue:_reportNumberOfResults];
        
        [idSelection removeAllItems];
        [idSelection addItemsWithObjectValues:_IDs];
        [idSelection selectItemAtIndex:0];
        [idSelection setObjectValue:[idSelection objectValueOfSelectedItem]];
    } else {
        [idSelection removeAllItems];
    }
    
}

@end
