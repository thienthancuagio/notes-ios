//
//  ViewController.m
//  Notes
//
//  Created by toandv on 5/31/16.
//  Copyright © 2016 toandv. All rights reserved.
//

#import "ViewController.h"
#import "UIViewUpdate.h"
#import "UIViewAddNote.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Constant.h"

enum {
    UITableViewCellEditingStyleMultiSelect = 3,
};


@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController {
    
    UIImage *imageNoteAdd;
    UIImage *imageNoteDelete;
    NSArray *cellArray;
    NSString * temValue;
    NSArray *searchResults;
    NSString *param;
}

static int countIsCheckBox = 0;
static int numberIndexSutring = 5;
static int cgpX = 0;
static int cgpY = 44;

- (void)viewDidLoad {
    [super viewDidLoad];
    imageNoteAdd = [UIImage imageNamed:@"iconAdd.png"];
    self.onClickEdit.title = NSLocalizedString(@"EDIT", nil);
    self.onClickAddOrDelete.image = imageNoteAdd;
    cellArray = [self loadDb];
    if(cellArray != nil) {
        NSInteger totalNote = [cellArray count];
        self.iTemTotalNotes.title = [NSString stringWithFormat:NSLocalizedString(@"NOTE_TOTAL", nil), totalNote];
    }
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setContentOffset:CGPointMake(cgpX, cgpY)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return [cellArray count];
    if(self.searchController.active){
        return [searchResults count];
    } else {
        return [cellArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"RecipeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    // search bar
    NSManagedObject *device = nil;
    if (self.searchController.active) {
        device = [searchResults objectAtIndex:indexPath.row];
    } else {
        device = [cellArray objectAtIndex:indexPath.row];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *systemDate = [[NSDate alloc]init];
    [dateFormatter setDateFormat:strDateFormat];
    NSString *fromatDate = [dateFormatter stringFromDate:systemDate];
    fromatDate = [fromatDate componentsSeparatedByString:@" "][0];
    NSArray *temArrayDate = [[device valueForKey:constantLastUpdate] componentsSeparatedByString:@" "];
    NSString* text = [device valueForKey:constantValues];
    
    if ([fromatDate isEqualToString:temArrayDate[0]]) {
        [cell.detailTextLabel setText:[temArrayDate[1] substringToIndex:numberIndexSutring]];
    } else {
        [cell.detailTextLabel setText:temArrayDate[0]];
    }
    if(self.isCheck) {
        text = [self stringByTruncatingToWidth:(cell.frame.size.width-180.0) withFont:[UIFont systemFontOfSize:17] :text];
    } else {
        text = [self stringByTruncatingToWidth:(cell.frame.size.width-140.0) withFont:[UIFont systemFontOfSize:17] :text];
    }
    cell.textLabel.text = text;
    [cell.textLabel sizeToFit];
    cell.tintColor = [UIColor redColor];
    return cell;
}

- (NSString *)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font :(NSString*) result {
    while ([result sizeWithFont:font].width > width) {
        result = [result stringByReplacingOccurrencesOfString:@"..." withString:[NSString string]];
        result = [[result substringToIndex:([result length] - 1)] stringByAppendingString:@"..."];
    }
    return result;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number") ];
    NSString *temId = [[cellArray objectAtIndex:indexPath.row] valueForKey:constantId];
    param = [constantId stringByAppendingString:@" == %@"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:param,temId]];
    
    NSError *error = nil;
    NSArray *relust = [managedContext executeFetchRequest:fetchRequest error:&error];
    if(relust != nil) {
        for(NSManagedObject *number in relust) {
            [managedContext deleteObject:number];
        }
        [managedContext save:&error];
    }
    [self viewDidLoad];
    [self.tableView reloadData];
}

- (NSArray *)loadDb {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number")];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: constantLastUpdate ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSError *error = nil;
    NSArray *relust = [managedContext executeFetchRequest:fetchRequest error:&error];
    
    return relust;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    cellArray = [self loadDb];
    if(cellArray != nil) {
        NSInteger totalNote = [cellArray count];
        self.iTemTotalNotes.title = [NSString stringWithFormat:NSLocalizedString(@"NOTE_TOTAL", nil),totalNote];
    }
    
    [self.tableView reloadData]; // to reload selected cell
    if(!self.searchController.active){
        [self.tableView setContentOffset:CGPointMake(cgpX, cgpY)];
    }
}
- (void)dealloc {
    [self.searchController.view removeFromSuperview]; // It works!
}

- (IBAction)onClickEdit:(id)sender {
    if(self.isCheck) {
        self.isCheck = false;
        [self.tableView setEditing:NO animated:YES];
        self.iTemTotalNotes.title = temValue;
        self.onClickEdit.title = NSLocalizedString(@"EDIT", nil);
        self.onClickAddOrDelete.image = imageNoteAdd;
        self.searchController.searchBar.userInteractionEnabled = YES;
        self.searchController.searchBar.translucent = YES;
        [self.tableView reloadData];
    } else {
        self.onClickEdit.title = NSLocalizedString(@"CANCEL", nil);
        temValue = self.iTemTotalNotes.title;
        self.isCheck = true;
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        
        self.iTemTotalNotes.title = @"";
        self.onClickAddOrDelete.image = nil;
        self.onClickAddOrDelete.title = NSLocalizedString(@"BUTTON_DELETE_ALL", nil);
        self.searchController.searchBar.userInteractionEnabled = NO;
        self.searchController.searchBar.translucent = NO;
    }
    if (cellArray != nil) {
        NSInteger totalNote = [cellArray count];
        self.iTemTotalNotes.title = [NSString stringWithFormat:NSLocalizedString(@"NOTE_TOTAL", nil), totalNote];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isCheck) {
        return UITableViewCellEditingStyleMultiSelect;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isCheck) {
        if (self.searchController.active) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewUpdate *updateVC = (UIViewUpdate *)[sb instantiateViewControllerWithIdentifier:@"UIViewUpdate"];
            updateVC.txtTem = [[searchResults objectAtIndex:indexPath.row] valueForKey:constantValues];
            updateVC.lastUpdateTem = [[searchResults objectAtIndex:indexPath.row] valueForKey:constantLastUpdate];//tempId
            updateVC.tempId = [[searchResults objectAtIndex:indexPath.row] valueForKey:constantId];//tempId
            [self.navigationController pushViewController:updateVC animated:YES];
        } else {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewUpdate *updateVC = (UIViewUpdate *)[sb instantiateViewControllerWithIdentifier:@"UIViewUpdate"];
            updateVC.txtTem = [[cellArray objectAtIndex:indexPath.row] valueForKey:constantValues];
            updateVC.lastUpdateTem = [[cellArray objectAtIndex:indexPath.row] valueForKey:constantLastUpdate];//tempId
            updateVC.tempId = [[cellArray objectAtIndex:indexPath.row] valueForKey:constantId];//tempId
            [self.navigationController pushViewController:updateVC animated:YES];
        }
    } else {
        countIsCheckBox++;
        if (countIsCheckBox > 0) {
            self.onClickAddOrDelete.title = NSLocalizedString(@"BUTTON_DELETE", nil);
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    countIsCheckBox--;
    if (countIsCheckBox == 0) {
        self.onClickAddOrDelete.title=NSLocalizedString(@"BUTTON_DELETE_ALL", nil);
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

//
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = self.searchController.searchBar.text;
    //    searchResults = nil;
    if ([searchString isEqualToString: @""]) {
        searchResults = cellArray;
    } else {
        NSPredicate *resultPredicate;
        param = [constantValues stringByAppendingString:@" contains[c] %@"];
        resultPredicate = [NSPredicate predicateWithFormat:param,searchString];
        if ([searchString isEqualToString: @""]) {
            self.isCheckSearBar = false;
        } else {
            self.isCheckSearBar = true;
        }
        searchResults = [cellArray filteredArrayUsingPredicate:resultPredicate];
        if(searchResults != nil) {
            NSInteger totalNote = [searchResults count];
            self.iTemTotalNotes.title = [NSString stringWithFormat:NSLocalizedString(@"NOTE_TOTAL", nil),totalNote];
        }
    }
    [self.tableView reloadData];
}

/*
 *process onClickAddOrDelete
 */
- (IBAction)onClickAddOrDelete:(id)sender {
    if(self.isCheck){
        // delete
        NSMutableArray *yourNewArr = [[NSMutableArray alloc ] init];
        for (NSUInteger i = 0; i < [cellArray count]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            //            NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
            NSArray *selIndexs = self.tableView.indexPathsForSelectedRows;
            if ([selIndexs containsObject:indexPath]) {
                if ([[cellArray objectAtIndex:indexPath.row] valueForKey:constantId] != nil) {
                    [yourNewArr addObject:[[cellArray objectAtIndex:indexPath.row] valueForKey:constantId]];
                }
            }
        }
        
        if ([yourNewArr count] > 0) {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSManagedObjectContext * managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number") ];
            param = [constantId stringByAppendingString:@" IN %@"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:param,yourNewArr]];
            
            NSError *error = nil;
            NSArray *relust = [managedContext executeFetchRequest:fetchRequest error:&error];
            if (relust != nil ) {
                for(NSManagedObject *number in relust){
                    [managedContext deleteObject:number];
                }
                [managedContext save:&error];
            }
            self.searchController.searchBar.userInteractionEnabled = NO;
            self.searchController.searchBar.translucent = NO;
            cellArray= [self loadDb];
            [self.tableView reloadData];
            if(cellArray != nil) {
                NSInteger totalNote = [cellArray count];
                self.iTemTotalNotes.title = [NSString stringWithFormat:NSLocalizedString(@"NOTE_TOTAL", nil), totalNote];
            }
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TITLE_DELETE",nil)
                                                                           message:NSLocalizedString(@"DELETE_ALL",nil)
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                                                      NSManagedObjectContext * managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
                                                                      NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number") ];
                                                                      NSError *error = nil;
                                                                      NSArray *relust = [managedContext executeFetchRequest:fetchRequest error:&error];
                                                                      if (relust != nil) {
                                                                          for (NSManagedObject *number in relust) {
                                                                              [managedContext deleteObject:number];
                                                                          }
                                                                          [managedContext save:&error];
                                                                      }
                                                                      cellArray= [self loadDb];
                                                                      [self.tableView reloadData];
                                                                      if(cellArray != nil) {
                                                                          NSInteger totalNote = [cellArray count];
                                                                          self.iTemTotalNotes.title = [NSString stringWithFormat:NSLocalizedString(@"NOTE_TOTAL", nil), totalNote];
                                                                      }
                                                                  }];
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL",nil)
                                                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                       [self dismissViewControllerAnimated:alert completion:nil];
                                                                   }];
            [alert addAction:firstAction];
            [alert addAction:secondAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        NSString *tem = [@([yourNewArr count]) stringValue];
        NSLog(@"so luong ban ghi trong bang %@", tem);
        //        [self viewDidLoad];
        
    } else {
        // open new VC
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewAddNote *newVC = (UIViewAddNote *)[sb instantiateViewControllerWithIdentifier:@"UIViewAddNote"];
        [self.navigationController pushViewController:newVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

@end
