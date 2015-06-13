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
 * PolymakeObjectPropertyTreeNode.m
 * PolyViewer
 **************************************************************************/


#import "PolymakeObjectPropertyTreeNode.h"
#import "PropertyNodeValue.h"






@implementation PolymakeObjectPropertyTreeNode

@synthesize polyObj      = _polyObj;
@synthesize propertyName = _propertyName;
@synthesize name         = _name;
@synthesize index        = _index;

@synthesize isObject, isLeaf, isMultiple;

@dynamic    children;
@dynamic    value;
@dynamic    propertyType;


- (void) dealloc {
    
    [_propertyName dealloc];
    [_propertType dealloc];
    [_polyObj dealloc];
    [_children dealloc];
    [_value dealloc];
    [_name dealloc];
    
    [super dealloc];
}


- (id)init {
    NSLog(@"[PolymakeObjectPropertyTreeNode init] called");
    
    self = [super init];
    if (self) {
        _polyObj = nil;

        _propertyName = @"undefined name";
        _propertType = nil;
        _name = nil;
        _index = 0;

        isObject   = nil;
        isMultiple = nil;
        isLeaf     = nil;
        
        _children  = nil;
        _value     = nil;
    }
    
    return self;
}

- (id)initWithName:(NSString *)propertyName
            andObj:(id)polyObj
          asObject:(BOOL) isObj
        asMultiple:(BOOL) isMult
            asLeaf:(BOOL) isL {
    NSLog(@"[PolymakeObjectPropertyTreeNode initWithName...] called for name: %@ and with polyObj %@", propertyName, polyObj);

    self = [super init];
    if (self) {
        _polyObj = polyObj;
        _propertyName = [[NSString stringWithString:propertyName] retain];
        _name = nil;
        _index = 0;
        isObject = isObj;
        isMultiple = isMult;
        isLeaf = isL;
        
        _children = nil;
        _value = nil;
        [self propertyType];
    }
    
    NSLog(@"[PolymakeObjectPropertyTreeNode initWithName...] returning with %@", self);
    return self;
}

- (id)initWithName:(NSString *)propertyName
            andObj:(id) polyObj
         withIndex:(int)index
          withName:(NSString *)name
          asObject:(BOOL) isObj
        asMultiple:(BOOL) isMult
            asLeaf:(BOOL) isL {
    NSLog(@"[PolymakeObjectPropertyTreeNode initWithName... (multiple)] called for name: %@ and with polyObj %@", propertyName, polyObj);
    
    self = [self initWithName:propertyName andObj:polyObj asObject:isObj asMultiple:isMult asLeaf:isL];
    if (self) {
        _name = [[NSString stringWithString:name] retain];
        _index = index;
    }
    
    NSLog(@"[PolymakeObjectPropertyTreeNode initWithName...(multiple)] returning with %@", self);
    return self;
}

    
- (id)initWithObject:(PolymakeObjectWrapper *)polyObj {
    NSLog(@"[PolymakeObjectPropertyTreeNode initWithObject] entering");

    self = [super init];
    if (self) {
        _polyObj      = [polyObj retain];
        _propertyName = [NSString stringWithString:[polyObj getObjectName]];
        _propertType  = [NSString stringWithString:[polyObj getObjectType:NO]];
        
        isObject      = TRUE;
        isMultiple    = FALSE;  //FIXME
        isLeaf        = FALSE;
        
        _children     = nil;
        _value        = nil;
    }
    
    NSLog(@"[PolymakeObjectPropertyTreeNode initWithObject] returning with %@",self);
    return self;
}

// get the children of a tag
// as with the value this is only done if really needed
// i.e. if the user opens the triangle in the display
- (NSArray *)children {
    NSLog(@"[PolymakeObjectPropertyTreeNode children] called");
    
    if ( _children == nil ) {
        NSLog(@"[PolymakeObjectPropertyTreeNode children] children not yet defined");

		NSMutableArray *newChildren = [NSMutableArray array];

		if ( isObject ) {            // okay, here we really have to do something
            NSLog(@"[PolymakeObjectPropertyTreeNode children] called for object");

            newChildren = [[_polyObj getPropertyListAtRootLevel] copy];
		}

        _children = [newChildren sortedArrayUsingComparator:^NSComparisonResult(id first, id second) {
                NSString *firstPropName  = [(PolymakeObjectPropertyTreeNode *)first  propertyName];
                NSString *secondPropName = [(PolymakeObjectPropertyTreeNode *)second propertyName];
                return [firstPropName compare:secondPropName];
        }];
        
    }
    
    NSLog(@"[PolymakeObjectPropertyTreeNode children] returning");
	return [_children retain];
}



// reset children to nil
// used if a new property is computed
// in this case we have to relead the children as we don't know wheter polymake computed further properties along the schedule
- (void)resetChildren {
    NSLog(@"[PolymakeObjectPropertyTreeNode resetChildren] called");    
    [_children release];
    _children = nil;
    
}


// compute the values of a property
// remember that this is not done during initialization
// but only if the user requests that property for display
- (PropertyNodeValue *)value {
    NSLog(@"[PolymakeObjectPropertyTreeNode value] entering");
    
	if ( _value == nil ) {
            NSString * prop = [_polyObj getProperty:_propertyName];
		if ( isLeaf ) {
//            _value = [[[PropertyNodeValue alloc] initWithValue:prop ofType:[_polyObj getPropertyType:_propertyName withTemplates:YES]] retain];
            _value = [[[PropertyNodeValue alloc] initWithValue:prop ofType:[_polyObj getObjectType:_propertyName]] retain];
        } else {
            _value = [[[PropertyNodeValue alloc] initWithValue:@"<no value>" ofType:[_polyObj getPropertyType:_propertyName withTemplates:YES]] retain];
        }
	}

	return _value;
}



// obtain the type of the property (the return of $P->type->name)
- (NSString *)propertyType {

    NSLog(@"[PolymakeObjectPropertyTreeNode propertyType] called");
    if ( _propertType == nil )  {
        
        if ( isObject ) {
            _propertType = [_polyObj getObjectType:NO];
        } else {
            _propertType = [_polyObj getPropertyType:_propertyName withTemplates:NO];
        }
    }
    
    return _propertType;
}


@end
