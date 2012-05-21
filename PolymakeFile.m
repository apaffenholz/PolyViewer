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
 * PolymakeFile.m
 * PolyViewer
 **************************************************************************/


#import "PolymakeFile.h"
#import "AppWindowController.h"

@implementation PolymakeFile

@synthesize lastOpenDialogStartDirectory = _lastOpenDialogStartDirectory;
@synthesize polymakeObject = _polyObj;


# pragma mark init

- (id)init {
		self = [super init];
		if (self) {
			
			_rootNode = nil;
			_polyObj = nil;
			_currentPropertyText = nil;
			
			// the directory shown in the file open dialog
			// initially this should point to the users $HOME
			[self setLastOpenDialogStartDirectory:NSHomeDirectory()];

		
		[	[NSNotificationCenter defaultCenter] addObserver:self 
																								selector:@selector(redrawValueTextViewWrapper:) 
																										name:NSOutlineViewSelectionDidChangeNotification 
																									object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self 
																							 selector:@selector(outlineViewSelectionWillChange:) 
																									 name:NSOutlineViewSelectionIsChangingNotification 
																								 object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self 
																							 selector:@selector(tableViewSelectionDidChange:) 
																									 name:NSTableViewSelectionDidChangeNotification
																								 object:nil];
			
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_rootNode                 release];
	[_currentPropertyText      release];
	[_polyObj                  release];
	[_valueLineNumberView      release];
	[super dealloc];
} 


- (void)makeWindowControllers {
	AppWindowController* controller = nil;
	controller = [[AppWindowController alloc] initWithWindowNibName: @"PolyViewer" owner: self];
	[self addWindowController: controller];
}

/*
- (void)addWindowController:(NSWindowController *)aController {
	
}

- (NSString *)windowNibName {
    return @"PolyViewer";
}
 */

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
	[super windowControllerDidLoadNib:aController];
	
	_rootNode = [_polyObj root];	

	NSFont * font = [NSFont systemFontOfSize:14];

	[_type setStringValue:[_polyObj objectType]];	          	// set object type
	[_type setFont:font];
	
	[_name setStringValue:[_polyObj name]];                  	// set object name
	[_name setFont:font];
	
	[_descriptionView setString:[_polyObj description]];  		// object description
	[_descriptionView setFont:font];
	
		// propertyView is an PropertyView::NSOutlineView
	[_propertyView setTarget:self];
	[_propertyView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
	[_propertyView reloadData];
	[_propertyView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	[self redrawValueTextView];
	
		// _creditTable is an NSTableView
		// we want no borders
		// and custom colors for the fields
	[_creditTable setDelegate:self];
	NSSize size;
	size.height = 0.0;
	size.width = 0.0;
	[_creditTable setIntercellSpacing:size];
	[_creditTable setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];	
	[_creditTable reloadData];
	[_creditTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NSTableViewSelectionDidChangeNotification" object:nil];
	
		// initialize the row numbers displayed left of the property values
	_valueLineNumberView = [[ValueLineNumberView alloc] initWithScrollView:_valueScrollView];
	[_valueScrollView setVerticalRulerView:_valueLineNumberView];
	[_valueScrollView setHasHorizontalRuler:NO];
	[_valueScrollView setHasVerticalRuler:YES];
	[_valueScrollView setRulersVisible:YES];
	
		// set the font for the property values
	NSString * floatString = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"propertyWindowFontSize"];
	CGFloat floatVal = [floatString floatValue];
	NSFont * valueFont = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"textFontName"] 
																		 size:floatVal];

	if ( valueFont != nil ) 
		[_valueTextView setFont:valueFont];	
		else                                                        // if there is nothing selected, use a default
		[_valueTextView setFont:font];
	
} // end of windowControllerDidLoadNib


	// this app is currently read-only...
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}


- (BOOL)readFromURL:(NSURL *)input ofType:(NSString *)typeName error:(NSError **)outError {
	_polyObj = [[PolymakeObject alloc] init];
	[_polyObj	initObjectWithURL:input];
	return YES;
}




	// the close button on the main window should just close the window
- (IBAction)closePoly:(id)sender {
	[self close];
}


