//
//  UIViewUpdate.m
//  Notes
//
//  Created by toandv on 5/31/16.
//  Copyright © 2016 toandv. All rights reserved.
//

#import "UIViewUpdate.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Constant.h"
@interface UIViewUpdate ()

@end

@implementation UIViewUpdate {
    NSString *param;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textUpdate.text = self.txtTem;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:strDateFormat];
    NSDate *date = [dateFormat dateFromString:self.lastUpdateTem];
    
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *fromatDate = [dateFormat stringFromDate:date];
    self.lastUpdate.text = fromatDate;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.onClickDoneUpdate.title = @"";
    self.onClickDoneUpdate.enabled = NO;
    //    self.textUpdate.backgroundColor =[UIColor yellowColor];
}

- (void)onKeyboardHide:(NSNotification *)notification {
    //keyboard will hide
    self.onClickDoneUpdate.title = @"";
    self.onClickDoneUpdate.enabled = NO;
    
}
-(void)onKeyboardShow:(NSNotification *)notification {
    self.onClickDoneUpdate.enabled = YES;
    self.onClickDoneUpdate.title = NSLocalizedString(@"DONE", nil);
    //keyboard will hide
}

- (IBAction)onClickDoneUpdate:(id)sender {
    
    if (![self.textUpdate.text isEqualToString:self.txtTem]) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        //    let appDelegate =UIApplication.sharedApplication().delegate as!
        NSManagedObjectContext * managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number")];
        param = [constantId stringByAppendingString:@" == %@"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:param,self.tempId]];
        
        NSError *error = nil;
        NSArray *relust = [managedContext executeFetchRequest:fetchRequest error:&error];
        //3
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *createDate = [[NSDate alloc]init];
        [dateFormatter setDateFormat:strDateFormat];
        NSString *sysdate = [dateFormatter stringFromDate:createDate];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateUpdateView = [dateFormatter stringFromDate:createDate];
        for (NSManagedObject *number in relust) {
            [number setValue:sysdate forKey:constantLastUpdate];
            [number setValue:self.textUpdate.text  forKey:constantValues];
            [managedContext save:&error];
            self.txtTem = self.textUpdate.text;
            self.lastUpdate.text = dateUpdateView;
        }
    }
    self.onClickDoneUpdate.title=@"";
    self.onClickDoneUpdate.enabled=NO;
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (IBAction)onClickDelete:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BUTTON_DELETE",nil)
                                                                   message:NSLocalizedString(@"DELETE",nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              
                                                              AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                                              NSManagedObjectContext * managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
                                                              NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number")];
                                                              param = [constantId stringByAppendingString:@" ==%@"];
                                                              [fetchRequest setPredicate:[NSPredicate predicateWithFormat:param,self.tempId]];
                                                              
                                                              NSError *error = nil;
                                                              NSArray *relust = [managedContext executeFetchRequest:fetchRequest error:&error];
                                                              
                                                              for (NSManagedObject *number in relust) {
                                                                  [managedContext deleteObject:number];
                                                                  [managedContext save:&error];
                                                              }
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self dismissViewControllerAnimated:alert completion:nil];
                                                           }];
    
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onClickButtomShare:(id)sender {
    
    NSString *textToShare = self.textUpdate.text;
    NSURL *myWebsite = [NSURL URLWithString:@"https://www.facebook.com/"];
    NSArray *objectsToShare = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeMessage,
                                   UIActivityTypePostToFacebook,
                                   UIActivityTypeMail];
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
