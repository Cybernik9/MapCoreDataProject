//
//  CreatePointViewController.m
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import "CreatePointViewController.h"

@interface CreatePointViewController ()

@end

@implementation CreatePointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.create) {
        self.namePointTextField.text = [self.create valueForKey:@"namePoint"];
        self.latitudeTextField.text = [self.create valueForKey:@"latitude"];
        self.longitudeTextField.text = [self.create valueForKey:@"longitude"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Core Data -

- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

#pragma mark - Action -

- (IBAction)actionSaveButton:(id)sender {
    
    CGFloat latitude = [self.latitudeTextField.text doubleValue];
    CGFloat longitude = [self.longitudeTextField.text doubleValue];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.create) {
        
        [self.create setValue:self.namePointTextField forKey:@"namePoint"];
        [self.create setValue:self.latitudeTextField forKey:@"latitude"];
        [self.create setValue:self.longitudeTextField forKey:@"longitude"];
        
        return;
    }
    
    
    NSManagedObject *newMapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MapPoints"
                                                              inManagedObjectContext:context];
    
    [newMapPoint setValue:self.namePointTextField.text forKey:@"namePoint"];
    [newMapPoint setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [newMapPoint setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"error: %@ %@", error, [error localizedDescription]);
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Save is not successful!"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Save"
                                      message:@"Save successful"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        [self.navigationController popViewControllerAnimated:YES];
                                        
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.namePointTextField]) {
        [self.latitudeTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.latitudeTextField]) {
        [self.longitudeTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@""]) {
        
        return YES;
    }
    
    if (([textField isEqual:self.latitudeTextField] || [textField isEqual:self.longitudeTextField]) &&
        (([string characterAtIndex:0] >= '0' && [string characterAtIndex:0] <= '9') ||
        [string characterAtIndex:0] == '.')) {
        
        return YES;
    }
    else if ([textField isEqual:self.namePointTextField]) {
        
        return YES;
        
    } else {
        
        return NO;
    }
    
}
@end