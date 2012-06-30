/***********************************************************************
 * Created by Andreas Paffenholz on 04/18/12.
 * Copyright 2012 by Andreas Paffenholz. 
 
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
#import "PolymakeObject.h"
#import "ValueLineNumberView.h"
#import "PropertyView.h"

extern NSString * const PVValueFormattingDidChangeNotification;

@interface PolymakeFile : NSDocument <NSOutlineViewDataSource,NSTableViewDelegate> {
	
		// class variables
	NSString           * _lastOpenDialogStartDirectory;
	NSString * _currentPropertyText;
	PolymakeObject     * _polyObj;
	PropertyXMLNode    *_rootNode;
	BOOL                _alignedColumns;
	
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
	IBOutlet NSSlider            * _fontSizeSlider;
	IBOutlet NSTextView          * _descriptionView;
	IBOutlet NSButton            * _alignedColumnsBox;
	
}

@property (readwrite,copy) NSString * lastOpenDialogStartDirectory;
@property (readonly) PolymakeObject * polymakeObject;
@property (readwrite,assign) BOOL alignedColumns;

- (IBAction)closePoly:(id)sender;
- (IBAction)fixAlignedColumns:(id)sender;

- (void)redrawValueTextView;
- (NSString *)formatPropertyNodeValue:(NSArray *)tvalue withAlignedCols:(BOOL)align;
- (NSString *)formatTTag:(PolymakeTag *)tTag 
		 withColumnAlignment:(NSArray *)columnWidths 
						 subTagStart:(NSString *)subStart 
							 subTagEnd:(NSString *)subEnd 
			 andEntrySeparator:(NSString *)entrySep;
- (NSString *)formatTTag:(PolymakeTag *)tTag withAlignedCols:(BOOL)aligned;
- (NSString *)formatMTag:(PolymakeTag *)mTag withAlignedCols:(BOOL)align  subTagStart:(NSString *)stStart subTagEnd:(NSString *)stEnd andEntrySeparator:(NSString *)separator;
- (NSString *)formatVTag:(PolymakeTag *)vTag withColumnAlignment:(NSArray *)columnWidths;
- (NSString *)formatETag:(PolymakeTag *)eTag;

@end
