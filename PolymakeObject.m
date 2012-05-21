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
 * PolymakeObject.m
 * PolyViewer
 **************************************************************************/


#import "PolymakeObject.h"
#import "PropertyXMLNode.h"


@implementation PolymakeObject

@synthesize objectType   = _objectType;
@synthesize filename     = _filename;
@synthesize name         = _name;
@synthesize description  = _description;
@synthesize credits      = _creditsDict;
@synthesize document     = _doc;
@synthesize root         = _rootNode;



/***************************************************************************
 * init
 ***************************************************************************/

- (id)init {

	if ( self = [super init] ) {

		_filename     = nil;
		_name         = nil;
		_description  = nil;
		_creditsDict  = nil;
		_doc          = nil; 
		_rootNode     = nil;
		
	} 
	
	return self;
}	


/***************************************************************************
 * init with a file
 ***************************************************************************/

- (void)initObjectWithURL:(NSURL *)input {
	
		// initialize document
	_doc = [[NSXMLDocument alloc] initWithContentsOfURL: input options:0 error:NULL];
	
		// initialize root node of document
	NSXMLElement* root  = [_doc rootElement];
	
		// and create one of our own xml nodes
	_rootNode = [[[PropertyXMLNode alloc] initRootWithXMLNode:root] retain];
	
		// determine the object type of the given object
		// this is stored as an attribute of the root node
	NSArray * rootTypeAttr = [root nodesForXPath:@"./@type" error:nil];
	if ( [rootTypeAttr count] > 0 ) 
		_objectType = [NSString stringWithString:[[rootTypeAttr objectAtIndex:0] stringValue]];
	else 
		_objectType = [NSString stringWithString:@""];
	

		// check whether the polymake object has a name
		// as the type this would be an attribute of the root
	NSArray * rootAttr = [root nodesForXPath:@"./@name" error:nil];
	if ( [rootAttr count] > 0 ) 
		_name = [NSString stringWithString:[[rootAttr objectAtIndex:0] stringValue]];
	else 
		_name = [NSString stringWithString:@""];
	
	
		// check whether the polytope has a description
		// this is stored in a property directly below the root
	NSArray * rootDescr = [root nodesForXPath:@"./description" error:nil];
	if ( [rootDescr count] > 0 ) 
		_description = [NSString stringWithString:[[rootDescr objectAtIndex:0] stringValue]];
	else 
		_description = [NSString stringWithString:@"<no description given>"];

		// read in the credits
		// they are stored as properties below the root
	NSArray * credit = [root nodesForXPath:@"./credit" error:nil];
	NSArray * creditAttr = [root nodesForXPath:@"./credit/@product" error:nil];
	
	NSMutableArray * creditLabels = [NSMutableArray array];
	NSMutableArray * creditStrings = [NSMutableArray array];
	int i = 0;
	for ( NSXMLNode * cr in credit ) 
		[creditStrings insertObject:[[cr stringValue] stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, 1)] atIndex:i++];
	i = 0;
	for ( NSXMLNode * cr in creditAttr ) 
		[creditLabels insertObject:[cr stringValue] atIndex:i++];
	_creditsDict = [NSDictionary dictionaryWithObjects:creditStrings forKeys:creditLabels];
	
		// apparently we have to retain this
	[_creditsDict retain];
	
		// keep the input filename
	_filename = [input retain];
}


	/***************************************************************************
	 * dealloc
	 ***************************************************************************/
- (void) dealloc {
	[_doc release];
	[_rootNode release];
	[_filename release];
	[_creditsDict release];
	[super dealloc];
}

@end
