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
 * PolymakeObjectController.m
 * PolyViewer
 **************************************************************************/


#import "PolymakeObjectController.h"
#import "AppWindowController.h"
#import "PolymakeInstanceWrapper.h"
#import "PolymakeObjectWrapper.h"
#import "MainPolymakeObject.h"

NSString * const PVValueFormattingDidChangeNotification = @"PVValueFormattingDidChange";
NSString * const ChildrenOfRootHaveChangedNotification = @"ChildrenOfRootHaveChanged";
NSString * const ComputePropertyOfRootNotification = @"ComputePropertyOfRoot";

@implementation PolymakeObjectController

@synthesize lastOpenDialogStartDirectory = _lastOpenDialogStartDirectory;
@synthesize polymakeObject = _polyObj;
@synthesize alignedColumns = _alignedColumns;


# pragma mark init

- (id)init {
		self = [super init];
		if (self) {
			
			[self setPolymakeObject:nil];
			_currentPropertyValue = nil;
			_alignedColumns = NO;
			
			// the directory shown in the file open dialog
			// initially this should point to the users $HOME
			[self setLastOpenDialogStartDirectory:NSHomeDirectory()];

		
			[[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(redrawValueTextViewWrapper:)
                                                         name:PVValueFormattingDidChangeNotification
                                                       object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self
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
			[[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(childrenOfRootHaveChanged:)
                                                         name:ChildrenOfRootHaveChangedNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(computePropertyOfRoot:)
                                                         name:ComputePropertyOfRootNotification
                                                       object:nil];
			
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_currentPropertyValue      release];
	[_polyObj                  release];
	[_valueLineNumberView      release];
	[super dealloc];
} 


- (void)makeWindowControllers {
	AppWindowController* controller = nil;
	controller = [[AppWindowController alloc] initWithWindowNibName: @"PolyViewer" owner: self];
	[self addWindowController: controller];
    [controller release];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
	[super windowControllerDidLoadNib:aController];
	   
    NSFont * font = [NSFont fontWithName:@"Menlo" size:14];
    
    [_type setStringValue:[_polyObj objectType]];	           	// set object type
//    [_type setStringValue:[[self polymakeObject] objectType]];
	[_type setFont:font];
    
	[_name setStringValue:[_polyObj name]];                  	// set object name
	[_name setFont:font];

    [_currentPropertyName setStringValue:@"<root>"];          	// set object name
	[_currentPropertyName setFont:font];
    
	[_descriptionView setString:[_polyObj description]];  		// object description
	[_descriptionView setFont:font];
     
    
	// propertyView is an PropertyView::NSOutlineView
    // initialize
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NSTableViewSelectionDidChangeNotification" object:_creditTable];
	
    
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
    
    if ( ![_polyObj databaseObject] )
        [_metaInfoTabView removeTabViewItem:[_metaInfoTabView tabViewItemAtIndex:3]];
    else {
        [_metaInfoTabView selectTabViewItemAtIndex:3];
    }
    
	
} // end of windowControllerDidLoadNib


- (BOOL)readFromDatabase:(NSString *)database
           andCollection:(NSString *)collection
                  withID:(NSString *)ID {

    NSLog(@"[PolymakeObjectController readFromDatabase andCollection withID] called");
    
    _polyObj = [[MainPolymakeObject alloc] retrieveFromDatabase:database
                                              andCollection:collection
                                                     withID:ID];
    if ( _polyObj == nil )
        return NO;
    return YES;
}



// method overriden from NSDocument
// the only input routine in this application
- (BOOL)readFromURL:(NSURL *)input
             ofType:(NSString *)typeName
              error:(NSError **)outError {
    NSLog(@"[PolymakeObjectController readFromURL] called");
  
    _polyObj = [[MainPolymakeObject alloc] initObjectWithURL:input];
    
    NSLog(@"[PolymakeObjectController readFromURL] returning");
    if ( _polyObj == nil )
        return NO;
    else
        return YES;
}



// the close button on the main window should just close the window
- (IBAction)closePoly:(id)sender {
	[self close];
}


// aligned columns for matrices
- (IBAction)fixAlignedColumns:(id)sender {
  if ( [_alignedColumnsBox state] == 0 )
		_alignedColumns = NO;
	else 
		_alignedColumns = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:PVValueFormattingDidChangeNotification object:nil];	
}


# pragma mark PropertyView

/*********************************************************************
 * methods for _propertyView
 * this is a PropertyView::NSOutlineView
 * methods overwritten from base class
 *********************************************************************/

/****************/
- (NSInteger) outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item {
    NSLog(@"[PolymakeObjectController outlineView:NumberOfChildrenOfItem:] called");
              
	if ( item == nil ) {
		if ( _polyObj == nil )
			return 0;
		return [[[_polyObj rootPerl] children] count];
	}
	
	PolymakeObjectPropertyTreeNode * propNode = (PolymakeObjectPropertyTreeNode *)item;
    
    NSLog(@"[PolymakeObjectController outlineView:NumberOfChildrenOfItem:] returning number of children of node %@", [propNode propertyName]);
    NSLog(@"[PolymakeObjectController outlineView:NumberOfChildrenOfItem:] returning %lu children",(unsigned long)[[propNode children] count]);
	return [[propNode children] count];
}


/****************/
- (BOOL) outlineView:(NSOutlineView *)ov isItemExpandable:(id)item {
    //NSLog(@"[PolymakeObjectController outlineView is Expandable] entering");

	if ( item == nil ) {
        //NSLog(@"[PolymakeObjectController outlineView is Expandable] leaving (item is nil)");
		return YES;
	}
	
	PolymakeObjectPropertyTreeNode * propNode = (PolymakeObjectPropertyTreeNode *)item;

    //NSLog(@"[PolymakeObjectController outlineView is Expandable] leaving, item is %@", [propNode propertyName]);
	return ![propNode isLeaf];
}


/****************/
- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item {
    //NSLog(@"[PolymakeObjectController outlineView child ofItem] entering]");

	if ( item == nil ) {

        //NSLog(@"[PolymakeObjectController outlineView child ofItem] leaving]");
		return [[[_polyObj rootPerl] children] objectAtIndex:index];
	}
    
	PolymakeObjectPropertyTreeNode *node = (PolymakeObjectPropertyTreeNode *)item;
    
    //NSLog(@"[PolymakeObjectController outlineView child ofItem] leaving]");
	return [[node children] objectAtIndex:index];
}


/****************/
- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    //NSLog(@"[PolymakeObjectController outlineView child objectValueForTableColumn] entering");

	PolymakeObjectPropertyTreeNode *node = (PolymakeObjectPropertyTreeNode *)item;
    NSString *name = [NSString stringWithString:[node propertyName]];
    
    if ( [node isMultiple] ) {
        
        NSString *propname = [NSString stringWithString:[node name]];
        if ( [propname length] > 0 )
            name = [name stringByAppendingString:[NSString stringWithFormat:@" (%@)",propname]];
        else
            name = [name stringByAppendingString:[NSString stringWithFormat:@" (%d)",[node index]]];
    }
        
    //NSLog(@"[PolymakeObjectController outlineView child objectValueForTableColumn] leaving for item %@", item);
	return name;
}


/****************/
- (void)outlineViewSelectionWillChange:(NSNotification *)aNotification {
}

- (void)childrenOfRootHaveChanged:(NSNotification *)aNotification {
    [[_polyObj rootPerl] resetChildren];
    [_propertyView reloadItem:nil reloadChildren:YES];
}

- (void)computePropertyOfRoot:(NSNotification *)aNotification {
    NSLog(@"[PolymakeObjectController computePropertyOfRoot] called");
    NSString *_property = [aNotification object];
    [[[_polyObj rootPerl] polyObj] getProperty:_property];
}

#pragma mark _ValueTextView


/*********************************************************************
 * methods for _valueTextView 
 * methods overwritten from base class
 **********************************************************************/


// fill the view with the value of the current property
- (void)redrawValueTextView {
    NSLog(@"[PolymakeObjectController redrawValueTextField] called");
	
    // determine which property we want to display
	id selectedItem = [_propertyView itemAtRow:[_propertyView selectedRow]];
	
		// get the property
	if ( selectedItem != nil ) {
		PolymakeObjectPropertyTreeNode * propNode = (PolymakeObjectPropertyTreeNode *)selectedItem;
        [_propertyTypeField setStringValue:[propNode propertyType]];
        [_currentPropertyName setStringValue:[propNode propertyName]];
		if ( [[propNode value] isEmpty] ) {
		  _currentPropertyValue = [[NSString alloc] initWithString:@"<empty property>"];
		} else {
			if ( [propNode isLeaf] ) {
                NSString * proptemp = [[NSString alloc] initWithString:[[propNode value] dataWithAlignedColumns:_alignedColumns]];
                NSLog(@"[PolymakeObjectController redrawValueTextView] setting prop:%@", proptemp);
                _currentPropertyValue = [[NSString alloc] initWithString:proptemp];
                [proptemp release];
			} else {
				_currentPropertyValue = [[NSString alloc] initWithString:@"<select a sub-property>"];
			}
		}
		[_valueTextView setString:_currentPropertyValue];
	} else {  // okay, nothing is selected, so clear the view
		NSString * attrString = [[NSString alloc] initWithString:@"<empty>"];
		_currentPropertyValue = [[NSString alloc] initWithString:attrString];
		[_valueTextView setString:attrString];
        [_propertyTypeField setStringValue:@""];
		[attrString release];
	}
	
}


	// just a wrapper that accepts a notification and ignores it
- (void)redrawValueTextViewWrapper:(NSNotification *)aNotification {
    NSLog(@"[PolymakeObjectController redrawValueTextViewWrapper] called");
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

/****************/
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tv {
    
    if ( tv == _creditTable ) {
        NSLog(@"[PolymakeObjectController numberOfRowsInTableView] called");
        if ( _polyObj != nil )
            return [[_polyObj credits] count];
    }
    
    if ( tv == _databaseTableView ) {
        NSLog(@"[PolymakeObjectController numberOfRowsInTableView] called dor database");
        return [[_polyObj databaseInfo] count];
    }
	
		// default return 0
	return 0;
}

/****************/
- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger) row {
    NSLog(@"[PolymakeObjectController tableView ObjectValueTableColumn column row] called");
    
    if ( tv == _creditTable ) {
        NSLog(@"[PolymakeObjectController tableView ObjectValueTableColumn column row] called for credits");
        NSString * value = [NSString stringWithString:(NSString *)[[[_polyObj credits] allKeys] objectAtIndex:row]];
        return value;
    }
    
    if ( tv == _databaseTableView ) {
        NSLog(@"[PolymakeObjectController tableView ObjectValueTableColumn column row] called for database");
        if ( [[column identifier]  isEqual: @"label"]) {
            NSString *key = [[[_polyObj databaseInfo] allKeys] objectAtIndex:row];
            return key;
        } else {
            NSString *key = [[[_polyObj databaseInfo] allKeys] objectAtIndex:row];
            NSString * value = [NSString stringWithString:(NSString *)[[_polyObj databaseInfo] objectForKey:key]];
            return value;
        }
    }
    
    return nil;
}


/****************/
- (void)tableView:(NSTableView *)tv setObjectValue:(id)item forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    NSLog(@"[PolymakeObjectController tableView setObjectvalue forTableColumn row] called");

    if ( tv == _creditTable ) {
        item = [NSString stringWithString:(NSString *)[[[_polyObj credits] allKeys] objectAtIndex:row]];
    }
    
}

/****************/
- (void) tableViewSelectionDidChange: (NSNotification *) notification {
    NSLog(@"[PolymakeObjectController tableViewSelectionDidChange] called");

    if ( [notification object] == _creditTable ) {
        
        int row = [_creditTable selectedRow];
        
        if ( row != -1 ) {
            NSArray * allValues = [[_polyObj credits] allValues];
            NSString * value = [[NSString alloc] initWithString:(NSString *)[allValues objectAtIndex:row]];
            [_creditView setString:value];
            [value release];
        }
    }
    
} 


	// this just sets the background color
-(void)tableView:(NSTableView *)tv willDisplayCell:(id)item forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    NSLog(@"[PolymakeObjectController tableView willDisplayCell for TableColumn row] called");
    
        if ( [tv selectedRow] == row )
            [item setBackgroundColor:[NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1]];
        else
            [item setBackgroundColor:[NSColor colorWithCalibratedRed:0.8 green:0.41 blue:0.14 alpha:1]];
}


@end
