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
 * PolymakeInstanceWrapper.h
 * PolyViewer
 **************************************************************************/

#import <Foundation/Foundation.h>

@interface PolymakeInstanceWrapper : NSObject

- (id)init;
- (void)createScope;

-(NSArray *)databaseNames;
-(NSArray *)collectionNamesofDatabase:(NSString *)db;
    -(NSArray *)idsForDatabase:(NSString *)db
                 andCollection:(NSString *)coll
       withAddtionalProperties:(NSString *)additionalProps
              restrictToAmount:(NSNumber *)amount
                    startingAt:(NSNumber *)start;

-(NSInteger)countForDatabase:(NSString *)db
               andCollection:(NSString *)coll
     withAddtionalProperties:(NSString *)additionalProps;
    
-(NSArray *)configuredExtensions;
- (void)showCommandFailedAlert:(NSString *)reason;
@end
