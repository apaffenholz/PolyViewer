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
 * PolymakeObject.h
 * PolyViewer
 **************************************************************************/
 
#import <Cocoa/Cocoa.h>
#import "PolymakeInstanceWrapper.h"
#import "PolymakeObjectWrapper.h"
#import "PropertyNode.h"


@interface PolymakeObject : NSObject {
	NSURL           * _filename;   	  // currently this is not so useful
                                      // but we might want to extend to a viewer that keeps multiple files
	NSString        * _name;          // name of the object
	NSString        * _objectType;    // the polymake big object type
	NSString        * _description;   // description 
	NSDictionary    * _creditsDict;   // dictionary of credits for external software
    PropertyNode    * _rootPerlNode;
}

@property (readonly, retain) NSString * objectType;
@property (readonly, retain) NSURL* filename;
@property (readonly, copy)   NSString * name;
@property (readonly, copy)   NSString * description;
@property (readonly, retain) NSDictionary* credits;
@property (readonly, retain) PropertyNode* rootPerl;

- (id)init;
- (id)initObjectWithURL:(NSURL *)input;

- (id)retrieveFromDatabase:(NSString *)database andCollection:(NSString *)collection withID:(NSString *)ID;

@end
