/***********************************************************************
 * Created by Andreas Paffenholz on 04/21/12.
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
 * ValueLineNumberView.h
 * PolyViewer
 **************************************************************************/

#import "ValueLineNumberView.h"

@implementation ValueLineNumberView

@synthesize fontAttributes          = _fontAttributes;
@synthesize rulerFont               = _rulerFont;
@synthesize rulerTextColor          = _rulerTextColor;
@synthesize rulerAlternateTextColor = _rulerAlternateTextColor;
@synthesize rulerBackgroundColor    = _rulerBackgroundColor;
@synthesize rowStartIndicesValid    = _rowStartIndicesValid;
@dynamic    rowStartIndices;


	/*************************************************************
	 * init etc
	 *
	 *************************************************************/
- (id)initWithScrollView:(NSScrollView *)aScrollView {
	if ((self = [super initWithScrollView:aScrollView orientation:NSVerticalRuler]) != nil) {
		
			// FIXME this should become user defaults, to be chosen in preferences
			// FIXME no fixed values in code...
		_fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
											 [self rulerFont], [NSFont systemFontOfSize:10],
											 [self rulerTextColor], [NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1], nil];		
		_rulerFont      = [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];	
		_rulerTextColor = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];

			// color is polymake yellow	
		[self setRulerBackgroundColor:[NSColor colorWithCalibratedRed:0.914 green:0.686 blue:0.227 alpha:1]];
		[self setRowStartIndicesValid:NO];
		_rowStartIndices = nil;
		
		[self setClientView:[aScrollView documentView]];
		[[NSNotificationCenter defaultCenter] addObserver:self 
																						 selector:@selector(textViewDidChange:) 
																								 name:NSTextStorageDidProcessEditingNotification 
																							 object:[(NSTextView *)[self clientView] textStorage]];
		[self setRowStartIndicesValid:NO];
		
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_rowStartIndices release];
	[_rulerFont release];
		//[_rulerTextColor release];
	
	[super dealloc];
}


/**********************************************************
 *
 * class extension
 *
 ***********************************************************/

- (NSMutableArray *)rowStartIndices {
	if ( ![self rowStartIndicesValid] ) 
		[self computeRowStartIndices];
	return _rowStartIndices;
}


	// compute the positions of the characters in the original text 
	// that are at the beginning of a row
	// store in array: row i -> index of first char in row
- (void)computeRowStartIndices {
	if ( ![self rowStartIndicesValid] ) {
		id valueView = [self clientView];
		NSString * value = [valueView string];
		unsigned valueLength = [value length];
		if ( _rowStartIndices == nil )
			[_rowStartIndices release];
		_rowStartIndices = [[NSMutableArray alloc] init];

		unsigned number = 0;
		do {
			[_rowStartIndices addObject:[NSNumber numberWithUnsignedInt:number]];
			number = NSMaxRange([value lineRangeForRange:NSMakeRange(number, 0)]);
		}
		while (number < valueLength);

			// now the rowIndices are valid again
			// have to announce this before requiredThickness is called!
		[self setRowStartIndicesValid:YES];
	
			// I thought requiredThickness would do everything
			// but apparently not. 
			// We compute this here to keep it off the actual drawing method, 
			// wich is called quite often
		CGFloat requiredWidth = [self requiredThickness];
		if (fabs( [self ruleThickness] - requiredWidth ) > 1) {
			[self setRuleThickness:requiredWidth];
		}

	 }
}

	//
	// returns for a given index pos in the text string 
	// corresponding to the line numbers
	// the row number of the row it is in
	//
- (NSUInteger)rowNumberForPosition:(NSUInteger)pos {
	
	NSUInteger index = [[self rowStartIndices] indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
		return (BOOL)((pos < [obj intValue])?YES:NO);  // for some reason the result of ?: is interpreted as an int without the cast...
	}];
	
		// we are looking from the wrong side, so it might actually be 
		// that we don't find something. This happens iff we are in the last row, so
	if ( index == NSNotFound )
		return [[self rowStartIndices] count]-1;
	
	return index-1;
}


/****************************************************************************
 *
 * methods overridden from original class
 *
 ****************************************************************************/

- (void)textViewDidChange:(NSNotification *)notification {
	[self setRowStartIndicesValid:NO];
	[self setNeedsDisplay:YES];
}

