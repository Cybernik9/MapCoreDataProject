//
//  MapPoints+CoreDataProperties.h
//  MapCoreDataProject
//
//  Created by Yurii Huber on 29.11.15.
//  Copyright © 2015 HY. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MapPoints.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapPoints (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *namePoint;

@end

NS_ASSUME_NONNULL_END
