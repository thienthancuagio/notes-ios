//
//  ViewController.h
//  Notes
//
//  Created by toandv on 5/31/16.
//  Copyright © 2016 toandv. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SWTableViewCell.h"

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *iTemTotalNotes;
@property (nonatomic, assign) BOOL isCheck;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *onClickEdit;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *onClickAddOrDelete;
@property (nonatomic, assign) BOOL isCheckSearBar;

@end

