/***********************************************************************
 * Created by Andreas Paffenholz on 18/01/14.
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
 * PolymakeNodeValue.h
 * PolyViewer
 **************************************************************************/


#import <Foundation/Foundation.h>


// templateParameters holds an array of DataTypeStructs, one for each template parameter, or is nil
// the template params may themselves be templated, if not, their property templateParameters points to nil
// FIXME this is not really a clever way to store the type... retrieval of information is too complicated
struct DataTypeStruct {
    NSString * name;
    NSArray  * templateParameters;
};



/*
 
 The actual value of a property
 only properties at the leaves of the porperty tree contain information
 all others are just set to "no value"

 FIXME: column alignment does not work currently
 
 */


@interface PropertyNodeValue : NSObject {
    
    NSString              * _data;
    NSString              * _dataType;
    struct DataTypeStruct   _dataTypeStructure;
    BOOL                    _isEmpty;          // true if _data is empty
	NSMutableArray        * _columnWidths;     // the widths of the columns for alignment. though always computed this is currently only useful for matrices
}


- (id) initWithValue:(NSString *)value
              ofType:(NSString *)type;


- (NSString *) dataWithAlignedColumns:(BOOL)alignedCols;

@property (readwrite,retain) NSString       * data;
@property (readwrite,retain) NSString       * dataType;
@property (readwrite,assign) BOOL             isEmpty;
@property (readonly,retain)  NSMutableArray * columnWidths;

@end
