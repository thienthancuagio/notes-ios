//
//  UIViewUpdate.h
//  Notes
//
//  Created by toandv on 5/31/16.
//  Copyright © 2016 toandv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewUpdate : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lastUpdate;
@property (weak, nonatomic) IBOutlet UITextView *textUpdate;
@property (strong, nonatomic) NSString *txtTem;
@property (strong, nonatomic) NSString *lastUpdateTem;
@property (strong,nonatomic) NSString * tempId;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *onClickDoneUpdate;

@end
