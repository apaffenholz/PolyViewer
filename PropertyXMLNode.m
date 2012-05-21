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


@implementation PropertyXMLNode

@synthesize XMLNode = _xmlNode;
@synthesize name    = _name;
@synthesize hasValue, isSimpleProperty, isObject, isLeaf;
@dynamic    children;
@dynamic    value;

- (id)initRootWithXMLNode:(NSXMLNode *)xmlNode {
	if ( self = [super init] ) {
		_xmlNode = [xmlNode retain];
		_children = nil;
		_name = @"root";

		isLeaf = NO;
		hasValue = NO;
		isSimpleProperty = NO;
		isObject = YES;
	}
	return self;
}


- (id)initWithXMLNode:(NSXMLNode *)xmlNode {
	if ( self = [super init] ) {
		_xmlNode  = xmlNode;
		_children = nil;  // those are never set by an init method, so let them just point to nothing
		
		// we have to check the attributes to find out whether we have a property with value, 
		// or whether there are further nodes down the tree
		NSXMLElement *xmlElement = (NSXMLElement *) _xmlNode;
			
		//Let's check what attributes we have
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
			isSimpleProperty = YES;
			isObject = NO;
			_value = nil;
		} else {
			// we know that the property we are looking at has exactly one child
			// this is either <m>, <v>, a text entry, or <object>
			if ( isText ) {
				isObject = NO;	
				isSimpleProperty = YES;
				isLeaf = YES;
				hasValue = YES;  // this is not the way we wanted to use this
				_value = nil;				
			} else {
				NSXMLNode * child = [_xmlNode childAtIndex:0];
				if ( [[child name] isEqualTo:@"object"] ) {  // we have found a property representing a big object
					isObject = YES;	
					isSimpleProperty = NO;
					isLeaf = NO;
					hasValue = NO;
					_value = nil;
				}	else {  // whatever we have is either something stored as a matrix or a vector
					isLeaf = YES;
					hasValue = NO;
					isObject = NO;
					isSimpleProperty = YES;
					_value = nil;
				}				
			}
		}
	}
	return self;	
}



	//***************************************************
	// format for <m> tags
	// we want to print children rowwise
- (NSString *) formatMTagXMLElement:(NSXMLElement *)xmlElement {
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	NSArray * children = [xmlElement nodesForXPath:@"./v | ./m | ./t" error:nil];	
	
	if ( [children count] == 0 ) { // we found an empty matrix
		[value stringByAppendingString:@""];
		return value;
	}

		// we assume that all children of <t> have the same type

	if ( [[[children objectAtIndex:0] name] isEqualToString:@"v"] ) { // we have a couple of <v> children
		for ( NSXMLElement * child in children ) 
			[value appendFormat:@"%@\n",[self formatVTagXMLElement:child withSeparator:NO]];
	}
	
	if ( [[[children objectAtIndex:0] name] isEqualToString:@"m"] ) { // we have a couple of <m> children
		BOOL first = YES;
		if ( [children count] > 1 ) {
			for ( NSXMLElement * child in children ) {
				if ( !first ) 
					[value appendString:@"],"];
				first = NO;
				[value appendFormat:@"[%@",[self formatMTagXMLElement:child]];
			}
			[value appendString:@"]"];
		} else 
			[value appendString:[self formatMTagXMLElement:[children objectAtIndex:0]]];
	}
	
	if ( [[[children objectAtIndex:0] name] isEqualToString:@"t"] ) { // we have a couple of <t> children
		if ( [children count] > 1 ) {
			BOOL first = YES;
			for ( NSXMLElement * child in children ) {
				if ( !first ) 
					[value appendString:@">\n"];
				first = NO;				
				[value appendFormat:@"<%@",[self formatTTagXMLElement:child]];
			}
			[value appendString:@">"];
		} else {
				[value appendFormat:@"%@",[self formatTTagXMLElement:[children objectAtIndex:0]]];	
		}
	}
	return value;
}


