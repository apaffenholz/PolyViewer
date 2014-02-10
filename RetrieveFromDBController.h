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
 * RetrieveFromDBController.h
 * PolyViewer
 **************************************************************************/

#import <Foundation/Foundation.h>

@interface RetrieveFromDBController : NSWindowController <NSComboBoxDelegate> {

    IBOutlet NSButton    * openObjectButton;
    IBOutlet NSButton    * queryDBButton;
    IBOutlet NSButton    * retrieveIDsButton;
    IBOutlet NSTextField * _additionalPropertiesTextfield;

    // currently unused
    // values controlled by bindings
    // IBOutlet NSTextField * _skipTextfield;
    // IBOutlet NSTextField * _amountTextfield;

    
    IBOutlet NSTextField * _reportNumberOfResultsLabel;
    IBOutlet NSTextField * _reportTotalNumberOfResultsLabel;
    
    
    
    IBOutlet NSComboBox * databaseSelection;
    IBOutlet NSComboBox * collectionSelection;
    IBOutlet NSComboBox * idSelection;
    
    NSString             * _database;
    NSString             * _collection;
    NSString             * _ID;
    
    NSString             * _reportNumberOfResults;

    NSArray              * _databases;
    NSArray              * _collections;
    NSArray              * _IDs;
}

@property (readwrite,copy) NSArray * databases;
@property (readwrite,copy) NSArray * collections;
@property (readwrite,copy) NSString * database;
@property (readwrite,copy) NSString * collection;
@property (readwrite,copy) NSString * ID;
@property (readwrite,copy) NSString * reportNumberOfResults;

- (IBAction)retrieveFromDB:(id)sender;
- (IBAction)queryDB:(id)sender;
- (IBAction) getIdsForCurrentSelections:(id)sender;

- (NSInteger)queryDB;
- (void)updateCollection;

    
@end
