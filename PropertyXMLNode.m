//
/***********************************************************************
 * Created by Andreas Paffenholz on 04/18/12.
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
 * PropertyXMLNode.m
 * PolyViewer
 **************************************************************************/


#import "PropertyXMLNode.h"
#import "PolymakeTag.h"

@implementation PropertyXMLNode

@synthesize XMLNode = _xmlNode;
@synthesize name    = _name;
@synthesize hasValue, isObject, isLeaf;
@dynamic    children;
@dynamic    value;

	// init the root node of the file, containing name, description etc.
- (id)initRootWithXMLNode:(NSXMLNode *)xmlNode {
	if ( self = [super init] ) {
		_xmlNode = [xmlNode retain];
		_children = nil;
		_name = @"root";

		isLeaf = NO;
		hasValue = NO;
		isObject = YES;
	}
	return self;
}


	// init a subnode
- (id)initWithXMLNode:(NSXMLNode *)xmlNode {
	if ( self = [super init] ) {
		_xmlNode  = xmlNode;
		_children = nil;  // those are never set by an init method, so let them just point to nothing
		_value    = nil;  // we compute the value only if actually requested
		
		// we have to check the attributes to find out whether we have a property with value, 
		// or whether there are further nodes down the tree
		NSXMLElement *xmlElement = (NSXMLElement *) _xmlNode;
			
		// Let's check what attributes we have
		// interesting are name, value, and undef, so we store them
		NSArray *attributes = [xmlElement attributes];
		NSXMLNode * attrUndef = nil;
		NSXMLNode * attrValue = nil;
		BOOL isText = NO;
		
		for ( NSXMLNode * attrNode in attributes ) {

			if ( [[attrNode name] isEqualTo:@"name"] ) 
				_name = [attrNode stringValue];

			if ( [[attrNode name] isEqualTo:@"type"] ) 
				if ( [[attrNode stringValue] isEqualToString:@"text"] ) 
					isText = YES;
		
			if ( [[attrNode name] isEqualTo:@"value"] ) 
				attrValue = attrNode;

			if ( [[attrNode name] isEqualTo:@"undef"] ) 
				attrUndef = attrNode;

			}
			
		if ( attrValue != nil || attrUndef != nil ) { 
			// we have a property that is either undef, or has a value stored in an attribute, e.g. POINTED, or CONE_DIM
			// actually, we treat undef and value in the same way, so undef is just a value for us.
			isLeaf = YES;
			hasValue = YES;
			isObject = NO;
		} else {
			// we know that the property we are looking at has exactly one child
			// this is either <m>, <v>, a text entry, or <object>
			if ( isText ) {
				isObject = NO;	
				isLeaf = YES;
				hasValue = YES;  // this is not the way we wanted to use this
			} else {
				NSXMLNode * child = [_xmlNode childAtIndex:0];
				if ( [[child name] isEqualTo:@"object"] ) {  // we have found a property representing a big object
					isObject = YES;	
					isLeaf = NO;
					hasValue = NO;
				}	else {  // whatever we have is either something stored as a matrix or a vector
					isLeaf = YES;
					hasValue = NO;
					isObject = NO;
				}				
			}
		}
	}
	return self;	
}


	// the following methods parse the tags <property>, <m>, <t>, <v>, <e> and store the values in PolymakeTags
	// they are displayed with the methods format* in PolymakeFile.m

	// read an <m> tag
- (PolymakeTag *)readMTagXMLElement:(NSXMLElement *)xmlElement {
	PolymakeTag * mTag = [[PolymakeTag alloc] initWithType:PVMTag];

	NSArray * children = [xmlElement nodesForXPath:@"./v | ./m | ./t" error:nil];	
	
	if ( [children count] == 0 ) { // an m tag cannot have a value, so we found an empty matrix
		[mTag setIsEmpty:YES];
		[mTag setHasSubTags:NO];
		return mTag;
	}

	[mTag setHasSubTags:YES];
	
		// FIXME an <m> tag might have an attribute dim or cols, which we currently ignore
	for ( NSXMLElement * child in children ) {
		if ( [[child name] isEqualToString:@"v"] )     // FIXME the following three if's at this level are mutually exclusive, do something more like switch-case
			[mTag addSubTag:[self readVTagXMLElement:child withSeparator:NO]];
	
		if ( [[child name] isEqualToString:@"m"] ) 
			[mTag addSubTag:[self readMTagXMLElement:child]];
	
		if ( [[child name] isEqualToString:@"t"] )         // FIXME this needs to set the column width
			[mTag addSubTag:[self readTTagXMLElement:child]];
	}
		
	return mTag;
} // end of readMTagXMLElement


	// FIXME a <v> tag might have an attribute dim or i, which we currently ignore
