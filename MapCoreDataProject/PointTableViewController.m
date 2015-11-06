//
//  PointTableViewController.m
//  MapCoreDataProject
//
//  Created by Admin on 05.11.15.
//  Copyright © 2015 HY. All rights reserved.
//

#import "PointTableViewController.h"
#import "CreatePointViewController.h"

@interface PointTableViewController ()

@property (strong, nonatomic) NSMutableArray* mapPointsArray;

@end

@implementation PointTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MapPoints"];
    self.mapPointsArray = [[managedObjectContext executeFetchRequest:fetchRequest
                                                               error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - MapProtocol -

- (void)mapArayDidChangeValue:(NSArray*)value {
 
    if ([value count]) {
        
        //
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.mapPointsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSManagedObject *mapPoint = [self.mapPointsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [mapPoint valueForKey:@"namePoint"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 [mapPoint valueForKey:@"latitude"],
                                 [mapPoint valueForKey:@"longitude"]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                                                forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [context deleteObject:[self.mapPointsArray objectAtIndex:indexPath.row]];
        [self.mapPointsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"error: %@ %@", error, [error localizedDescription]);
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"Update" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"Update"]) {

        NSManagedObject  *selected = [self.mapPointsArray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        CreatePointViewController* createViewController = segue.destinationViewController;
        createViewController.create = selected;
    }
}

@end