# pragma mark PropertyView


/*********************************************************************
 * methods for _propertyView
 * this is a PropertyView::NSOutlineView
 * methods overwritten from base class
 *********************************************************************/

/****************/
- (NSInteger) outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item {
	if ( item == nil ) {
		if ( _rootNode == nil ) 
			return 0;
		return [[_rootNode children] count];
	}
	
	PropertyXMLNode * propNode = (PropertyXMLNode *)item;
	return [[propNode children] count]; 
}


/****************/
- (BOOL) outlineView:(NSOutlineView *)ov isItemExpandable:(id)item {
	if ( item == nil ) {
		return YES;	
	}
	
	PropertyXMLNode * propNode = (PropertyXMLNode *)item;
	return ![propNode isLeaf]; 
}


/****************/
- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item {
	if ( item == nil ) {
		return [[_rootNode children] objectAtIndex:index];
	}
	PropertyXMLNode *node = (PropertyXMLNode *)item;
	return [[node children] objectAtIndex:index];
}


/****************/
- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	PropertyXMLNode *node = (PropertyXMLNode *)item;
	return [node name];
}


/****************/
- (void)outlineViewSelectionWillChange:(NSNotification *)aNotification {
}



#pragma mark _ValueTextView

/*********************************************************************
 * methods for _valueTextView 
 * methods overwritten from base class
 **********************************************************************/


	// fill the view with the value of the current property
- (void)redrawValueTextView {
	
		// determine which property we want to display
	id selectedItem = [_propertyView itemAtRow:[_propertyView selectedRow]];
	
		// get the property
	if ( selectedItem != nil ) {
		PropertyXMLNode * propNode = (PropertyXMLNode *)selectedItem;
		_currentPropertyText = [[NSMutableAttributedString alloc] initWithAttributedString:[propNode value]];
		[_valueTextView setString:[NSString stringWithString:[[propNode value] string]]];
	} else {  // okay, nothing is selected, so clear the view
		NSString * attrString = [[NSString alloc] initWithString:@"<empty>"];
		_currentPropertyText = [[NSMutableString alloc] initWithString:attrString];
		[_valueTextView setString:attrString];
		[attrString release];
	}
	
}


	// just a wrapper that accepts a notification and ignores it
- (void)redrawValueTextViewWrapper:(NSNotification *)aNotification {
	[self redrawValueTextView];
}


	// the property list should not resize horizontally if the window is resized
	// the split view has two subviews: 0 are the properties, 1 are the values
- (BOOL)splitView:(NSSplitView *)sv shouldAdjustSizeOfSubview:(id)aSubView {
	if ( aSubView == [[sv subviews] objectAtIndex:1] ) 
		return YES;
	return NO;
}



#pragma mark CreditView

/*********************************************************************
 * TableView methods for credits info window
 * methods overwritten from base class
 *********************************************************************/


- (NSInteger) numberOfRowsInTableView:(NSTableView *)tv {
	if ( _polyObj != nil ) 
		return [[_polyObj credits] count];
	
		// default return 0
	return 0;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger) row {
	NSString * value = [NSString stringWithString:(NSString *)[[[_polyObj credits] allKeys] objectAtIndex:row]];
	return value;
}


- (void)tableView:(NSTableView *)tv setObjectValue:(id)item forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
	item = [NSString stringWithString:(NSString *)[[[_polyObj credits] allKeys] objectAtIndex:row]];
}


- (void) tableViewSelectionDidChange: (NSNotification *) notification {
	int row = [_creditTable selectedRow];
	
	if ( row != -1 ) {
		NSArray * allValues = [[_polyObj credits] allValues];
		NSString * value = [[NSString alloc] initWithString:(NSString *)[allValues objectAtIndex:row]];
		[_creditView setString:value];
		[value release];
	}
} 


	// this just sets the background color
-(void)tableView:(NSTableView *)tv willDisplayCell:(id)item forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
	if ( [tv selectedRow] == row )
		[item setBackgroundColor:[NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1]];
	else
		[item setBackgroundColor:[NSColor colorWithCalibratedRed:0.8 green:0.41 blue:0.14 alpha:1]];
}


@end
