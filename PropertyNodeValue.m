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
 * PolymakeNodeValue.m
 * PolyViewer
 **************************************************************************/


#import "PropertyNodeValue.h"

@implementation PropertyNodeValue


@synthesize data          = _data;
@synthesize dataType      = _dataType;
@synthesize isEmpty       = _isEmpty;


- (void) dealloc {
    [_data dealloc];
    [_dataType dealloc];
    [super dealloc];
}


- (id) init {
    self = [super init];
    if ( self ) {
        _data     = nil;
        _dataType = nil;
        _isEmpty  = YES;
    }
    
    return self;
}

- (id) initWithValue:(NSString *)value
              ofType:(NSString *)type {
    
    self = [super init];
    if ( self ) {
        
        _data = [value retain];
        _dataType = [type retain];
        if ( [_data length] == 0 )
            _isEmpty = YES;
        else
            _isEmpty = NO;
        
    }
    
    return self;
}

@end
