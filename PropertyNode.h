/***********************************************************************
 * Created by Andreas Paffenholz on 01/08/14.
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
 * PropertyNode.h
 * PolyViewer
 **************************************************************************/

#import <Foundation/Foundation.h>
#import "PropertyNodeValue.h"
#import "PolymakeObjectWrapper.h"

@interface PropertyNode : NSObject {

    NSString              * _propertyName;  // the property name
    NSString              * _propertType;   // the type of the property

    // relevant variables if the property defines a perl::Object (with declare object in some rule file)
    PolymakeObjectWrapper * _polyObj;       // a pointer to the perl::Object associated with the property
    NSArray               * _children;      // the properties defined for the perl::Object

    // relevant variables if the property is multiple
    int                     _index;         // for multiple properties: index in the list
    NSString              * _name;          // for multiple properties: the name (may be nil if the corresponding object has no name associated to it)

    // relevant variable for properties containing a value (PTL types or perl types)
    PropertyNodeValue     * _value;         // the value of a property


    BOOL                  isObject;         // the property corresponds to a perl::Object
    BOOL                  isMultiple;       // the property is multiple

    // FIXME 
    BOOL                  hasValue;         // FIXME do we need this?
    BOOL                  isLeaf;           // FIXME the property has a value and is not a perl::Object. Do we still need this?
}


- (NSArray *)children;

- (id)initWithName:(NSString *)propertyName andObj:(id) polyObj asObject:(BOOL) isObj asMultiple:(BOOL) isMult asLeaf:(BOOL) isLeaf;
- (id)initWithName:(NSString *)propertyName andObj:(id) polyObj withIndex:(int) index withName:(NSString *)name asObject:(BOOL) isObj asMultiple:(BOOL) isMult asLeaf:(BOOL) isLeaf;
- (id)initWithObject:(PolymakeObjectWrapper *)polyObj;
- (void)resetChildren;


@property (readonly)      PolymakeObjectWrapper * polyObj;
@property (readonly,copy) PropertyNodeValue * value;
@property (readonly,copy) NSString * propertyName;
@property (readonly,copy) NSString * propertyType;
@property (readonly,copy) NSString * name;
@property (readonly)      int index;
@property (readonly)      NSArray * children;
@property (readonly)      BOOL hasValue;        
@property (readonly)      BOOL isObject;
@property (readonly)      BOOL isLeaf;
@property (readonly)      BOOL isMultiple;

@end
