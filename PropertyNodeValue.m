/***********************************************************************
 * Created by Andreas Paffenholz on 18/01/14.
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
 * PolymakeNodeValue.m
 * PolyViewer
 **************************************************************************/


#import "PropertyNodeValue.h"





void splitDataType ( struct DataTypeStruct * dts, NSString * datatype ) {
    
    NSArray * comp = [datatype componentsSeparatedByString:@"<"];
    dts->name = [comp objectAtIndex:0];
    if ( [comp count] > 1 ) {
        
        NSRange start = [datatype rangeOfString:@"<"];
        NSRange templateParamRange;
        if (start.location != NSNotFound) {
            templateParamRange.location = start.location + start.length;
            templateParamRange.length = [datatype length] - templateParamRange.location;
            NSRange end = [datatype rangeOfString:@">" options:NSBackwardsSearch range:templateParamRange];
            if (templateParamRange.location != NSNotFound)
                templateParamRange.length = end.location - templateParamRange.location;
        }
        NSMutableString * templateParam = (NSMutableString *)[datatype substringWithRange:templateParamRange];
        NSMutableArray * tp = [[NSMutableArray alloc] init];

        NSRange splitFurther = [templateParam rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<,"]];
        if ( splitFurther.location != NSNotFound ) {
            NSMutableArray * tmsplit = [[NSMutableArray alloc] init];
            int paren=0;
            NSRange searchRange;
            searchRange.location=0;
            searchRange.length=[templateParam length];
            BOOL end = NO;
            while ( !end ) {
                NSRange splitFurther = [templateParam rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<>,"] options:0 range:searchRange];
                if ( splitFurther.location != NSNotFound) {
                    // FIXME
                    // the following is a weird way to determine whether the character we found is a comma,
                    // but all previous attempts ended with a bad access error
                    // the same construction appears for < and > below
                    if ( [[NSCharacterSet characterSetWithCharactersInString:@","] characterIsMember:[templateParam characterAtIndex:splitFurther.location]] ) {
                        if ( paren == 0 ) {
                            NSRange sub;
                            sub.location = 0;
                            sub.length = splitFurther.location;
                            [tmsplit addObject:[templateParam substringWithRange:sub]];
                            templateParam = (NSMutableString *)[templateParam substringFromIndex:sub.length+1];
                            searchRange.location=0;
                            searchRange.length=[templateParam length];
                        } else {
                            searchRange.location=splitFurther.location+1;
                            searchRange.length=searchRange.length-splitFurther.location-1;
                        }
                    }
                    if ( [[NSCharacterSet characterSetWithCharactersInString:@"<"] characterIsMember:[templateParam characterAtIndex:splitFurther.location]] ) {                               searchRange.location=splitFurther.location+1;
                        searchRange.length=searchRange.length-splitFurther.location-1;
                        ++paren;
                    }
                    if ( [[NSCharacterSet characterSetWithCharactersInString:@">"] characterIsMember:[templateParam characterAtIndex:splitFurther.location]] ) {
                        searchRange.location=splitFurther.location+1;
                        searchRange.length=searchRange.length-splitFurther.location-1;
                        --paren;
                    }
                } else {
                    end = YES;
                    [tmsplit addObject:templateParam];
                }
            }
            for ( id st in tmsplit ) {
                struct DataTypeStruct dst_tmp;
                splitDataType(&(dst_tmp), st);
                [tp addObject:[NSValue value:&dst_tmp withObjCType:@encode(struct DataTypeStruct)]];
            }
        } else {
            // no comma and no < means we have a single template param without any template params left.
            [tp addObject:templateParam];
        }
        [tp retain];
        dts->templateParameters = tp;
    } else {
        dts->templateParameters = nil;
    }
}

@implementation PropertyNodeValue

@synthesize data          = _data;
@synthesize dataType      = _dataType;
@synthesize isEmpty       = _isEmpty;


- (void) dealloc {
    [_data dealloc];
    [_dataType dealloc];
    [super dealloc];
}


- (id) init {
    NSLog(@"[PropertyNodeValue init] called");
    self = [super init];
    if ( self ) {
        _data     = nil;
        _dataType = nil;
        _isEmpty  = YES;
    }
    
    return self;
}

- (id) initWithValue:(NSString *)value
              ofType:(NSString *)type {
    NSLog(@"[PropertyNodeValue initWIthValue of Type] called with type %@", type);
    self = [super init];
    if ( self ) {
        
        _data = [value retain];
        _dataType = [type retain];
        splitDataType(&(_dataTypeStructure), _dataType);
        NSLog(@"[PropertyNodeValue] initWithValue dataType and TemplateArg is %@ and %@",_dataTypeStructure.name,_dataTypeStructure.templateParameters);
        if ( [_data length] == 0 )
            _isEmpty = YES;
        else
            _isEmpty = NO;
        
    }
    
    return self;
}


- (NSString *) data {
    
    if ( [_dataType isEqualToString:@"Matrix"] ) {
        
        return [_data stringByReplacingOccurrencesOfString:@"\n" withString:@"\n"];
    } else
        return _data;
    
}

- (void) setData:(NSString *)inputData {
    _data = [inputData retain];
}

@end
