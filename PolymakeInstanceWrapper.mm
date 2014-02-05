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
 * PolymakeInstanceWrapper.mm
 * PolyViewer
 **************************************************************************/


#import "PolymakeInstanceWrapper.h"
#import "polymake/Main.h"
#import "polymake/Matrix.h"
#import "polymake/Array.h"
#import "polymake/Set.h"
#import "polymake/SparseMatrix.h"
#import "polymake/Rational.h"

@interface PolymakeInstanceWrapper () {
    
    polymake::Main pm_instance;
    
}
@end

@implementation PolymakeInstanceWrapper

- (id)init {
	NSLog(@"[PolymakeInstanceWrapper init] entering");

	self = [super init];

    NSLog(@"[PolymakeInstanceWrapper init] leaving");
	return self;
}

- (void)createScope {
	NSLog(@"[PolymakeInstanceWrapper createScope] entering");

    polymake::perl::Scope main_polymake_scope(polymake::perl::Scope(pm_instance.newScope()));
    pm_instance.set_application("common");

	NSLog(@"[PolymakeInstanceWrapper createScope] leaving");
}

-(NSArray *)databaseNames {
    NSLog(@"[PolymakeInstanceWrapper databaseNames] entering");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_db_list" ofType:@"pl"];
    polymake::perl::ListResult results = ListCallPolymakeFunction("script",[filePath UTF8String]);
    
    NSMutableArray * databases = [NSMutableArray array];
    for (int i=0, end=results.size(); i<end; ++i) {
        NSLog(@"[PolymakeInstanceWrapper databaseNames] in loop");
        std::string dbstring = results[i];
        NSString * db = [[NSString alloc] initWithCString:dbstring.c_str() encoding:NSUTF8StringEncoding];
        [databases addObject:db];
    }

    NSLog(@"[PolymakeInstanceWrapper databaseNames] leaving");
    return databases;
}

-(NSArray *)collectionNamesofDatabase:(NSString *)db {
    NSLog(@"[PolymakeInstanceWrapper collectionNamesofDatabase] entering");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"get_db_collection_list" ofType:@"pl"];
    polymake::perl::ListResult results = ListCallPolymakeFunction("script",[filePath UTF8String],[db cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSLog(@"[PolymakeInstanceWrapper collectionNamesofDatabase] found %d results", results.size());
    NSMutableArray * collections = [NSMutableArray array];
    for (int i=0, end=results.size(); i<end; ++i) {
        std::string collstring = results[i];
        NSLog(@"[PolymakeInstanceWrapper collectionNamesofDatabase] in loop, adding %s", collstring.c_str());
        NSString *  coll = [[NSString alloc] initWithCString:collstring.c_str() encoding:NSUTF8StringEncoding];
        [collections addObject:coll];
    }
    
    NSLog(@"[PolymakeInstanceWrapper collectionNamesofDatabase] leaving");
    return collections;
}


@end
