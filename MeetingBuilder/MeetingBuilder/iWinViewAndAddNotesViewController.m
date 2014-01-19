//
//  iWinViewAndAddNotesViewController.m
//  MeetingBuilder
//
//  Created by Richard Shomer on 10/29/13.
//  Copyright (c) 2013 CSSE371. All rights reserved.
//

#import "iWinViewAndAddNotesViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface iWinViewAndAddNotesViewController ()
@property (nonatomic) NSInteger noteID;
@property (nonatomic) BOOL inEditMode;
@property (nonatomic) iWinMergeNoteViewController *mergeNoteViewController;
@end

@implementation iWinViewAndAddNotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withNoteID:(NSInteger)noteID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.inEditMode = YES;
    if (self) {
        // Custom initialization
        self.noteID = noteID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.noteField.layer.borderColor = [[UIColor blackColor] CGColor];
    self.noteField.layer.borderWidth = 0.7f;
    self.noteField.layer.cornerRadius = 15.0f;
    
    // change page according to wether or not it is an existing note
    if (self.noteID != -1) {
        [self.saveButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)saveButton:(id)sender
{
    if (self.inEditMode) {
        self.inEditMode = NO;
        [self.saveButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else {
        self.inEditMode = YES;
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
}

- (void)saveNote
{

    NSString *title = [[self.titleField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *note = [[self.noteField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //create note in database
    NSArray *keys = [NSArray arrayWithObjects:@"titleText", @"description", @"contentText", nil];
    NSArray *objects = [NSArray arrayWithObjects:title, @"HOLDER", note, nil];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSData *jsonData;
    NSString *jsonString;
    
    if ([NSJSONSerialization isValidJSONObject:jsonDictionary])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *url = [NSString stringWithFormat:@"http://csse371-04.csse.rose-hulman.edu/Note/"];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-length"];
    [urlRequest setHTTPBody:jsonData];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data =[NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&response
                                                     error:&error];
    NSLog(@"Console");
    NSInteger userID = -1;
    if (error) {
        [self noteCreationAlert:YES];
    }
    else
    {
        [self noteCreationAlert:NO];
//        NSError *jsonParsingError = nil;
//        NSDictionary *deserializedDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
//        userID = [[deserializedDictionary objectForKey:@"noteID"] integerValue];
    }

}


- (IBAction)cancelButton:(id)sender {
      [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)mergeNotesButton:(id)sender {
    self.mergeNoteViewController = [[iWinMergeNoteViewController alloc] initWithNibName:@"iWinMergeNoteViewController" bundle:nil inEditMode:NO];
    self.mergeNoteViewController.mergeDelegate = self;
    [self.mergeNoteViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.mergeNoteViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self presentViewController:self.mergeNoteViewController animated:YES completion:nil];
    self.mergeNoteViewController.view.superview.bounds = CGRectMake(0,0,597,200);
}


-(void)saveMergeClicked{
    [self dismissViewControllerAnimated:YES completion:Nil];

}
-(void)cancelMergeClicked
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)noteCreationAlert:(BOOL)error
{
    NSString *title;
    NSString *message;
    if (error) {
        title = @"Error";
        message = @"Failed to save note";
    }
    else
    {
        title = @"Success";
        message = @"Note has been saved";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

@end
