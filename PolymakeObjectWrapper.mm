/***********************************************************************
 * Created by Andreas Paffenholz on 01/07/14.
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
 * PolymakeObjectWrapper.mm
 * PolyViewer
 **************************************************************************/

#import "PolymakeObjectWrapper.h"

#import "polymake/Main.h"
#import "polymake/Matrix.h"
#import "polymake/Array.h"
#import "polymake/Set.h"
#import "polymake/SparseMatrix.h"
#import "polymake/Rational.h"

#import "PropertyNode.h"



@interface PolymakeObjectWrapper () {

    polymake::perl::Object p;
    
}
@end



@implementation PolymakeObjectWrapper


- (void)initWithPolymakeInstance:(PolymakeInstanceWrapper *)pinst
                     andPolytope:(NSString *)filename {
   
    polymake::perl::Object p = CallPolymakeFunction("load",filename);
}


    
- (id)initWithPolymakeObject:(NSString *)filename {
    NSLog(@"[PolymakeObjectWrapper initWithPolymakeObject filename] entering with filename %@", filename);
    
	self = [super init];
    p = CallPolymakeFunction("load",[filename UTF8String]);
    
    NSLog(@"[PolymakeObjectWrapper initWithPolymakeObject filename] done]");
	return self;
}

- (id)initWithPolymakeObjectFromDatabase:(NSString *)database
                           andCollection:(NSString *)collection
                                  withID:(NSString *)ID {
    NSLog(@"[PolymakeObjectWrapper initWithPolymakeObjectFromDatabase andCollection withID] entering");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"retrieve_database_object" ofType:@"pl"];
    polymake::perl::ListResult rval = ListCallPolymakeFunction("script",[filePath UTF8String],[database UTF8String],[collection UTF8String],[ID UTF8String]);

    NSString * err_string = [[NSString alloc] initWithUTF8String:rval[1]];
    NSLog(@"[PolymakeObjectWrapper initWithPolymakeObjectFromDatabase andCollection withID] checking success, error string is: %@",err_string);
    if ( [err_string length] > 0 ) {
        NSLog(@"[PolymakeObjectWrapper initWithPolymakeObjectFromDatabase andCollection withID] load failed");
        if ( [err_string rangeOfString:@"ERROR"].location != NSNotFound ) {
            if ([err_string rangeOfString:@"timed out"].location != NSNotFound) {
                [self showCommandFailedAlert:@"could not connect to database server"];
            } else if ([err_string rangeOfString:@"Unknown application"].location != NSNotFound) {
                [self showCommandFailedAlert:[NSString stringWithFormat:@"please install an extension providing the following application: \n%@",err_string]];
            } else {
                [self showCommandFailedAlert:[NSString stringWithFormat:@"an unknown error occured:\n%@", err_string]];
            }
            return nil;
        }
    }
    
    NSLog(@"[PolymakeObjectWrapper initWithPolymakeObjectFromDatabase andCollection withID] success!");
	self = [super init];
    p = rval[0];
    NSLog(@"[PolymakeObjectWrapper initWithPolymakeObjectFromDatabase andCollection withID] done]");
	return self;
}



- (id)initWithPolymakeObject:(PolymakeObjectWrapper *)polyObj andProperty:(NSString *)prop {
    NSLog(@"[PolymakeObjectWrapper initWithPolymakePerlObject andProperty] entering with prop %@", prop);

	self = [super init];
    p = polyObj->p.CallPolymakeMethod("give",[prop UTF8String]);
    
    NSLog(@"[PolymakeObjectWrapper initWithPolymakePerlObject andProperty] leaving");
	return self;
}