- (CGFloat)requiredThickness {
		// do some math: we need the number of digits in base 10
	NSUInteger nDigits = (NSUInteger)floor(log10([[self rowStartIndices] count])) + 1;
		// okay, lets cheat: we need the width of our number, 
		// as in bibtex, we use 8 as a placeholder for the max width of a char
		// maybe we should create a string of the proper length? are there spaces between chars?
	NSSize numberSize = [@"8" sizeWithAttributes:[self fontAttributes]];
		// the width should actually only jump if it is really necessary, so 
		// by default we want to have a bar that can cope with at least ROW_NUMBER_MIN_DIGITS digits.
	NSUInteger max = MAX(ROW_NUMBERS_DEFAULT_MIN_DIGITS,nDigits);
		// make it integer. Just to be sure
	return ceilf((max * numberSize.width) + ROW_NUMBERS_DEFAULT_MARGIN * 2);
}


- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect {
	NSRect bounds = [self bounds];
	NSTextView			* valueView     = (NSTextView *)[self clientView];
	NSLayoutManager * layoutManager = [valueView layoutManager];
	NSTextContainer * textContainer = [valueView textContainer];	
	
	NSRect  visibleRect           = [[[self scrollView] contentView] bounds];
	NSRange visibleGlyphRange     = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:textContainer];
	NSRange visibleCharacterRange = [layoutManager characterRangeForGlyphRange:visibleGlyphRange actualGlyphRange:NULL];
	NSSize  textContainerInset    = [valueView textContainerInset];        
	
	[_rulerBackgroundColor set];
	NSRectFill(bounds);
		// separate the ruler and the textview with a thin line
	[[NSColor colorWithCalibratedWhite:.2 alpha:1] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, NSMinY(bounds)) 
														toPoint:NSMakePoint(0, NSMaxY(bounds))];			
	[[NSColor colorWithCalibratedRed:0.8 green:0.41 blue:0.14 alpha:1] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(bounds) - ROW_NUMBERS_DEFAULT_SEP_LINE_WIDTH, NSMinY(bounds)) 
														toPoint:NSMakePoint(NSMaxX(bounds) - ROW_NUMBERS_DEFAULT_SEP_LINE_WIDTH, NSMaxY(bounds))];

		// record the beginning of the y-coordinates
		// so we don't have to compute this in the loop
		//
		// the origin of the textview scrolls, so we have to
		// adjust our y-position with the upper y-position of the visible area
		// further, we have to take care of the inset of our textview in the enclosing scrollview	
	CGFloat yfix = textContainerInset.height - NSMinY(visibleRect);
		// same for x position
		// the numbers should appear right aligned, so we take the total width
		// and substract the width, and add some margin
	CGFloat xfix = NSWidth(bounds) - ROW_NUMBERS_DEFAULT_MARGIN;
	
	if ( ![[[valueView textStorage] string] isEqualToString:@"\n"] ) {
			// now we loop over the visible rows
			// row starts with the first visible row, obtained by searching rowNumberForPosition
			// the loop ends if either row hits the end of the visible area, 
			// or there are no more rows to display
		NSUInteger lastRowNumber = MIN([[self rowStartIndices] count], NSMaxRange(visibleCharacterRange));
		for (unsigned row = [self rowNumberForPosition:visibleCharacterRange.location]; row < lastRowNumber; row++) {
			
			NSUInteger rowStartIndex = [[[self rowStartIndices] objectAtIndex:row] unsignedIntValue];
			if (NSLocationInRange(rowStartIndex, visibleCharacterRange)) {
				
					// we request the height of one row of the textview by
					// asking for the rectangle necessary to cover zero letters at the start position 
					// of the current row
					// (the text may be empty!)
				NSUInteger  rectCount;
				NSRectArray valueCharRect = [layoutManager rectArrayForCharacterRange:NSMakeRange(rowStartIndex, 0)
																								 withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0)
																															inTextContainer:textContainer
																																		rectCount:&rectCount];
				
				if (rectCount > 0) {
					NSString * rowNumberAsString = [NSString stringWithFormat:@"%d", row];
					NSSize rowNumberSize = [rowNumberAsString sizeWithAttributes:[self fontAttributes]];
					
					
						// the row numbers might have different size
						// we center them in the row by adding half the height difference
					CGFloat y = yfix + NSMinY(valueCharRect[0]) + (NSHeight(valueCharRect[0]) - rowNumberSize.height) / 2.0;
					
						// width and height of the required box are easier now...
					NSRect tRect = NSMakeRect(xfix - rowNumberSize.width, y, rowNumberSize.width + ROW_NUMBERS_DEFAULT_MARGIN, NSHeight(valueCharRect[0]));
					
					[rowNumberAsString drawInRect:tRect withAttributes:[self fontAttributes]];
				}
			}
		}
	}
}


@end
