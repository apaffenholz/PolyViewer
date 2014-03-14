//
//  DatabaseAccess.h
//  PolyViewer
//
//  Created by Andreas Paffenholz on 08/02/14.
//
//

#import <Foundation/Foundation.h>

@interface DatabaseAccess : NSObject {
    
    
    NSString * _reportNumberOfResults;
    
    // A dictionary that contains additional restrictions for the database search
    // in the form of property-value pairs.
    // passed to polymake as hash in the form "property=>value"
    NSDictionary * _additionalPropertiesDict;
    
    // the max number of elements retrieved from the database
    // passed to polymake as "limit=><amount>"
    NSString * _amount;
    
    // the number of elements of the query skipped from the beginning
    // passed to polymake in the form "skip=><skip>"
    NSString * _skip;
    
    // the list of available databases
    NSArray  * _databases;
    // the currently chosen database
    NSString * _database;
    
    // the list of collections in the currently chosen database
    NSArray  * _collections;
    // the currently chosen collection
    NSString * _collection;

    // the list of IDs retrieved with given amount and skip
    NSArray  * _IDs;
    // the selected ID
    NSString * _ID;
    
}

- (IBAction)updateAdditionalPropertiesDict:(id)sender;
- (NSString *) additionalPropertiesAsString;
- (NSInteger)queryDBwithDatabase:db andCollection:coll;
- (NSArray *)getIDsForDatabase:db andCollection:coll;


// synthesized class variables
@property (readwrite,copy)   NSArray  * databases;
@property (readwrite,copy)   NSArray  * collections;
@property (readwrite,copy)   NSArray  * IDs;
@property (readwrite,copy)   NSString * database;
@property (readwrite,copy)   NSString * collection;
@property (readwrite,copy)   NSString * ID;
@property (readwrite,copy)   NSString * reportNumberOfResults;
@property (readwrite,retain) NSString * skip;
@property (readwrite,copy)   NSString * amount;
    

@end