- (NSString *) formatTTagXMLElement:(NSXMLElement *)xmlElement {
	
		// allowed children are <v>, <t>, <e> and <m>
		// no attributes are allowed

	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	NSArray * children = [xmlElement nodesForXPath:@"./v | ./m | ./t | ./e" error:nil];	

	if ( [children count] == 0 ) { // we found an empty tuple
		[value stringByAppendingString:@""];
		return value;
	}
	
		// we assume that all children of <t> have the same type
	
		// we start with the <e> children
	if ( [[[children objectAtIndex:0] name] isEqualToString:@"e"] ) { // we have a couple of <e> children
		BOOL first = YES;
		for ( NSXMLElement * child in children ) {
			if ( !first ) 
				[value appendString:@", "];
			first = NO;
			[value appendFormat:@"%@",[self formatETagXMLElement:child]];
		}
	}
	
	if ( [[[children objectAtIndex:0] name] isEqualToString:@"v"] ) { // we have a couple of <v> children
		BOOL first = YES;
		for ( NSXMLElement * child in children ) {
			if ( !first ) 
				[value appendString:@", "];		
			first = NO;
			[value appendFormat:@"(%@)",[self formatVTagXMLElement:child withSeparator:YES]];
		}
	}
	
	if ( [[[children objectAtIndex:0] name] isEqualToString:@"m"] ) { // we have a couple of <m> children
		[value appendString:@"[\n"];
		for ( NSXMLElement * child in children ) 
			[value appendFormat:@"[%@]\n",[self formatMTagXMLElement:child]];
		[value appendString:@"]"];
	}

	if ( [[[children objectAtIndex:0] name] isEqualToString:@"t"] ) { // we have a couple of <t> children
		[value appendString:@"<\n"];
		for ( NSXMLElement * child in children ) 
			[value appendFormat:@"[%@]\n",[self formatMTagXMLElement:child]];
		[value appendString:@">"];
	}
	return value;	
}


- (NSString *) formatVTagXMLElement:(NSXMLElement *)xmlElement withSeparator:(BOOL)separator {
		// FIXME a <v> tag might have an attribute dim or i, which we currently ignore
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	NSArray * children = [xmlElement nodesForXPath:@"./e" error:nil];	
	if ( [children count] != 0 ) { // we have found a sparse matrix
		BOOL first = YES;
		for ( NSXMLElement * e in children ) {
			if ( !first ) 
				[value appendString:@", "];
			first = NO;
			[value appendString:[self formatETagXMLElement:e]];
		}
	} else {
		[value appendFormat:@"%@",[xmlElement stringValue]];
		if ( separator ) {
			NSRange range = NSMakeRange(0,[value length]);
			[value replaceOccurrencesOfString:@" " withString:@", " options:0 range:range];
		}
	}

	return value;	
}


- (NSString *) formatETagXMLElement:(NSXMLElement *)xmlElement {
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];	
	NSArray * iAttr = [xmlElement attributes];

	[value appendFormat:@"(%@,%@)", [[iAttr objectAtIndex:0] stringValue], [xmlElement stringValue]];
	return value;
}


- (NSAttributedString *)value {
	
	if ( _value == nil ) {
		NSAttributedString * newValue;
		if ( isLeaf ) {
			if ( hasValue ) { // our value is either a number or a boolean stored in an attribute
				
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
					newValue = [[NSAttributedString alloc] initWithString:[xmlElement stringValue]];
				if ( attrValue != nil )
					newValue = [[NSAttributedString alloc] initWithString:[attrValue stringValue]];
				if ( attrUndef != nil )
					newValue = [[NSAttributedString alloc] initWithString:[attrUndef stringValue]];				
			} else {
				NSArray * matrixChild = [_xmlNode nodesForXPath:@"./m" error:nil];
				NSArray * vectorChild = [_xmlNode nodesForXPath:@"./v" error:nil];
				NSArray * tupleChild = [_xmlNode nodesForXPath:@"./t" error:nil];

				if ( [vectorChild count] > 0 ) 
					newValue = [[NSAttributedString alloc] initWithString:[self formatVTagXMLElement:(NSXMLElement *)_xmlNode withSeparator:NO]];
				if ( [matrixChild count] > 0 )
					newValue = [[NSAttributedString alloc] initWithString:[self formatMTagXMLElement:(NSXMLElement *)_xmlNode]];
				if ( [tupleChild count] > 0 )
					newValue = [[NSAttributedString alloc] initWithString:[self formatTTagXMLElement:(NSXMLElement *)_xmlNode]];
			}			
		} else {
			newValue = [[NSAttributedString alloc] initWithString:@""];
		}
		_value = newValue; // no retain necessary, we have alloc'ed it in this method
	}
	return _value;  // no retain, see above
}


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
