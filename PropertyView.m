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
 * PropertyView.m
 * PolyViewer
 **************************************************************************/

#import "PropertyView.h"
#import "PolymakeObjectPropertyTreeNode.h"


@implementation PropertyView

- (id)init {
	NSLog(@"[PropertyView] init]");
	self = [super init];
	return self;	
}


// highlight color for selected item
-(id)_highlightColorForCell:(NSCell *)cell {
  return [NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1];
}

// get the secondary menu
-(NSMenu*)menuForEvent:(NSEvent*)event {
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    int row=[self rowAtPoint:pt];
    return [self defaultMenuForRow:row];
}


// build up context menu
-(NSMenu*)defaultMenuForRow:(int)row {

    // can this happen?
    if (row < 0)
        return nil;
    
    // get the clicked property node
    // FIXME eventually we want to offer different options depending on the type:
    // FIXME for objects (non-leafs) offer to add a subproperty of the object or
    // FIXME a property at the same level (as for leaf nodes)
    // we can't stick with just adding subporperties as we have no visual "root node"
    //
    PolymakeObjectPropertyTreeNode * propNode = (PolymakeObjectPropertyTreeNode *)[self itemAtRow:row];
    BOOL isObj = [propNode isObject];
    
    NSMenuItem * addPropItem = [[NSMenuItem alloc] initWithTitle:@"Compute property"
                                                          action:@selector(addProperty:)
                                                   keyEquivalent:@""];
    
    [addPropItem setRepresentedObject:[NSNumber numberWithInt:row]];
    
    NSMenu *theMenu = [[[NSMenu alloc]
                        initWithTitle:@"Context Menu"]
                       autorelease];
    [theMenu addItem:addPropItem];
    
    if ( isObj ) {
        NSMenuItem * addSubPropItem = [[NSMenuItem alloc] initWithTitle:@"Compute subproperty of current"
                                                              action:@selector(addSubProperty:)
                                                       keyEquivalent:@""];
        
        [addSubPropItem setRepresentedObject:[NSNumber numberWithInt:row]];
        [theMenu addItem:addSubPropItem];
    }
    
    return theMenu;
}

    
// actually ocmpute the property and force a reload of the outline view
// reloading is necessary as we cannot just add another row to the view:
//    polymake might add further properties necessary to compute the one asked for
//    those should be displayed as well but we have no chance to get notified about what
//    was actually added
//
// FIXME this should go into the controller
- (void)addProperty:(id)sender {
    NSLog(@"[PropertyView addProperty] called");

    int row = [[sender representedObject] intValue];
    NSLog(@"The menu item's object is %d",row);
    
    NSString * _property = nil;
    NSAlert *alert = [NSAlert alertWithMessageText: @"Compute property"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@"<property>"];
    [input autorelease];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        _property = [input stringValue];
        NSLog(@"got %@", [input stringValue]);
    } else if (button == NSAlertAlternateReturn) {
    } else {
    }
    
    PolymakeObjectPropertyTreeNode * propNode = (PolymakeObjectPropertyTreeNode *)[self itemAtRow:row];
    PolymakeObjectPropertyTreeNode * parent = (PolymakeObjectPropertyTreeNode *)[self parentForItem:[self itemAtRow:row]];
    if ( ![propNode isObject] ) {
        NSLog(@"[PropertyView addProperty] switching to parent");
        [[propNode polyObj] getProperty:_property];   //FIXME change this: we are computing the prop and throw away the result
    } else {
        if ( parent == nil ) {
             NSLog(@"[PropertyView addProperty] parent is nil");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ComputePropertyOfRoot" object:_property];
        } else {
            [[parent polyObj] getProperty:_property];
        }
    }
    
    // here we again have to find out wether our property is a child of the root or some lower node
    // we treat the root differently as it is not displayed in the view
    // and we associate additional information with the node
    if ( parent == nil ) {
        NSLog(@"[PropertyView addProperty] property added to root");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChildrenOfRootHaveChanged" object:nil];
    } else {
        [parent resetChildren];
        [self reloadItem:nil reloadChildren:YES];
    }
}




- (void)addSubProperty:(id)sender {
    NSLog(@"[PropertyView addSubProperty] called");
    
    int row = [[sender representedObject] intValue];
    NSLog(@"The menu item's object is %d",row);
    
    NSString * _property = nil;
    NSAlert *alert = [NSAlert alertWithMessageText: @"Compute property"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@"<property>"];
    [input autorelease];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        _property = [input stringValue];
        NSLog(@"got %@", [input stringValue]);
    } else if (button == NSAlertAlternateReturn) {
    } else {
    }
    
    PolymakeObjectPropertyTreeNode * propNode = (PolymakeObjectPropertyTreeNode *)[self itemAtRow:row];
    [[propNode polyObj] getProperty:_property];   //FIXME change this: we are computing the prop and throw away the result
    [propNode resetChildren];
    [self reloadItem:nil reloadChildren:YES];
}

@end
