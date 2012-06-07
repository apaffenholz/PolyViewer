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
 * PolymakeTag.m
 * PolyViewer
 **************************************************************************///

#import "PolymakeTag.h"

@implementation PolymakeTag

@synthesize data          = _data;                    
@synthesize attributes    = _attributes;        

@synthesize type          = _type;                    
@synthesize isEmpty       = _isEmpty;              
@synthesize hasSubTags    = _hasSubTags;        
@synthesize hasAttributes = _hasAttributes;  

@dynamic columnWidths;                       

	// init a PolymakeTag of a given type
- (id)initWithType:(PolymakeTagType)aType {

	self = [super init];
	if ( self ) {
		_data = [[NSMutableArray alloc] init];
		_type = aType;	
		_columnWidths = nil;
		_attributes = nil;
		_hasSubTags = NO;
	}
	return self;
}

/************/
- (void)dealloc {
	[_data release];
	[super dealloc];
}

	// add a subtag to the property
- (void)addSubTag:(id)aSubTag {
	[_data addObject:aSubTag];
}

	// return the contents of the data array at a given index
- (id)objectAtIndex:(NSUInteger)index {
	return [_data objectAtIndex:index];	
}

	// return the total width of the property for display
	// used to compute the column widths of the supertag
- (int)proplength {
	int i = 0;
	for ( id entry in _data ) {
		if ( [entry class] == [NSString class] ) 
			i += [entry length];
		else 
			i += [entry proplength];
	}
	
	return i;
}

	// return the column widths 
	// currently only useful for matrices
- (NSMutableArray *)columnWidths {
	
	if ( _columnWidths == nil ) {
		if ( _hasSubTags == NO ) {
			_columnWidths = [[NSMutableArray alloc] init];
			for ( id entry in _data ) {
				if ( [entry isKindOfClass:[NSString class]] ) 
					[_columnWidths addObject:[NSNumber numberWithInt:[entry length]]];			
				else {
				[_columnWidths addObject:[NSNumber numberWithInt:[entry proplength]]];
				}
			}
		} else {
			for ( id entry in _data ) {			
				if ( _columnWidths == nil ) {            // for m tags we try to support aligned columns
					_columnWidths = [[NSMutableArray alloc] initWithArray:[entry columnWidths]];
				} else {
					unsigned mSize = [_columnWidths count];
					unsigned vSize = [[entry columnWidths] count];
					unsigned i = 0;
					while ( i < mSize && i < vSize ) {
						if ( [[_columnWidths objectAtIndex:i] intValue] < [[[entry columnWidths] objectAtIndex:i] intValue] )
							[_columnWidths replaceObjectAtIndex:i withObject:[[entry columnWidths] objectAtIndex:i]];
						++i;
					}
					if ( i < vSize ) 
						for ( ; i < vSize; ++i )
							[_columnWidths addObject:[[entry columnWidths] objectAtIndex:i]];
				}	
			}		
		}
	}
	
	return _columnWidths;
	}

  // output for NSLog
- (NSString *)description {
	return [NSString stringWithFormat:@"%@",[self data]];
}

@end
