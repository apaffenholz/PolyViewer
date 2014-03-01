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
 * PolymakeObjectPropertyTreeNode.h
 * PolyViewer
 **************************************************************************/

#import <Foundation/Foundation.h>
#import "PropertyNodeValue.h"
#import "PolymakeObjectWrapper.h"

/*
 A node in the property tree of a polymake object
 The data at this node is kept in _value, the children (if any) in _children
 Both _value and _children are set to nil by the initializers and only computed if actually needed in the view
 
 The class is used both for inner nodes and for leaves. However, different variables are used in each case:
 - for inner nodes, _polyObj points to the big polymake object (inside a PolymakeObjectWrapper) and _children points to the children. _values is set to "<no property>" to put something in the property view, so people don't think the comutation has failed.
 - for leaves, _polyObj points to the polymake big Object (inside a PolymakeObjectWrapper) this property is defined in (so, its parent in the tree) and _value contains the value
 
 For multiple properties we define the variables _index and _name.
 Note the difference between _propertyName and _name: The former is the name of property as defined by "propery XY" (e.g. "LP"), the name is a named assigned by the user (e.g. "my linear program")
 
 for convenience, some meta properties of the node are stored alongside:
 name and type of the property, wheter it is a polymake big object, multiple, or a leaf in the tree

*/
@interface PolymakeObjectPropertyTreeNode : NSObject {

    NSString              * _propertyName;  // the property name
    NSString              * _propertType;   // the type of the property

    // indicators
    BOOL                  isObject;         // the property corresponds to a perl::Object
    BOOL                  isMultiple;       // the property is multiple
    BOOL                  isLeaf;           // indicates that the property is a leaf of the property tree
                                            // FIXME should be equivalent to !isObject

    // relevant variables if the property defines a perl::Object (with declare object in some rule file)
    PolymakeObjectWrapper * _polyObj;       // a pointer to the perl::Object associated with the property
    NSArray               * _children;      // the properties defined for the perl::Object

    // relevant variables if the property is multiple
    int                     _index;         // for multiple properties: index in the list
    NSString              * _name;          // for multiple properties: the name (may be nil if the corresponding object has no name associated to it)

    // relevant variable for properties containing a value (PTL types or perl types)
    PropertyNodeValue     * _value;         // the value of a property


}

// initializers
- (id)initWithName:(NSString *)propertyName
            andObj:(id)polyObj
          asObject:(BOOL)isObj
        asMultiple:(BOOL)isMult
            asLeaf:(BOOL)isLeaf;

- (id)initWithName:(NSString *)propertyName
            andObj:(id) polyObj
         withIndex:(int)index
          withName:(NSString *)name
          asObject:(BOOL)isObj
        asMultiple:(BOOL)isMult
            asLeaf:(BOOL)isLeaf;

- (id)initWithObject:(PolymakeObjectWrapper *)polyObj;


// dealing with the children of a node
- (NSArray *)children;
- (void)resetChildren;


@property (readonly)      PolymakeObjectWrapper * polyObj;
@property (readonly,copy) PropertyNodeValue     * value;
@property (readonly,copy) NSString              * propertyName;
@property (readonly,copy) NSString              * propertyType;
@property (readonly,copy) NSString              * name;
@property (readonly)      int                     index;
@property (readonly)      NSArray               * children;
@property (readonly)      BOOL                    isObject;
@property (readonly)      BOOL                    isLeaf;
@property (readonly)      BOOL                    isMultiple;

@end