- (id)initWithPolymakeObject:(PolymakeObjectWrapper *)polyObj andProperty:(NSString *)prop ofIndex:(int)index {
    NSLog(@"[PolymakeObjectWrapper initWithPolymakePerlObject andProperty ofIndex] entering with prop %@ and index: %d", prop,index);
    
	self = [super init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_multiple_object_by_index" ofType:@"pl"];
    p = CallPolymakeFunction("script",[filePath UTF8String],polyObj->p,[prop UTF8String],index);
    
    NSLog(@"[PolymakeObjectWrapper initWithPolymakePerlObject andProperty ofIndex] leaving");
	return self;
}



- (NSString *)getObjectType {
    NSLog(@"[PolymakeObjectWrapper getObjectType] entering");
    
    NSString *objectType = @"";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_type" ofType:@"pl"];
    objectType = [[NSString alloc] initWithUTF8String:CallPolymakeFunction("script",[filePath UTF8String],p)];
    if ( [objectType rangeOfString:@"ERROR"].location != NSNotFound ) {
        NSLog(@"[PolymakeObjectWrapper getObjectType] perl script failed");
        objectType = @"<unable to retrieve object type>";
    }

    NSLog(@"[PolymakeObjectWrapper getObjectType] returning");
    return objectType;
}

    
- (NSString *)getObjectName {
    NSLog(@"[PolymakeObjectWrapper getObjectName] entering");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_name" ofType:@"pl"];
    NSString *objectName = [[NSString alloc] initWithUTF8String:CallPolymakeFunction("script",[filePath UTF8String],p)];

    NSLog(@"[PolymakeObjectWrapper getObjectName] returning name: %@", objectName);
    return objectName;
}

    
- (NSString *)getObjectDescription {
    NSLog(@"[PolymakeObjectWrapper getObjectDescription] entering");

    NSString *objectDescr = [[NSString alloc] initWithUTF8String:p.CallPolymakeMethod("description")];

    NSLog(@"[PolymakeObjectWrapper getObjectDescription] returning");
    return objectDescr;
}

    
- (NSString *)getProperty:(NSString *)propertyName {
    NSLog(@"[PolymakeObjectWrapper getProperty] called for propertyName %@",propertyName);
    
    NSString * property = [[NSString alloc] initWithUTF8String:p.give([propertyName cStringUsingEncoding:NSUTF8StringEncoding])
                                                   ];
    
    NSLog(@"[PolymakeObjectWrapper getProperty] returning");
    return property;
}
    

- (PolymakeObjectWrapper *)getSubobject:(NSString *)propertyName {
    NSLog(@"[PolymakeObjectWrapper getSubobject] called for propertyName %@",propertyName);
    
    PolymakeObjectWrapper * sub = [[PolymakeObjectWrapper alloc] initWithPolymakeObject:self andProperty:propertyName];

    NSLog(@"[PolymakeObjectWrapper getSubobject] returning");
    return sub;
}


- (PolymakeObjectWrapper *)getSubobjectWithIndex:(int)index andName:(NSString *)propertyName {
    NSLog(@"[PolymakeObjectWrapper getSubobjectWithIndex] called for propertyName %@",propertyName);
    
    PolymakeObjectWrapper * sub = [[PolymakeObjectWrapper alloc] initWithPolymakeObject:self andProperty:propertyName ofIndex:index];
    
    NSLog(@"[PolymakeObjectWrapper getSubobjectWithIndex] returning");
    return sub;
}

    
- (NSArray *)getPropertyListAtRootLevel {
    NSLog(@"[PolymakeObjectWrapper getPropertyListAtRootLevel] called");

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"list_props" ofType:@"pl"];
    polymake::perl::ListResult results = ListCallPolymakeFunction("script",[filePath UTF8String],p);
    
    NSMutableArray * props = [NSMutableArray array];
    for (int i=0, end=results.size(); i<end; ++i) {
        NSLog(@"[PolymakeObjectWrapper] reading props: %i",i);

        std::pair<std::string,polymake::Array<bool> > prop = results[i];
        PolymakeObjectWrapper * _prop = nil;
        
        if ( prop.second[1] == NO ) {
            if ( prop.second[0] ) {
                _prop = [[PolymakeObjectWrapper alloc] init];
                _prop = [self getSubobject:[NSString stringWithCString:prop.first.c_str() encoding:NSUTF8StringEncoding]];
            } else {
                _prop = self;
            }
            PropertyNode *propNode = [[PropertyNode alloc] initWithName: [NSString stringWithCString:prop.first.c_str() encoding:NSUTF8StringEncoding]
                                                                 andObj:_prop
                                                               asObject:(BOOL)prop.second[0]
                                                             asMultiple:prop.second[1]
                                                                 asLeaf:!(BOOL)prop.second[0]];
        
            [props addObject:propNode];
            [propNode release];
        } else {
            
            NSLog(@"[PolymakeObjectWrapper children] retrieving multiple subobject: %s",prop.first.c_str());
            filePath = [[NSBundle mainBundle] pathForResource:@"get_names_for_multiple" ofType:@"pl"];
            polymake::perl::ListResult namesOfMultiples = ListCallPolymakeFunction("script",[filePath UTF8String],p,prop.first.c_str());

            NSLog(@"[PolymakeObjectWrapper children] found %d subobjects",namesOfMultiples.size());

            for (int j=0, jend = namesOfMultiples.size(); j<jend; ++j) {
                NSLog(@"[PolymakeObjectWrapper children] working on number %d",j);

                if ( prop.second[0] ) {
                    _prop = [[PolymakeObjectWrapper alloc] init];
                    _prop = [self getSubobjectWithIndex:j
                                                andName:[NSString stringWithCString:prop.first.c_str()
                                                                           encoding:NSUTF8StringEncoding]];
                } else {
                    _prop = self;
                }
            
                NSString * propname;
                if( namesOfMultiples[j] )
                    propname = [NSString stringWithCString:namesOfMultiples[j] encoding:NSUTF8StringEncoding];
                else
                    propname = @"";
                PropertyNode *propNode = [[PropertyNode alloc] initWithName:[NSString stringWithCString:prop.first.c_str()
                                                                                               encoding:NSUTF8StringEncoding]
                                                                     andObj:_prop
                                                                  withIndex:j
                                                                   withName:propname
                                                                   asObject:(BOOL)prop.second[0]
                                                                 asMultiple:prop.second[1]
                                                                     asLeaf:!(BOOL)prop.second[0]];
            
                [props addObject:propNode];
                [propNode release];
            }
            
        }
            
  
        NSLog(@"%s -- is an object: %d   --- is multiple: %d",prop.first.c_str(),prop.second[0],prop.second[1]);
    }
    
    [props retain];
    
    NSLog(@"[PolymakeObjectWrapper getPropertyListAtRootLevel] leaving");
    return props;
}
    
    
    /***************************************************************/
- (void)showCommandFailedAlert:(NSString *)reason {
    NSAlert *alert = [NSAlert alertWithMessageText:reason
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    [alert runModal];
}

@end
