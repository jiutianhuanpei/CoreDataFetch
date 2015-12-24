//
//  ViewController.m
//  CoreDataFetch
//
//  Created by 沈红榜 on 15/12/22.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Car.h"

@interface ViewController ()<NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController {
    __weak IBOutlet UITableView *_tableView;
    
    __weak IBOutlet UIView *_bottomView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"owner = %@", @"myself"];
    
    _resultsController = [Car MR_fetchAllSortedBy:@"factoryDate" ascending:true withPredicate:pre groupBy:nil delegate:self];
    [_resultsController performFetch:nil];
}

- (IBAction)add:(id)sender {
    Car *kk = [Car MR_createEntity];
    kk.name = [NSString stringWithFormat:@"car_%d", arc4random() % 100];
    kk.factoryDate = [NSDate date];
    kk.owner = @"myself";
    [kk.managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (IBAction)delete:(id)sender {
    id <NSFetchedResultsSectionInfo> info = [_resultsController sections][0];
    NSInteger num = [info numberOfObjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num - 1 inSection:0];
    
    Car *car = [_resultsController objectAtIndexPath:indexPath];
    [car MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
}



#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"%@   %d", anObject, type);
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
        }
        case NSFetchedResultsChangeMove: {
            
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
        }
            default:
            break;
    }
    
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    Car *car = [_resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = car.name;
    static NSDateFormatter *matter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        matter = [[NSDateFormatter alloc] init];
        matter.dateFormat = @"yyyy-dd-mm";
    });
    cell.detailTextLabel.text = [matter stringFromDate:car.factoryDate];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_resultsController sections].count > 0) {
        id<NSFetchedResultsSectionInfo> info = [_resultsController sections][section];
        return [info numberOfObjects];
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Car *car = [_resultsController objectAtIndexPath:indexPath];
    NSString *indexName = [[car.name componentsSeparatedByString:@"_"] firstObject];
    NSInteger index = [[[car.name componentsSeparatedByString:@"_"] lastObject] integerValue];
    
    index += 100;
    car.name = [NSString stringWithFormat:@"%@_%d", indexName, index];
    [car.managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (NSIndexPath *)lastIndexPath {
    id <NSFetchedResultsSectionInfo> info = [_resultsController sections][0];
    NSInteger num = [info numberOfObjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num - 1 inSection:0];
    return indexPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
