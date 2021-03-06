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
 * PolymakeFile.h
 * PolyViewer
 **************************************************************************/

#import <Cocoa/Cocoa.h>
#import "MainPolymakeObject.h"
#import "ValueLineNumberView.h"
#import "PropertyView.h"
#import "PolymakeObjectWrapper.h"
#import "PolymakeObjectPropertyTreeNode.h"
#import "MainPolymakeObject.h"

extern NSString * const PVValueFormattingDidChangeNotification;
extern NSString * const ChildrenOfRootHaveChangedNotification;

@interface PolymakeObjectController : NSDocument <NSOutlineViewDataSource,NSTableViewDelegate> {
	
		// class variables
	NSString * _lastOpenDialogStartDirectory;
	NSString * _currentPropertyValue;

    IBOutlet MainPolymakeObject  * _polyObj;
	BOOL              _alignedColumns;
    	
		// main window
	IBOutlet NSScrollView        * _valueScrollView;
	IBOutlet PropertyView        * _propertyView;
	IBOutlet NSTextView          * _valueTextView;
	IBOutlet NSButton            * closeButton;	
	IBOutlet ValueLineNumberView * _valueLineNumberView;
	IBOutlet NSTableView         * _creditTable;
	IBOutlet NSTextView          * _creditView;
	IBOutlet NSTextField         * _type;
	IBOutlet NSTextField         * _name;
	IBOutlet NSTextField         * _currentPropertyName;
	IBOutlet NSSlider            * _fontSizeSlider;
	IBOutlet NSTextView          * _descriptionView;
	IBOutlet NSTextField          * _propertyTypeField;
	IBOutlet NSButton            * _alignedColumnsBox;
  IBOutlet NSTabView           * _metaInfoTabView;
  IBOutlet NSTableView         * _databaseTableView;
	
}



@property (readwrite,copy) NSString * lastOpenDialogStartDirectory;
@property (readwrite,retain) MainPolymakeObject * polymakeObject;
@property (readwrite,assign) BOOL alignedColumns;


- (IBAction)closePoly:(id)sender;
- (IBAction)fixAlignedColumns:(id)sender;

- (void)redrawValueTextView;

- (BOOL)readFromDatabase:(NSString *)database
           andCollection:(NSString *)collection
                  withID:(NSString *)ID;

@end
