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
 * PreferencesController.h
 * PolyViewer
 **************************************************************************/


#import "PreferencesController.h"


@implementation PreferencesController


@synthesize propertyWindowFontString = _propertyWindowFontString;



-(id)init {
    NSLog(@"[PreferencesController init] called");
	self = [super init];
	if (self) 
		_propertyWindowFontString = nil;

	return self;
}


-(void)dealloc {
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"propertyWindowFontSize"];
	[_propertyWindowFontString release];
	[super dealloc];
}




- (void)windowDidLoad {
	
	[[NSUserDefaults standardUserDefaults] addObserver:self
																					forKeyPath:@"propertyWindowFontSize"
																						 options:NSKeyValueObservingOptionNew
																						 context:nil];

		// set the font for the property values
	NSString * floatString = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"propertyWindowFontSize"];
	CGFloat floatVal = [floatString floatValue];
	NSFont * valueFont = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"textFontName"] 
																			 size:floatVal];
	[self setPropertyWindowFontString:[NSString stringWithFormat:@"%g pt %@", [valueFont pointSize], [valueFont fontName]]];		
	
	if ( valueFont != nil ) 
		[showFontButton setTitle:[self propertyWindowFontString]];
}




#pragma mark Preferences

	// preferences menu
	// FIXME there asome more things that a user should be allowed to change

- (IBAction)showFontMenu:(id)sender {
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
		//[fontManager setDelegate:_valueTextView];
	
	NSFontPanel *fontPanel = [fontManager fontPanel:YES];
	[fontPanel makeKeyAndOrderFront:sender];
}

- (void)changeFont:(id)sender {
		//NSFont *oldFont = [_valueTextView font];
	NSString * floatString = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"propertyWindowFontSize"];
	CGFloat floatVal = [floatString floatValue];
	NSFont * oldFont = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"textFontName"] 
																		 size:floatVal];
	NSFont *newFont = [sender convertFont:oldFont];
	[self setPropertyWindowFontString:[NSString stringWithFormat:@"%g pt %@", [newFont pointSize], [newFont fontName]]];
	[showFontButton setTitle:[self propertyWindowFontString]];
	[[NSUserDefaults standardUserDefaults] setValue:[newFont fontName] forKey:@"textFontName"];
	[[NSUserDefaults standardUserDefaults] setFloat:[newFont pointSize] forKey:@"propertyWindowFontSize"];
	
	return;
}


	// observe a change in the font size
	// this is used to make the font printed on the button in the preferences menu
	// aware of a font size change triggered by the slider on the main window
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ( [keyPath isEqualToString:@"propertyWindowFontSize"] ) {
		NSString * floatString = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"propertyWindowFontSize"];
		CGFloat floatVal = [floatString floatValue];
		NSFont * newFont = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"textFontName"] 
																			 size:floatVal];
		[self setPropertyWindowFontString:[NSString stringWithFormat:@"%g pt %@", [newFont pointSize], [newFont fontName]]];
		
		if ( newFont != nil ) 
			[showFontButton setTitle:[self propertyWindowFontString]];
	}
}


@end
