/***********************************************************************
 * Created by Andreas Paffenholz on 06/01/12.
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
 * PolymakeTag.h
 * PolyViewer
 **************************************************************************///

#import <Cocoa/Cocoa.h>


typedef enum _PolymakeTagType {       // enum to identify the different tag types
	PVMTag    = 1,
	PVVTag    = 2,
	PVTTag    = 4,
	PVETag    = 8,
	PVPropTag = 16
} PolymakeTagType;

@interface PolymakeTag : NSObject {
	
	NSMutableArray * _data;             // contains the data of the property, i.e. the stuff between <x>...</x>
	NSDictionary *   _attributes;       // contains the attributes of the tag as key-value pairs (FIXME currently only read for <e> tags)
	
	PolymakeTagType  _type;             // the type of the tag: <property>, <m>, <t>, <v>, <e>
	BOOL             _isEmpty;          // true if _data is empty
	BOOL             _hasSubTags;       // true if there are further subtags to parse
	BOOL             _hasAttributes;    // does the tag have attributes? FIXME as _attributes currently not realibly read
	NSMutableArray * _columnWidths;     // the widths of the columns for alignment. though always computed this is currently only useful for matrices
	
	
}

@property (readwrite,retain) NSMutableArray * data;
@property (readwrite,retain) NSDictionary * attributes;
@property (readonly)         PolymakeTagType type;
@property (readwrite,assign) BOOL isEmpty;
@property (readwrite,assign) BOOL hasSubTags;
@property (readwrite,assign) BOOL hasAttributes;
@property (readonly,retain)  NSMutableArray * columnWidths;

- (id) initWithType:(PolymakeTagType)aType;

- (void)addSubTag:(id)aSubTag;
- (id)objectAtIndex:(NSUInteger)index;
- (int)proplength;

@end
