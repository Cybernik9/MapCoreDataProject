//
//  ViewController.h
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *mapMypeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)actionZoom:(id)sender;
- (IBAction)actionChangeMapType:(id)sender;
- (IBAction)actionAddPoint:(id)sender;
- (IBAction)actionSegmentedControl:(id)sender;

@end

