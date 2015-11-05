//
//  ViewController.m
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotation.h"

@interface MapViewController ()

@property (strong, nonatomic) NSMutableArray* mapPointArray;

@end

@implementation MapViewController

//static NSMutableArray* mapPointArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MapPoints"];
    self.mapPointArray = [[managedObjectContext executeFetchRequest:fetchRequest
                                                               error:nil] mutableCopy];
    
    [self createMap];
}

#pragma mark - Core Data -

- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

#pragma mark - My metods -

- (void)createMap {
    
    for (int i=0; i<[self.mapPointArray count]; i++) {
        
        NSManagedObject *mapPoint = [self.mapPointArray objectAtIndex:i];
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[mapPoint valueForKey:@"latitude"] doubleValue];
        coordinate.longitude = [[mapPoint valueForKey:@"longitude"] doubleValue];
        
        annotation.coordinate = coordinate;
        annotation.title = [mapPoint valueForKey:@"namePoint"];
        annotation.subtitle = [NSString stringWithFormat:@"%@, %@",
                               [mapPoint valueForKey:@"latitude"],
                               [mapPoint valueForKey:@"longitude"]];
        
        [self.mapView addAnnotation:annotation];
    }
    
    
    //[mapPointArray  addObjectsFromArray:array];
}

@end
