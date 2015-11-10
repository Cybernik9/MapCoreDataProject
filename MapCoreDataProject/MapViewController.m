//
//  ViewController.m
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotation.h"
#import "UIView+MKAnnotationView.h"

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray* mapPointArray;
//@property (strong, nonatomic) MapAnnotation* annotation;
@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (strong, nonatomic) CLGeocoder* geoCoder;
//@property (weak, nonatomic) MKAnnotationView* annotationView;

@end

@implementation MapViewController

typedef NS_ENUM(NSUInteger, MapType) {
    
    MapTypeSatellite  = 0,
    MapTypeHybrid,
    MapTypeStandard
};

typedef NS_ENUM(NSUInteger, SegmentedControlType) {
    
    SegmentedControlTypeEmpty = 0,
    SegmentedControlTypeRoad,
    SegmentedControlTypeFigure
};

static bool isLongPress;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.locationManager = [[CLLocationManager alloc] init];

    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.mapView.showsUserLocation = YES;
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString* identifier = @"MapAnnotation";
    
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        //pin.pinTintColor = MKPinAnnotationColorPurple;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        pin.draggable = YES;
        
        UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
        
        UIButton* directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
        pin.leftCalloutAccessoryView = directionButton;
    }
    else {
        pin.annotation = annotation;
    }
    
    return pin;
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
        annotation.subtitle = [NSString stringWithFormat:@"%.5g, %.5g",
                               annotation.coordinate.latitude,
                               annotation.coordinate.longitude];
        
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
    
    CLLocationCoordinate2D coordinates[self.mapPointArray.count];
    
    for (int i=0; i < [self.mapPointArray count]; i++) {
        
        NSManagedObject *mapPoint = [self.mapPointArray objectAtIndex:i];
        coordinates[i].latitude = [[mapPoint valueForKey:@"latitude"] doubleValue];
        coordinates[i].longitude = [[mapPoint valueForKey:@"longitude"] doubleValue];
    }
    
    // create a polygon with all cooridnates
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:self.mapPointArray.count];
    [self.mapView addOverlay:polygon];
}

#pragma mark - Alert -

- (UIAlertController *)createAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    return alert;
}

- (void)actionWithTitle:(NSString *)title alertTitle:(NSString *)alertTitle alertMessage:(NSString *)alertMessage {
    
    UIAlertController * alert = [self createAlertControllerWithTitle:alertTitle message:alertMessage];
    
    UIAlertAction* alertAction = [UIAlertAction
                                  actionWithTitle:title
                                  style:UIAlertActionStyleCancel
                                  handler:^(UIAlertAction * action)
                                  {
                                      //[alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
    
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    switch (sender.selectedSegmentIndex) {
            
        case SegmentedControlTypeEmpty:
            [self removeRoutes];
            break;
            
        case SegmentedControlTypeRoad:
            [self removeRoutes];
            [self pinRoute];
            break;
            
        case SegmentedControlTypeFigure:
            [self removeRoutes];
            [self createFigure];
            break;
    }
}

#pragma mark Action to pin button

- (void) actionDescription:(UIButton*) sender {
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    
    if ([geoCoder isGeocoding]) {
        [geoCoder cancelGeocode];
    }
    
    [geoCoder
     reverseGeocodeLocation:location
     completionHandler:^(NSArray *placemarks, NSError *error) {
         
         NSString* message = nil;
         
         if (error) {
             
             message = [error localizedDescription];
             
         } else {
             
             if ([placemarks count] > 0) {
                 
                 MKPlacemark* placeMark = [placemarks firstObject];
                 
                 message = [placeMark.addressDictionary description];
                 
             } else {
                 message = @"No Placemarks Found";
             }
         }
         
         //[self showAlertWithTitle:@"Location" andMessage:message];
         
         [self actionWithTitle:@"OK" alertTitle:@"Location" alertMessage:message];
     }];
    
}

- (void) actionDirection:(UIButton*) sender {
    
    [self removeRoutes];
    
    MKAnnotationView* annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    [self addRouteForAnotationCoordinate:self.mapView.userLocation.coordinate startCoordinate:coordinate];
}

@end
