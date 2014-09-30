//
//  IMOUpdatesViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOUpdatesViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface IMOUpdatesViewController ()
@property (strong, nonatomic) NSMutableArray *installedItems;
@property (strong, nonatomic) NSMutableArray *updatedItems;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) NSEntityDescription *entity;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *uninstallButton;

- (IBAction)updateButtonWasTapped:(UIButton *)sender;
- (IBAction)uninstallButtonWasTapped:(UIButton *)sender;

@end

@implementation IMOUpdatesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    self.entity = [NSEntityDescription entityForName:@"IMOInstalledItem" inManagedObjectContext:self.managedObjectContext];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    // Load list of installed items from persistent store
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = self.entity;
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error: &error];
    
    if (error) {
        // TODO: deal with error
        NSLog(@"error: %@", error.localizedDescription);
    } else {
        NSLog(@"results: %@", results);
        self.installedItems = [results mutableCopy];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSManagedObject *item = [self.installedItems objectAtIndex: indexPath.row];
    
    NSLog(@"app: %@ version %@", [item valueForKey: @"name"], [item valueForKey: @"version"]);
    cell.textLabel.text = [item valueForKey: @"name"];
    cell.detailTextLabel.text = [item valueForKey: @"version"];
    cell.editingAccessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"imods-assets-updates-icon-selected"]];
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.installedItems count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Current installed items: %@", self.installedItems);
        NSManagedObject *item = self.installedItems[indexPath.row];
        
        // Delete object from both in-memory array and persistent store
        [self.installedItems removeObject: item];
        [self.managedObjectContext deleteObject: item];
        NSError *error = nil;
        [self.managedObjectContext save: &error];
        if (error) {
            NSLog(@"Couldn't save: %@", error.localizedDescription);
        }
        [tableView endEditing:YES];
        [tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)updateButtonWasTapped:(UIButton *)sender {
    [self.tableView setEditing:NO animated:YES];
}

- (IBAction)uninstallButtonWasTapped:(UIButton *)sender {
    [self.tableView setEditing:YES animated:YES];
}
@end
