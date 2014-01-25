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
 * PolymakeObject.m
 * PolyViewer
 **************************************************************************/


#import "PolymakeObject.h"

@implementation PolymakeObject

@synthesize objectType   = _objectType;
@synthesize filename     = _filename;
@synthesize name         = _name;
@synthesize description  = _description;
@synthesize credits      = _creditsDict;
@synthesize rootPerl     = _rootPerlNode;


/***************************************************************************
 * init
 ***************************************************************************/

- (id)init {

	if ( self = [super init] ) {

		_filename     = nil;
		_name         = nil;
		_description  = nil;
		_creditsDict  = nil;
        _rootPerlNode = nil;
    
	} 
	
	return self;
}	


/***************************************************************************
 * init with a file
 ***************************************************************************/

- (id)initObjectWithURL:(NSURL *)input {
    
    if ( self = [super init] ) {
        
        // libpolymake initialize polymake object
        _rootPerlNode = [[[PropertyNode alloc] initWithObject:[[PolymakeObjectWrapper alloc ] initWithPolymakeObject:[input path]]] retain];
        
        // determine the object type of the given object
        // this is stored as an attribute of the root node
        _objectType = [NSString stringWithString:[[_rootPerlNode polyObj] getObjectType]];
        
        // check whether the polymake object has a name
        // as the type this would be an attribute of the root
        _name = [NSString stringWithString:[[_rootPerlNode polyObj] getObjectName]];
        
        // check whether the polytope has a description
        // this is stored in a property directly below the root
        _description = [NSString stringWithString:[[_rootPerlNode polyObj] getObjectDescription]];
        
        NSMutableArray * creditLabels = [NSMutableArray array];
        NSMutableArray * creditStrings = [NSMutableArray array];

        _creditsDict = [NSDictionary dictionaryWithObjects:creditStrings forKeys:creditLabels];
        
		// apparently we have to retain this
        [_creditsDict retain];
        
		// keep the input filename
        _filename = [input retain];
    }
    
    return self;
}


	/***************************************************************************
	 * dealloc
	 ***************************************************************************/
- (void) dealloc {
	[_rootPerlNode release];
	[_filename release];
	[_creditsDict release];
	[super dealloc];
}

@end
