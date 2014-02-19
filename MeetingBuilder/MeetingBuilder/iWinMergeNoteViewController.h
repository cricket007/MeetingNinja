//
//  iWinMergeNoteViewController.h
//  MeetingBuilder
//
//  Created by CSSE Department on 1/23/14.
//  Copyright (c) 2014 CSSE371. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MergeNoteDelegate <NSObject>
-(void)loadNoteIntoView;
@end
@interface iWinMergeNoteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) id<MergeNoteDelegate> mergeNoteDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil noteContent:(NSString *)content userNames:(NSMutableArray *)names notes:(NSMutableArray *)notes noteID:(NSInteger)noteID userID:(NSInteger)userID;
@property (nonatomic) IBOutlet UITableView *userListTable;
@property (nonatomic) IBOutlet UITableView *noteListTable;
@property (nonatomic) NSMutableArray *notes;
@property (nonatomic) NSMutableArray *names;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end
