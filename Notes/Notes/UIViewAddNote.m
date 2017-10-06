//
//  UIViewAddNote.m
//  Notes
//
//  Created by toandv on 5/31/16.
//  Copyright © 2016 toandv. All rights reserved.
//

#import "UIViewAddNote.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Constant.h"

@interface UIViewAddNote ()

@end

@implementation UIViewAddNote

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *date = [[NSDate alloc] init];
    NSString *fromatDate = [dateFormatter stringFromDate:date];
    self.labelCreateDate.text = fromatDate;
    self.textViewAddNote.text = @"";
//    self.textViewAddNote.backgroundColor =[UIColor yellowColor];
    [self.textViewAddNote becomeFirstResponder];
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [textView setSelectedRange:NSMakeRange(0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickDone:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *createDate = [[NSDate alloc]init];
    [dateFormatter setDateFormat:strDateFormat];
    NSString *fromatDate = [dateFormatter stringFromDate:createDate];
    NSString *inputVaulesTem = self.textViewAddNote.text;
    inputVaulesTem = [inputVaulesTem stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    inputVaulesTem = [inputVaulesTem stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    long countTem = [self isGetVaulesRow] +1;
    if (inputVaulesTem != nil && ![inputVaulesTem isEqualToString:@""]) {
        // action save
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
        //2
        NSEntityDescription *entity = [NSEntityDescription entityForName:(@"Number")inManagedObjectContext:(managedContext)];
        NSManagedObject *number = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedContext];
        //3
        [number setValue:self.textViewAddNote.text forKey:constantValues];
        [number setValue:fromatDate forKey:constantLastUpdate];
        [number setValue:[@(countTem) stringValue] forKey:constantId];
        //4
        NSError *error = nil;
        if ([ managedContext save:&error] == NO) {
            NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
    
    UIViewController *prevVC = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:prevVC animated:YES];
    
}

- (NSInteger)isGetVaulesRow {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedContext = (NSManagedObjectContext *)appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:(@"Number")];
    
    NSError *error = nil;
    NSArray *relust = [[managedContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    //    NoteNSO
     return [relust count];
}
@end
