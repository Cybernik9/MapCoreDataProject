//
//  CreatePointViewController.h
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CreatePointViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UITextField *namePointTextField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;

@property (strong, nonatomic) NSManagedObject *create;

- (IBAction)actionSaveButton:(id)sender;

@end
