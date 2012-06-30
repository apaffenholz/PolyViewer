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
#import "PropertyXMLNode.h"

NSString * const PVValueFormattingDidChangeNotification = @"PVValueFormattingDidChange";

@implementation PolymakeFile

@synthesize lastOpenDialogStartDirectory = _lastOpenDialogStartDirectory;
@synthesize polymakeObject = _polyObj;
@synthesize alignedColumns = _alignedColumns;


# pragma mark init

- (id)init {
		self = [super init];
		if (self) {
			
			_rootNode = nil;
			_polyObj = nil;
			_currentPropertyText = nil;
			_alignedColumns = NO;
			
			// the directory shown in the file open dialog
			// initially this should point to the users $HOME
			[self setLastOpenDialogStartDirectory:NSHomeDirectory()];

		
			[	[NSNotificationCenter defaultCenter] addObserver:self 
																								selector:@selector(redrawValueTextViewWrapper:) 
																										name:PVValueFormattingDidChangeNotification 
																									object:nil];
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

	// input
- (BOOL)readFromURL:(NSURL *)input ofType:(NSString *)typeName error:(NSError **)outError {
	_polyObj = [[PolymakeObject alloc] init];
	[_polyObj	initObjectWithURL:input];
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
 * formatting properties 
 **********************************************************************/

	// format a tag of type <e>
- (NSString *)formatETag:(PolymakeTag *)eTag {

	if ( [eTag isEmpty] )
		return [NSString stringWithString:@"<empty tuple>"];

	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	
	if ( [eTag hasAttributes] ) {
			// this can only be an <i> attribute containing a coordinate
			// we format this as (coord,value)
		[value appendFormat:@"(%@,", [[eTag attributes] objectForKey:@"i"]];
		for ( NSString * entry in [eTag data] )
			[value appendFormat:@"%@", entry];			
		[value appendString:@")"];
	} else {
			// the tag should just contain a single value
			// stored in the data array
		for ( NSString * entry in [eTag data] )
			[value appendFormat:@"%@ ", entry];			
	}
	
	return [NSString stringWithString:value];
}


	// format a tag of type <t> that has subtags
	// each tag element will be enclosed in  (...)
	// each subtag of <t> will be enclosed in {...}
	// FIXME we should introduce indentation to separate subtags
- (NSString *)formatTTag:(PolymakeTag *)tTag withAlignedCols:(BOOL)aligned {
	
	if ( [tTag isEmpty] )
		return [NSString stringWithString:@"<empty tuple>"];
	
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];

	[value appendString:@"(\n"];
	for ( PolymakeTag * entry in [tTag data] ) {
		
		switch ( [entry type] ) {

			case PVVTag:
				if ( aligned ) 
					[value appendFormat:@"  <%@>\n", [self formatVTag:entry withColumnAlignment:[tTag columnWidths]]];
				else 
					[value appendFormat:@"  <%@>\n", [self formatVTag:entry withColumnAlignment:nil]];
				break;

			case PVETag:
				[value appendFormat:@"  <%@>\n", [self formatETag:entry]];
				break;

			case PVTTag:
				if ( aligned ) 
					[value appendFormat:@"  %@\n", [self formatTTag:entry 
																			withColumnAlignment:[tTag columnWidths] 
																							subTagStart:@"<" subTagEnd:@">" andEntrySeparator:@" "]];
				else 
					[value appendFormat:@"  %@\n", [self formatTTag:entry 
																			withColumnAlignment:nil
																							subTagStart:@"<" subTagEnd:@">" andEntrySeparator:@" "]];
				break;

			case PVMTag:
				if ( aligned ) 
					[value appendFormat:@"  <%@>\n", [self formatMTag:entry withAlignedCols:aligned subTagStart:@"{" subTagEnd:@"}" andEntrySeparator:@", "]];
				else 
					[value appendFormat:@"  <%@>\n", [self formatMTag:entry withAlignedCols:aligned subTagStart:@"{" subTagEnd:@"}" andEntrySeparator:@", "]];
				break;

			default:
				break;
		}
		
	}  // end of loop over tTag data
	[value appendString:@")\n"];		
	return [NSString stringWithString:value];
}
	

	// format a <t> tag that has a string array as data
- (NSString *)formatTTag:(PolymakeTag *)tTag 
		 withColumnAlignment:(NSArray *)columnWidths 
						 subTagStart:(NSString *)subStart 
							 subTagEnd:(NSString *)subEnd 
			 andEntrySeparator:(NSString *)entrySep {
	
	if ( [tTag isEmpty] )
		return [NSString stringWithString:@"<empty tuple>"];
	
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	
	
	if ( columnWidths != nil ) {
		for ( unsigned i = 0; i < [[tTag data] count]; ++i ) {
			NSString * format = [NSString stringWithFormat:@"%%%ds", [[columnWidths objectAtIndex:i] intValue]+1];
				[value appendFormat:format, [[[tTag data] objectAtIndex:i] UTF8String]];
			}
 } else {
	 if ( [tTag hasAttributes] ) { // we assume that we have found a sparse representation of a QuadraticExtension
		 [value appendFormat:@"(%@,", [[tTag attributes] objectForKey:@"i"]];
		 BOOL first = YES;
		 for ( NSString * entry in [tTag data] ) {
			 if ( first ) { 
				 first = NO;
	 			 [value appendFormat:@"%@%@", subStart, entry];			
			 } else {
			 [value appendFormat:@"%@%@", entrySep, entry];			
			 }
		 }
		 [value appendFormat:@"%@)",subEnd];		 
	 } else {
		BOOL first = YES;
		for ( NSString * entry in [tTag data] ) 
			if ( first ) { 
				first = NO;
				[value appendFormat:@"%@%@", subStart, entry];			
			} else {
				[value appendFormat:@"%@%@", entrySep, entry];			
			}
		[value appendFormat:@"%@", subEnd];		 
	 }
 }
	return [NSString stringWithString:value];
}
	

	// format an <m> tag 
	// according to its specification, an <m> tag can only have PolymakeTags as children, no strings
	// the PolymakeTags are of type <v> (maybe sparse), <m>, or <t>
- (NSString *)formatMTag:(PolymakeTag *)mTag withAlignedCols:(BOOL)aligned 
						 subTagStart:(NSString *)stStart 
							 subTagEnd:(NSString *)stEnd  
			 andEntrySeparator:(NSString *)separator {
	
	if ( [mTag isEmpty] )
		return [NSString stringWithString:@"<empty matrix>"];
		
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	BOOL first = YES;
	for ( PolymakeTag * entry in [mTag data] ) {
		switch ( [entry type] ) {
			case PVVTag:
				if ( aligned ) {
					if ( first ) {
						first = NO;
						[value appendFormat:@"%@%@%@", stStart, [self formatVTag:entry withColumnAlignment:[mTag columnWidths]], stEnd];
					} else {
						[value appendFormat:@"%@%@%@%@", separator, stStart, [self formatVTag:entry withColumnAlignment:[mTag columnWidths]], stEnd];					
					}
				} else {
					if ( first )	{
						first = NO;
						[value appendFormat:@"%@%@%@", stStart, [self formatVTag:entry withColumnAlignment:nil], stEnd];
					} else {
						[value appendFormat:@"%@%@%@%@", separator, stStart, [self formatVTag:entry withColumnAlignment:nil], stEnd];
					}
				}
				break;
		
			case PVMTag: 
				if ( first ) {
					first = NO;
					[value appendFormat:@"%@%@%@", stStart, [self formatMTag:entry withAlignedCols:aligned subTagStart:@"" subTagEnd:@"" andEntrySeparator:@"\n"], stEnd];
				} else {
					[value appendFormat:@"%@%@%@%@", separator, stStart, [self formatMTag:entry withAlignedCols:aligned subTagStart:@"" subTagEnd:@"" andEntrySeparator:@"\n"], stEnd];
				}
				break;
				
			case PVTTag:
				if ( [entry hasSubTags] ) {
					if ( first ) {
						first = NO;
						[value appendFormat:@"%@%@%@", stStart, [self formatTTag:entry withAlignedCols:aligned],stEnd];				
					} else {
						[value appendFormat:@"%@%@%@%@", separator, stStart, [self formatTTag:entry withAlignedCols:aligned],stEnd];									
					}
				} else {
					if ( aligned ) {
						if ( first ) {
							first = NO;
							[value appendFormat:@"%@%@%@", stStart, [self formatTTag:entry
																									 withColumnAlignment:[mTag columnWidths]
																													 subTagStart:@"" 
																														 subTagEnd:@"" 
																										 andEntrySeparator:@""], stEnd];
						} else {
							[value appendFormat:@"%@%@%@%@", separator, stStart, [self formatTTag:entry
																																withColumnAlignment:[mTag columnWidths]
																																				subTagStart:@"" 
																																					subTagEnd:@"" 
																																	andEntrySeparator:@""], stEnd];
						}
					} else {
						if ( first ) {
							first = NO;					
							[value appendFormat:@"%@%@%@", stStart, [self formatTTag:entry 
																									 withColumnAlignment:nil 
																													 subTagStart:@"" 
																														 subTagEnd:@"" 
																										 andEntrySeparator:@""], stEnd];
						} else {
							[value appendFormat:@"%@%@%@%@", separator, stStart, [self formatTTag:entry 
																																withColumnAlignment:nil
																																				subTagStart:@"" 
																																					subTagEnd:@"" 
																																	andEntrySeparator:@""], stEnd];
						}
					}
				}
				break;
	
			default:
				break;
				
		}
	}
	
	return [NSString stringWithString:value];
}

	// format a <v> tag
	// we need to distinguish whether the tag has subtags or not
	// in the former case it is a sparse vector
- (NSString *)formatVTag:(PolymakeTag *)vTag withColumnAlignment:(NSArray *)columnWidths {

	if ( [vTag isEmpty] )
		return [NSString stringWithString:@"<empty vector>"];
	
	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	
	if ( [vTag hasSubTags] ) {   // found a sparse vector
		                           // or a Quadraticextension (that might itself be a sparse vector)
		
		for ( PolymakeTag * tag in [vTag data] ) {
			switch ( [tag type] ) {

				case PVTTag:
					[value appendFormat:@"%@ ", [self formatTTag:tag withColumnAlignment:nil 
																					 subTagStart:@"(" 
																						 subTagEnd:@")" 
																		 andEntrySeparator:@","]];
					break;
				
				case PVETag:
					[value appendFormat:@"%@ ", [self formatETag:tag]];
					break;
					
				default:
					break;
			}
		}
	} else {
		if ( columnWidths != nil )
			for ( unsigned i = 0; i < [[vTag data] count]; ++i ) {
				NSString * format = [NSString stringWithFormat:@"%%%ds", [[columnWidths objectAtIndex:i] intValue]+1];
				[value appendFormat:format, [[[vTag data] objectAtIndex:i] UTF8String]];
			}
		else
			for ( NSString * entry in [vTag data] )
				[value appendFormat:@"%@ ", entry];
	}

	
	return [NSString stringWithString:value];
}


	// the basic formmating function called by the textview 
	// formats the whole property
- (NSString *)formatPropertyNodeValue:(NSArray *)tvalue withAlignedCols:(BOOL)aligned {

	NSMutableString * value = [[[NSMutableString alloc] init] autorelease];
	
	for ( PolymakeTag * ptag in tvalue ) {
	  switch ( [ptag type] ) {
				
			case PVVTag:
				[value appendString:[self formatVTag:ptag withColumnAlignment:nil]]; 
				break;

			case PVMTag:
				[value appendString:[self formatMTag:ptag withAlignedCols:aligned  subTagStart:@"" subTagEnd:@"" andEntrySeparator:@"\n"]]; 
				break;

			case PVTTag:
				[value appendString:[self formatTTag:ptag withColumnAlignment:nil  
																 subTagStart:@"" 
																	 subTagEnd:@"" 
													 andEntrySeparator:@""]];
				break;
				
			default:
				break;
		}
	}
	
	return [NSString stringWithString:value];
}

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
		if ( [[propNode value] isEmpty] ) {
		  _currentPropertyText = [[NSString alloc] initWithString:@"<empty property>"];	
		} else {
			if ( [propNode isLeaf] ) {
				if ( [propNode hasValue] )
					_currentPropertyText = [[NSString alloc] initWithString:[[propNode value] objectAtIndex:0]];
				else
					_currentPropertyText = [[NSString alloc] initWithString:[self formatPropertyNodeValue:[[propNode value] data] withAlignedCols:_alignedColumns]];
			} else {
				_currentPropertyText = [[NSString alloc] initWithString:@"<select a sub-property>"];
			}
		}
		[_valueTextView setString:_currentPropertyText];
	} else {  // okay, nothing is selected, so clear the view
		NSString * attrString = [[NSString alloc] initWithString:@"<empty>"];
		_currentPropertyText = [[NSString alloc] initWithString:attrString];
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

/****************/
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tv {
	if ( _polyObj != nil ) 
		return [[_polyObj credits] count];
	
		// default return 0
	return 0;
}

/****************/
- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger) row {
	NSString * value = [NSString stringWithString:(NSString *)[[[_polyObj credits] allKeys] objectAtIndex:row]];
	return value;
}


/****************/
- (void)tableView:(NSTableView *)tv setObjectValue:(id)item forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
	item = [NSString stringWithString:(NSString *)[[[_polyObj credits] allKeys] objectAtIndex:row]];
}

/****************/
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
