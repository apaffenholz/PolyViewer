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


- (id)initWithPolymakeObject:(PolymakeObjectWrapper *)polyObj andProperty:(NSString *)prop {
    NSLog(@"[PolymakeObjectWrapper initWithPolymakePerlObject andProperty] entering with prop %@", prop);

	self = [super init];
    p = polyObj->p.CallPolymakeMethod("give",[prop UTF8String]);
    
    NSLog(@"[PolymakeObjectWrapper initWithPolymakePerlObject andProperty] leaving");
	return self;
}


- (NSString *)getObjectType {
    NSLog(@"[PolymakeObjectWrapper getObjectType] entering");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_type" ofType:@"pl"];
    NSString *objectType = [[NSString alloc] initWithCString:CallPolymakeFunction("script",[filePath UTF8String],p) encoding:NSUTF8StringEncoding];

    NSLog(@"[PolymakeObjectWrapper getObjectType] returning");
    return objectType;
}

    
- (NSString *)getObjectName {
    NSLog(@"[PolymakeObjectWrapper getObjectName] entering");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_name" ofType:@"pl"];
    NSString *objectName = [[NSString alloc] initWithCString:CallPolymakeFunction("script",[filePath UTF8String],p) encoding:NSUTF8StringEncoding];

    NSLog(@"[PolymakeObjectWrapper getObjectName] returning name: %@", objectName);
    return objectName;
}

    
- (NSString *)getObjectDescription {
    NSLog(@"[PolymakeObjectWrapper getObjectDescription] entering");

    NSString *objectDescr = [[NSString alloc] initWithCString:p.CallPolymakeMethod("description") encoding:NSUTF8StringEncoding];

    NSLog(@"[PolymakeObjectWrapper getObjectDescription] returning");
    return objectDescr;
}

    
- (NSString *)getProperty:(NSString *)name {
    NSLog(@"[PolymakeObjectWrapper getProperty] called for name %@",name);
    
    NSString * property = [[NSString alloc] initWithCString:p.give([name cStringUsingEncoding:NSUTF8StringEncoding])
                                                   encoding:NSUTF8StringEncoding];
    
    NSLog(@"[PolymakeObjectWrapper getProperty] returning");
    return property;
}
    

- (PolymakeObjectWrapper *)getSubobject:(NSString *)name {
    NSLog(@"[PolymakeObjectWrapper getSubobject] called for name %@",name);
    
    PolymakeObjectWrapper * sub = [[PolymakeObjectWrapper alloc] initWithPolymakeObject:self andProperty:name];

    NSLog(@"[PolymakeObjectWrapper getSubobject] returning");
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
        
        NSLog(@"%s -- is an object: %d   --- is multiple: %d",prop.first.c_str(),prop.second[0],prop.second[1]);
    }
    
    [props retain];
    
    NSLog(@"[PolymakeObjectWrapper getPropertyListAtRootLevel] leaving");
    return props;
}

@end
