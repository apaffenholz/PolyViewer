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

    IBOutlet NSButton    * retrieveObject;
    IBOutlet NSTextField * databaseTextfield;
    IBOutlet NSTextField * collectionTextfield;
    IBOutlet NSTextField * IDTextfield;
    
    
    IBOutlet NSComboBox * databaseSelection;
    IBOutlet NSComboBox * collectionSelection;
    
    NSString             * _database;
    NSString             * _collection;
    NSString             * _ID;

    NSArray              * _databases;
    NSArray              * _collections;
}

@property (readwrite,copy) NSArray * databases;
@property (readwrite,copy) NSArray * collections;
@property (readwrite,copy) NSString * database;
@property (readwrite,copy) NSString * collection;
@property (readwrite,copy) NSString * ID;

- (IBAction)retrieveFromDB:(id)sender;
- (IBAction)updateCollection:(id)sender;

@end