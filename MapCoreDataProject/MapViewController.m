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

static bool isLongPress;

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
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MapPoints"];
    self.mapPointArray = [[managedObjectContext executeFetchRequest:fetchRequest
                                                              error:nil] mutableCopy];
    
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
}

#pragma - Action -

- (IBAction)actionZoom:(id)sender {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static double delta = 20000;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:YES];
}

- (IBAction)actionChangeMapType:(id)sender {
    
    static bool isMapType = YES;
    
    if (isMapType) {
        self.mapView.mapType = MKMapTypeHybrid;
        isMapType = NO;
        [self.mapMypeButton setTitle:@"Map" forState:UIControlStateNormal];
    } else {
        self.mapView.mapType = MKMapTypeStandard;
        isMapType = YES;
        [self.mapMypeButton setTitle:@"Hybrid" forState:UIControlStateNormal];
    }
}

- (IBAction)actionAddPoint:(id)sender {
    
    isLongPress = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.mapView addGestureRecognizer:longPress];
    //[longPress release];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateEnded && isLongPress) {
        NSLog(@"Long Press");
        
        isLongPress = NO;
        
        CGPoint touchPoint = [gesture locationInView:self.mapView];
        CLLocationCoordinate2D location =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        NSLog(@"Location found from Map: %f %f",location.latitude,location.longitude);
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Enter city"
                                              message:[NSString stringWithFormat:@"With coordinates:\n%f %f",
                                                       location.latitude,location.longitude]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        //Adds a text field to the alert box
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"city", @"Сity");
         }];
        
        [self presentViewController:alertController animated:YES completion:nil];
        //Creates a button with actions to perform when clicked
        UIAlertAction *saveAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Save",@"Save Action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         //Stores what has been inputted into the NSString Fullname

                                         UITextField * textField = alertController.textFields.firstObject;
                                         
                                         NSManagedObjectContext *context = [self managedObjectContext];
                                         NSManagedObject *newMapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MapPoints"
                                                                                                      inManagedObjectContext:context];
                                         
                                         [newMapPoint setValue:textField.text forKey:@"namePoint"];
                                         [newMapPoint setValue:[NSNumber numberWithDouble:location.latitude] forKey:@"latitude"];
                                         [newMapPoint setValue:[NSNumber numberWithDouble:location.longitude] forKey:@"longitude"];
                                         
                                         NSError *error = nil;
                                         
                                         if (![context save:&error]) {
                                             
                                             NSLog(@"error: %@ %@", error, [error localizedDescription]);
                                         }

                                         [self createMap];
                                     }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action) {
                                     }];
        
        [alertController addAction:saveAction];
        [alertController addAction:cancelAction];
    }
}

@end
