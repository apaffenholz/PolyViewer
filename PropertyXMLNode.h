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
 * PropertyXMLNode.h
 * PolyViewer
 **************************************************************************/


#import <Cocoa/Cocoa.h>


@interface PropertyXMLNode : NSObject {
	NSXMLNode * _xmlNode;
	NSString *  _name;
	NSArray *   _children;
	NSAttributedString * _value;
	
	BOOL hasValue;
	BOOL isSimpleProperty;
	BOOL isObject;
	BOOL isLeaf;
}

- (id) initRootWithXMLNode:(NSXMLNode *)xmlNode;
- (id) initWithXMLNode:(NSXMLNode *)xmlNode;
- (NSArray *)children;

- (NSString *)formatMTagXMLElement:(NSXMLElement *)xmlElement;
- (NSString *)formatVTagXMLElement:(NSXMLElement *)xmlElement withSeparator:(BOOL)separator;
- (NSString *)formatTTagXMLElement:(NSXMLElement *)xmlElement;
- (NSString *)formatETagXMLElement:(NSXMLElement *)xmlElement;

@property (readonly,copy) NSXMLNode * XMLNode;
@property (readonly,copy) NSAttributedString * value;
@property (readonly,copy) NSString * name;
@property (readonly)      NSArray * children;
@property (readonly)      BOOL hasValue;
@property (readonly)      BOOL isSimpleProperty;
@property (readonly)      BOOL isObject;
@property (readonly)      BOOL isLeaf;

@end
