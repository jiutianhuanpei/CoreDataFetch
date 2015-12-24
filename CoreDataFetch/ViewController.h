//
//  ViewController.h
//  CoreDataFetch
//
//  Created by 沈红榜 on 15/12/22.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController<NSFetchedResultsControllerDelegate>


@property (nonatomic, strong) NSFetchedResultsController    *resultsController;

@end
