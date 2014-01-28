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
 * PropertyNode.m
 * PolyViewer
 **************************************************************************/


#import "PropertyNode.h"
#import "PropertyNodeValue.h"

@implementation PropertyNode

@synthesize polyObj = _polyObj;
@synthesize propertyName    = _propertyName;
@synthesize name    = _name;
@synthesize index    = _index;
@synthesize hasValue, isObject, isLeaf, isMultiple;
@dynamic    children;
@dynamic    value;


- (id)init {
    NSLog(@"[PropertyNode init] called");
    self = [super init];
    if (self) {
        _polyObj = nil;
        _propertyName = @"undefined name";
        _name = nil;
        _index = 0;
        isObject = nil;
        isMultiple = nil;
        isLeaf = nil;
        
        _children = nil;
        _value = nil;
    }
    
    return self;
}

- (id)initWithName:(NSString *)propertyName andObj:(id) polyObj asObject:(BOOL) isObj asMultiple:(BOOL) isMult asLeaf:(BOOL) isL {
    NSLog(@"[PropertyNode initWithName...] called for name: %@ and with polyObj %@", propertyName, polyObj);

    self = [super init];
    if (self) {
        _polyObj = polyObj;
        _propertyName = propertyName;
        [_propertyName retain];
        _name = nil;
        _index = 0;
        isObject = isObj;
        isMultiple = isMult;
        isLeaf = isL;
        
        _children = nil;
        _value = nil;
    }
    
    NSLog(@"[PropertyNode initWithName...] returning with %@", self);
    return self;
}

- (id)initWithName:(NSString *)propertyName andObj:(id) polyObj withIndex:(int)index withName:(NSString *)name asObject:(BOOL) isObj asMultiple:(BOOL) isMult asLeaf:(BOOL) isL {
    NSLog(@"[PropertyNode initWithName... (multiple)] called for name: %@ and with polyObj %@", propertyName, polyObj);
    
    self = [super init];
    if (self) {
        _polyObj = polyObj;
        _propertyName = propertyName;
        [_propertyName retain];
        _name = name;
        [_name retain];
        _index = index;
        isObject = isObj;
        isMultiple = isMult;
        isLeaf = isL;
        
        _children = nil;
        _value = nil;
    }
    
    NSLog(@"[PropertyNode initWithName...(multiple)] returning with %@", self);
    return self;
}

    
- (id)initWithObject:(PolymakeObjectWrapper *)polyObj {
    NSLog(@"[PropertyNode initWithObject] entering");

    self = [super init];
    if (self) {
        _polyObj = [polyObj retain];
        _propertyName = [polyObj getObjectName];
        [_propertyName retain];
        isObject = TRUE;
        isMultiple = FALSE;  //FIXME
        isLeaf = FALSE;
        
        _children = nil;
        _value = nil;
    }
    
    NSLog(@"[PropertyNode initWithObject] returning with %@",self);
    return self;
}

// get the children of a tag
// as with the value this is only done if really needed
// i.e. if the user opens the triangle in the display
- (NSArray *)children {
    NSLog(@"[PropertyNode children] called");
    
    if ( _children == nil ) {
        NSLog(@"[PropertyNode children] children not yet defined");

		NSMutableArray *newChildren = [NSMutableArray array];

		if ( isObject ) {            // okay, here we really have to do something
            NSLog(@"[PropertyNode children] called for object");

            newChildren = [[_polyObj getPropertyListAtRootLevel] copy];
		}
        
		_children = [newChildren retain];
	}

    NSLog(@"[PropertyNode children] returning");
	return _children;
}


// compute the values of a property
// remember that this is not done during initialization
// but only if the user requests that property for display
- (PropertyNodeValue *)value {
    NSLog(@"[PropertyNode value] entering");
    
	if ( _value == nil ) {
        NSLog(@"[PropertyNode value] value not yet set");
        
		_value = [[PropertyNodeValue alloc] init];
		if ( isLeaf ) {
            NSLog(@"[PropertyNode value] at a leaf");
            
            [_value setData:[_polyObj getProperty:_propertyName]];
            if ( [[_value data] length] == 0 )
                [_value setIsEmpty:YES];
                
            NSLog(@"[PropertyNode value] value set: %@", _value);
            [_value retain];
		}	else {
            NSLog(@"[PropertyNode value] not at a leaf");
            
			[_value setData:[[NSString alloc] initWithString:@"<no value>"]];
		}
	}
    
    NSLog(@"[PropertyNode value] leaving");
	return _value;
}


@end
