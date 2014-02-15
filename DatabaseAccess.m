//
//  DatabaseAccess.m
//  PolyViewer
//
//  Created by Andreas Paffenholz on 08/02/14.
//
//

#import "DatabaseAccess.h"
#import "AppController.h"

@implementation DatabaseAccess
    
@synthesize database = _database;
@synthesize collection = _collection;
@synthesize ID = _ID;
@synthesize databases = _databases;
@synthesize collections = _collections;
@synthesize reportNumberOfResults = _reportNumberOfResults;
@synthesize amount = _amount;
@synthesize skip = _skip;
    
    
    /***************************************************************/
-(id) init {
    NSLog(@"[DatabaseAccess init] called");
    self = [super init];
    if ( self ) {
        _databases = [[[NSApp delegate] databaseNames] retain];
        [self setSkip:@"0"];
        [self setAmount:@"10"];
    }
    return self;
}
    
    
    /***************************************************************/
- (IBAction)updateAdditionalPropertiesDict:(id)sender {
    NSLog(@"[DatabaseAccess updateAdditionalPropertiesDict] recieved: %@", sender);
    
    NSString * props = [sender stringValue];
    NSLog(@"[DatabaseAccess updateAdditionalPropertiesDict] extracted props: %@", props);
    
    NSMutableDictionary *propDict = [[NSMutableDictionary alloc] init];
    if ( [props length] > 0 ) {
        NSArray *objects = [props componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=,"]];
        
        NSLog(@"[DatabaseAccess updateAdditionalPropertiesDict] additional properties as array: %@", objects);
        
        for (int i=0; i<[objects count]; i=i+2) {
            [propDict setObject:[objects[i+1] stringByReplacingOccurrencesOfString:@">" withString:@""] forKey:[objects[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
        }
    }
    _additionalPropertiesDict = [propDict retain];
    NSLog(@"[DatabaseAccess updateAdditionalPropertiesDict] additional properties as dict: %@", _additionalPropertiesDict);
}

    
    /***************************************************************/
- (NSString *) additionalPropertiesAsString {
    
    NSLog(@"[DatabaseAccess additionalPropertiesAsString] entering, current dict is: %@", _additionalPropertiesDict);
    NSString * props = [[NSString alloc] init];
    
    for ( NSString *prop in [_additionalPropertiesDict allKeys] ) {
        props = [props stringByAppendingFormat:@"\"%@\"=>%@,",prop,[_additionalPropertiesDict objectForKey:prop]];
    }
    
    if ([props length] > 0) {
        props = [props substringToIndex:[props length] - 1];
    }
    
    NSLog(@"[DatabaseAccess additionalPropertiesAsString] returning: %@", props);
    return props;
}
    
    
    /***************************************************************/
- (NSInteger)queryDBwithDatabase:db andCollection:coll {
    
    NSLog(@"[DatabaseAcces queryDBwithDatabase: andCollection:] selected database: %@ and collection: %@", db, coll);
    
    NSInteger count = 0;
    
    if ( [coll length] != 0 && coll != NULL && coll != nil )
        count = [[NSApp delegate] countForDatabase:db
                                     andCollection:coll
                           withAddtionalProperties:[self additionalPropertiesAsString]];
    
    return count;
}
    

    /***************************************************************/
- (NSArray *)getIDsForDatabase:db andCollection:coll {

    _IDs = [[NSApp delegate] idsForDatabase:db
                              andCollection:coll
                    withAddtionalProperties:[self additionalPropertiesAsString]
                           restrictToAmount:[[self amount] intValue]
                                 startingAt:[[self skip] intValue]];
    
    return _IDs;
}
    
@end
