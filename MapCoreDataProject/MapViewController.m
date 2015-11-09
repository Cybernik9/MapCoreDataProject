//
//  ViewController.m
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotation.h"

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray* mapPointArray;
@property (strong, nonatomic) MapAnnotation* annotation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

typedef NS_ENUM(NSUInteger, MapType) {
    
    MapTypeSatellite  = 0,
    MapTypeHybrid,
    MapTypeStandard
};

static bool isLongPress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    [CLLocationManager requestWhenInUseAuthorization];
    
    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
   
    
    // TODO: Add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
    
    // Check for iOS 8
//    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//     [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
}

// Location Manager Delegate Methods
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    NSLog(@"%@", [locations lastObject]);
//}
//
//- (void)requestAlwaysAuthorization
//{
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    
//    // If the status is denied or only granted for when in use, display an alert
//    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
//        NSString *title;
//        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
//        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
//        
//        UIAlertController *alert = [UIAlertController
//                                    alertControllerWithTitle:title
//                                    message:message
//                                    preferredStyle:UIAlertControllerStyleAlert];
//        
//        [self presentViewController:alert animated:YES completion:nil];
//    }
//    // The user has not enabled any location services. Request background authorization.
//    else if (status == kCLAuthorizationStatusNotDetermined) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self createMap];
    //[self actionSegmentedControl:self.segmentedControl];
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

#pragma mark - MKMapViewDelegate -

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {

    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        return renderer;
    }
    else if ([overlay isKindOfClass:[MKPolygon class]]) {
    
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonView.lineWidth = 2.f;
        polygonView.strokeColor = [UIColor magentaColor];
        
        return polygonView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 80000, 80000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
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
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action) {
                                       }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
    }
}

- (void) pinRoute {
    
    for (int i=0; i<[self.mapPointArray count]; i++) {
        
        NSManagedObject *mapPointStart = [self.mapPointArray objectAtIndex:i];
        
        CLLocationCoordinate2D coordinateStart;
        coordinateStart.latitude = [[mapPointStart valueForKey:@"latitude"] doubleValue];
        coordinateStart.longitude = [[mapPointStart valueForKey:@"longitude"] doubleValue];
        
        [self addRouteForAnotationCoordinate:self.mapView.userLocation.coordinate startCoordinate:coordinateStart];
    }
    
}

//Build routes

- (void) addRouteForAnotationCoordinate:(CLLocationCoordinate2D)endCoordinate startCoordinate:(CLLocationCoordinate2D)startCoordinate {
    
    MKDirections* directions;
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark* startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startCoordinate
                                                        addressDictionary:nil];
    
    MKMapItem* startDestination = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    
    request.source = startDestination;
    
    MKPlacemark* endPlacemark = [[MKPlacemark alloc] initWithCoordinate:endCoordinate
                                                      addressDictionary:nil];
    
    MKMapItem* endDestination = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    
    request.destination = endDestination;
    
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    request.requestsAlternateRoutes = YES;
    
    directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            
        } else if ([response.routes count] == 0) {
            
        } else {
            
            NSMutableArray *array  = [NSMutableArray array];
            for (MKRoute *route in response.routes) {
                [array addObject:route.polyline];
            }//magic don't touch
            [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
        }
        
    }];
    
}

- (void)removeRoutes {
    
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)createFigure {
    
    NSMutableDictionary *boundaryPoints = [[NSMutableDictionary alloc] init];
    
    CLLocationCoordinate2D *location; //= [[CLLocationCoordinate2D alloc] init];
    
    for (int i=0; i<[self.mapPointArray count]; i++) {
        
        NSManagedObject *mapPointStart = [self.mapPointArray objectAtIndex:i];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[mapPointStart valueForKey:@"latitude"] doubleValue];
        coordinate.longitude = [[mapPointStart valueForKey:@"longitude"] doubleValue];
        
        NSString *str = [NSString stringWithFormat:@"{%f,%f}", coordinate.latitude, coordinate.longitude];
        //{34.4313,-118.59890}
        
        CGPoint p = CGPointFromString(str);
        location[i] = CLLocationCoordinate2DMake[p.x, p.y];
    }
    
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:location
                                                     count:[self.mapPointArray count]];
    [self.mapView addOverlay:polygon];
}

#pragma mark - Action -

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
    
    static int mapType;
    
    switch (mapType) {
            
        case MapTypeSatellite:
            self.mapView.mapType = MKMapTypeSatellite;
            mapType++;
            [self.mapMypeButton setTitle:@"Hybrid" forState:UIControlStateNormal];
            break;
            
        case MapTypeHybrid:
            self.mapView.mapType = MKMapTypeHybrid;
            mapType++;
            [self.mapMypeButton setTitle:@"Map" forState:UIControlStateNormal];
            break;
            
        case MapTypeStandard:
            self.mapView.mapType = MKMapTypeStandard;
            mapType = 0;
            [self.mapMypeButton setTitle:@"Satellite" forState:UIControlStateNormal];;
            break;
    }
}

- (IBAction)actionAddPoint:(id)sender {
    
    isLongPress = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.mapView addGestureRecognizer:longPress];
    //[longPress release];
}

- (IBAction)actionSegmentedControl:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            NSLog(@"1");
            [self removeRoutes];
            break;
        case 1:
            NSLog(@"2");
            [self pinRoute];
            break;
        case 2:
            NSLog(@"3");
            [self removeRoutes];
            [self createFigure];
            break;
    }
}

@end
