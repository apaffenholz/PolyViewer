/***********************************************************************
 * Created by Andreas Paffenholz on 04/21/12.
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
 * ValueLineNumberView.m
 * PolyViewer
 **************************************************************************/

#import <Cocoa/Cocoa.h>

#define ROW_NUMBERS_DEFAULT_MIN_DIGITS					2
#define ROW_NUMBERS_DEFAULT_MARGIN							5.0
#define ROW_NUMBERS_DEFAULT_SEP_LINE_WIDTH      1

@interface ValueLineNumberView : NSRulerView {

		// entry at position i contains the index of the character of the text 
		// in the associated NSTextView that is at the beginning of row i
	NSMutableArray *_rowStartIndices;
	BOOL _rowStartIndicesValid;
	NSDictionary   *_fontAttributes;
	
	NSFont         *_rulerFont;
	NSColor				 *_rulerTextColor;
	NSColor				 *_rulerAlternateTextColor;
	NSColor				 *_rulerBackgroundColor;
}

- (id)initWithScrollView:(NSScrollView *)aScrollView;

@property (readwrite, retain) NSFont         * rulerFont;
@property (readwrite, retain) NSColor        * rulerTextColor;
@property (readwrite, retain) NSColor        * rulerAlternateTextColor;
@property (readwrite, retain) NSColor        * rulerBackgroundColor;
@property (readonly)          NSMutableArray * rowStartIndices;
@property (readwrite)         BOOL             rowStartIndicesValid;
@property (readonly)          NSDictionary   * fontAttributes;

- (void)computeRowStartIndices;
- (NSUInteger) rowNumberForPosition:(NSUInteger)pos;

@end