- (PolymakeTag *)readVTagXMLElement:(NSXMLElement *)xmlElement withSeparator:(BOOL)separator {

	PolymakeTag * vTag = [[PolymakeTag alloc] initWithType:PVVTag];
	
	NSArray * eChildren = [xmlElement nodesForXPath:@"./e" error:nil];	
	NSArray * tChildren = [xmlElement nodesForXPath:@"./t" error:nil];	// this happens for quadratic extensions
	if ( [eChildren count] != 0 ) { // we have found a sparse vector
		[vTag setHasSubTags:YES];	
		for ( NSXMLElement * e in eChildren ) 
			[vTag addSubTag:[self readETagXMLElement:e]];
	} else {
		if ( [tChildren count] != 0 ) {
			[vTag setHasSubTags:YES];	
			for ( NSXMLElement * t in tChildren ) 
				[vTag addSubTag:[self readTTagXMLElement:t]];			
		} else {
			[vTag setHasSubTags:NO];
			[vTag setData:[NSMutableArray arrayWithArray:[[xmlElement stringValue] componentsSeparatedByString:@" "]]];
		}
	}
	
	return vTag;
}


	// an eTag can contain only text and potentially have one attribute indicating the index or coordinate
- (PolymakeTag *)readETagXMLElement:(NSXMLElement *)xmlElement {
	PolymakeTag * eTag = [[PolymakeTag alloc] initWithType:PVETag];

	NSArray * iAttr = [xmlElement attributes];
	if ( [iAttr count] != 0 ) {
		[eTag setHasAttributes:YES];
		NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
		for ( NSXMLElement * a in iAttr )
			[dict setObject:[a stringValue] forKey:[a name]];
		[eTag setAttributes:dict];
	}	else {
		[eTag setHasAttributes:NO];
	}
	
	[eTag setData:[NSMutableArray arrayWithArray:[[xmlElement stringValue] componentsSeparatedByString:@" "]]];	
	
	return eTag;
}

	// read a <t> tag
	// remember that <t> tags can either contain text like <v> tags, or have subproperties of any type
	// a <t> Tag cannot have attributes
- (PolymakeTag *)readTTagXMLElement:(NSXMLElement *)xmlElement {
	PolymakeTag * tTag = [[PolymakeTag alloc] initWithType:PVTTag];
	
	NSArray * children = [xmlElement nodesForXPath:@"./v | ./m | ./t | ./e" error:nil];	
	
	if ( [children count] == 0 ) { // we found a tuple with value (maybe empty)
			                           // it might still be a quad extension matrix

		[tTag setHasSubTags:NO];

		NSArray * iAttr = [xmlElement attributes];
		if ( [iAttr count] != 0 ) { // we have found a sparse representation of a QuadraticExtension
			
			[tTag setHasAttributes:YES];
			NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
			for ( NSXMLElement * a in iAttr )
				[dict setObject:[a stringValue] forKey:[a name]];
			[tTag setAttributes:dict];
			
		} else {

			[tTag setHasAttributes:NO];
		}
		
		if ( [[xmlElement stringValue] length] == 0 )
			[tTag addSubTag:@""]; 
		else {
		
			[tTag setData:[NSMutableArray arrayWithArray:[[xmlElement stringValue] componentsSeparatedByString:@" "]]];
		}
		return tTag;
	}

		// if we reached this then we have found a <t> tag with subproperties
	[tTag setHasSubTags:YES];

	for ( NSXMLElement * child in children ) {
		if ( [[child name] isEqualToString:@"v"] )
			[tTag addSubTag:[self readVTagXMLElement:child withSeparator:NO]];
	
		if ( [[child name] isEqualToString:@"m"] )
			[tTag addSubTag:[self readMTagXMLElement:child]];
	
		if ( [[child name] isEqualToString:@"t"] )
			[tTag addSubTag:[self readTTagXMLElement:child]];

		if ( [[child name] isEqualToString:@"e"] )
			[tTag addSubTag:[self readETagXMLElement:child]];

	}
	
	return tTag;
}


	// compute the values of a property
	// remember that this is not done during initialization
	// but only if the user requests that property for display

	//FIXME we currently don't read:
	// - attachments
	//   an attachment can have attributes: name, type (required) and ext, value (not required)
	// - markes for extensions
	// we might want to read the time stamp
