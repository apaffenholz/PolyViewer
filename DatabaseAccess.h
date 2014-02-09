//
//  DatabaseAccess.h
//  PolyViewer
//
//  Created by Andreas Paffenholz on 08/02/14.
//
//

#import <Foundation/Foundation.h>

@interface DatabaseAccess : NSObject {
    
    NSString * _database;
    NSString * _collection;
    NSString * _ID;
    
    NSString * _reportNumberOfResults;
    NSString * _additionalProperties;
    
    NSDictionary * _additionalPropertiesDict;
    NSString * _amount;
    NSString * _skip;
    
    NSArray  * _databases;
    NSArray  * _collections;
    NSArray  * _IDs;
    
}

@property (readwrite,copy) NSArray * databases;
@property (readwrite,copy) NSArray * collections;
@property (readwrite,copy) NSString * database;
@property (readwrite,copy) NSString * collection;
@property (readwrite,copy) NSString * ID;
@property (readwrite,copy) NSString * reportNumberOfResults;
@property (readwrite,retain) NSString * skip;
@property (readwrite,copy) NSString * amount;
    
- (IBAction)updateAdditionalPropertiesDict:(id)sender;
- (NSString *) additionalPropertiesAsString;
    
@end
