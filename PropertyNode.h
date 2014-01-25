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

    PolymakeObjectWrapper * _polyObj;
    NSString              * _name;
    NSArray               * _children;
    PropertyNodeValue           * _value;

    BOOL                  hasValue;
    BOOL                  isObject;
    BOOL                  isLeaf;
    BOOL                  isMultiple;
}


- (NSArray *)children;

- (id)initWithName:(NSString *)name andObj:(id) polyObj asObject:(BOOL) isObj asMultiple:(BOOL) isMult asLeaf:(BOOL) isLeaf;
- (id)initWithObject:(PolymakeObjectWrapper *)polyObj;


@property (readonly)      PolymakeObjectWrapper * polyObj;
@property (readonly,copy) PropertyNodeValue * value;
@property (readonly,copy) NSString * name;
@property (readonly)      NSArray * children;
@property (readonly)      BOOL hasValue;        
@property (readonly)      BOOL isObject;
@property (readonly)      BOOL isLeaf;
@property (readonly)      BOOL isMultiple;

@end
