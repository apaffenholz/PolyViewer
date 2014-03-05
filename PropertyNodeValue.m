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




// we assume that the variable datatype is of the form NAME or NAME<TEMP1,TEMP2,...>
// where TEMP1 etc may have template parameters themselves
void splitDataType ( struct DataTypeStruct * dts, NSString * datatype ) {
   
    // first check whether any template parameters are left
    NSArray * comp = [datatype componentsSeparatedByString:@"<"];
    dts->name = [[comp objectAtIndex:0] retain];
    if ( [comp count] > 1 ) {     // we do have template params
        
        NSRange start = [datatype rangeOfString:@"<"];
        NSRange templateParamRange;
        if (start.location != NSNotFound) {  // we found an opening <,  now find the corresponding >
            templateParamRange.location = start.location + start.length;
            templateParamRange.length = [datatype length] - templateParamRange.location;
            NSRange end = [datatype rangeOfString:@">" options:NSBackwardsSearch range:templateParamRange];
            if (templateParamRange.location != NSNotFound)
                templateParamRange.length = end.location - templateParamRange.location;
        }
        
        // templateParam will contain anzthing inbetween the outermost <...> pair of the input
        // we still have to split this into its pieces, i.e. we have to check for , and split at the appropriate ones
        // note that a comma may also appear within a template argument to one of the template arguments listed in templateParam
        NSMutableString * templateParam = (NSMutableString *)[datatype substringWithRange:templateParamRange];
        NSMutableArray * tp = [[NSMutableArray alloc] init];

        // check for commas, if there are none, then we have a single template argument
        NSRange splitFurther = [templateParam rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]];

        if ( splitFurther.location != NSNotFound ) {

            // we found one, now we have to split on commas not contained in <...>
            NSMutableArray * tmsplit = [[NSMutableArray alloc] init];

            // paren tells the level of parenthesis we are in
            int paren=0;
            // set up a search range, we go through the string from beginning to end finding ",","<",">"
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
                        
                        // we found a comma.
                        // we split at this comma iff we are not inside <...>
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
                    if ( [[NSCharacterSet characterSetWithCharactersInString:@"<"] characterIsMember:[templateParam characterAtIndex:splitFurther.location]] ) {
                        searchRange.location=splitFurther.location+1;
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
            // no comma  means we have a single template param
            struct DataTypeStruct dst_tmp;
            splitDataType(&(dst_tmp), templateParam);
            [tp addObject:[NSValue value:&dst_tmp withObjCType:@encode(struct DataTypeStruct)]];
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


- (NSString *) dataWithAlignedColumns:(BOOL)alignedCols {
    NSLog(@"[PropertyNodeValue dataWithAlignedColumns:] called for dts %@",_dataTypeStructure.name);
    if ( alignedCols ) {
        if ( [_dataTypeStructure.name isEqualToString:@"Matrix"] ) {
            NSValue *tp = _dataTypeStructure.templateParameters[0];
            struct DataTypeStruct dts;
            [tp getValue:&dts];
            NSLog(@"[name is] %@",dts.name);
            if ( [dts.name isEqualToString:@"Rational"] ) {
                return [_data stringByReplacingOccurrencesOfString:@"\n" withString:@"\nr: "];
            } else {
                return _data;
            }
        } else
            return _data;
    } else
        return _data;
    
}


@end