- (PolymakeTag *)value {

	if ( _value == nil ) {
		_value = [[PolymakeTag alloc] initWithType:PVPropTag];
		if ( isLeaf ) {
			if ( hasValue ) { // our value is either a number or a boolean stored in an attribute
				[_value setHasSubTags:NO];
				
				NSXMLElement *xmlElement = (NSXMLElement *) _xmlNode;
				NSArray *attributes = [xmlElement attributes];
				NSXMLNode * attrUndef = nil;
				NSXMLNode * attrValue = nil;
				BOOL isText = NO;
				for ( NSXMLNode * attrNode in attributes ) {
					
					if ( [[attrNode name] isEqualTo:@"type"] ) 
						isText = YES;
					
					if ( [[attrNode name] isEqualTo:@"value"] ) 
						attrValue = attrNode;
					
					if ( [[attrNode name] isEqualTo:@"undef"] ) 
						attrUndef = attrNode;
					
				}
				
				if ( isText ) 
					[_value addSubTag:[[NSString alloc] initWithString:[xmlElement stringValue]]];
				
				if ( attrValue != nil )
					[_value addSubTag:[[NSString alloc] initWithString:[attrValue stringValue]]];
				
				if ( attrUndef != nil )
					[_value addSubTag:[[NSString alloc] initWithString:[attrUndef stringValue]]];
				
			} else {
				[_value setHasSubTags:YES];
				NSArray * matrixChild = [_xmlNode nodesForXPath:@"./m" error:nil];
				NSArray * vectorChild = [_xmlNode nodesForXPath:@"./v" error:nil];
				NSArray * tupleChild = [_xmlNode nodesForXPath:@"./t" error:nil];
				
				if ( [vectorChild count] > 0 ) 
					for ( NSXMLElement * child in vectorChild ) 
						[_value addSubTag:[self readVTagXMLElement:(NSXMLElement *)child withSeparator:NO]];

				if ( [matrixChild count] > 0 ) 
					for ( NSXMLElement * child in matrixChild ) 
						[_value addSubTag:[self readMTagXMLElement:(NSXMLElement *)child]];

				if ( [tupleChild count] > 0 )
					for ( NSXMLElement * child in tupleChild )
						[_value addSubTag:[self readTTagXMLElement:(NSXMLElement *)child]];

			}
		}	else {
			[_value addSubTag:[[NSString alloc] initWithString:@"<no value>"]];
		}
	}

	return _value;
}


	// get the children of a tag
	// as with the value this is only done if really needed
	// i.e. if the user opens the triangle in the display
- (NSArray *)children {
		if ( _children == nil ) {
		NSMutableArray *newChildren = [NSMutableArray array];
		if ( isObject ) { // okay, here we really have to do something
			NSString * xmlPath;
			if ( [_name isEqualTo:@"root"] ) {
				xmlPath = [[NSString alloc ] initWithString:@"./property"];
			} else {
				xmlPath = [[NSString alloc] initWithString:@"./object/property"];
			}
			NSArray * childProperties = [_xmlNode nodesForXPath:xmlPath error:nil];
			for (NSXMLNode * xmlNode in childProperties) {
				PropertyXMLNode * newChild = [[[PropertyXMLNode alloc] initWithXMLNode:xmlNode] autorelease];
				[newChildren addObject:newChild];
			}
			[xmlPath release];	
		} 

		_children = [newChildren retain];
	}
	return _children;
}
 
@end
