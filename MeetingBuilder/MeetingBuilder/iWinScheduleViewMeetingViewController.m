//
//  iWinScheduleViewMeetingViewController.m
//  MeetingBuilder
//
//  Created by CSSE Department on 10/24/13.
//  Copyright (c) 2013 CSSE371. All rights reserved.
//

#import "iWinScheduleViewMeetingViewController.h"
#import "iWinViewAndAddViewController.h"
#import "iWinAddUsersViewController.h"
#import "iWinAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Meeting.h"
#import "Contact.h"
#import "Settings.h"

@interface iWinScheduleViewMeetingViewController ()
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL isStartDate;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSInteger meetingID;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (strong, nonatomic) OCCalendarViewController* ocCalVC;
@property (strong, nonatomic) iWinViewAndAddViewController *agendaController;
@property (strong, nonatomic) iWinAddUsersViewController *userViewController;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIDatePicker *enddatePicker;
@property (nonatomic) NSInteger userID;
@property (strong, nonatomic) Meeting *meeting;
@property (strong, nonatomic) NSMutableArray *userList;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSUInteger rowToDelete;
@property (nonatomic) UIAlertView *deleteAlertView;
@end

@implementation iWinScheduleViewMeetingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUserID:(NSInteger)userID withMeetingID:(NSInteger)meetingID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.meetingID = meetingID;
        self.isEditing = YES;
        self.userID = userID;
        if (meetingID == -1)
        {
            self.isEditing = NO;
        }
    }
    return self;
}

- (void)formatTime:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    self.startTimeLabel.text = [formatter stringFromDate:date];
    NSDate *currentDate = [NSDate date];
    NSDate *datePlusFiveMinutes = [currentDate dateByAddingTimeInterval:300];
    self.endTimeLabel.text = [formatter stringFromDate:datePlusFiveMinutes];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //_isAgendaCreated = false;
    
    iWinAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [appDelegate managedObjectContext];
    self.isStartDate = NO;
    self.headerLabel.text = @"Schedule a Meeting";
    [self.addAgendaButton setTitle:@"Add Agenda" forState:UIControlStateNormal];
    self.saveAndAddMoreButton.hidden = NO;
    
    self.userList = [[NSMutableArray alloc] init];
    
    self.startDateLabel.userInteractionEnabled = YES;
    self.endDateLabel.userInteractionEnabled = YES;
    
    [self setGestureRecognizers];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    if (self.isEditing)
    {
        
        [self initForExistingMeeting];
    }
    else
    {
        self.startDateLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
        self.endDateLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
        
        self.startDate = [NSDate date];
        self.endDate = [NSDate date];
        [self formatTime:[NSDate date]];
    }
    
}

-(void) setGestureRecognizers
{
    UITapGestureRecognizer *tapStartDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startDateClicked)];
    UITapGestureRecognizer *tapEndDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endDateClicked)];
    
    UITapGestureRecognizer *tapStartTime = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTimeClicked)];
    UITapGestureRecognizer *tapEndTime = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeClicked)];
    
    [self.startDateLabel addGestureRecognizer:tapStartDate];
    [self.endDateLabel addGestureRecognizer:tapEndDate];
    
    [self.startTimeLabel addGestureRecognizer:tapStartTime];
    [self.endTimeLabel addGestureRecognizer:tapEndTime];
}

-(void) initForExistingMeeting
{
    self.headerLabel.text = @"View Meeting";
    [self.addAgendaButton setTitle:@"Agenda 101" forState:UIControlStateNormal];
    self.saveAndAddMoreButton.hidden = YES;
    
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"meetingID = %d", self.meetingID];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request
                                                  error:&error];
    self.meeting = (Meeting*)[result objectAtIndex:0];
    
    self.titleField.text = self.meeting.title;
    self.placeField.text = self.meeting.location;
    
    [self initDateTimeLabels];
    [self initAttendees];
}

-(void) initDateTimeLabels
{
    NSArray *startDateAndTime = [self.meeting.datetime componentsSeparatedByString:@" "];
    NSArray *endDateAndTime = [self.meeting.endDatetime componentsSeparatedByString:@" "];
    
    NSString *startdate = [startDateAndTime objectAtIndex:0];
    NSString *starttime = [NSString stringWithFormat:@"%@ %@", [startDateAndTime objectAtIndex:1], [startDateAndTime objectAtIndex:2]];
    
    NSString *enddate = [endDateAndTime objectAtIndex:0];
    NSString *endtime = [NSString stringWithFormat:@"%@ %@", [endDateAndTime objectAtIndex:1], [endDateAndTime objectAtIndex:2]];
    
    self.startDateLabel.text = startdate;
    self.endDateLabel.text = enddate;
    
    self.startTimeLabel.text = starttime;
    self.endTimeLabel.text = endtime;
    
    self.startDate = [self.dateFormatter dateFromString:startdate];
    self.endDate = [self.dateFormatter dateFromString:enddate];
}

-(Contact *)getContactForID:(NSString*)userID
{
    NSString *url = [NSString stringWithFormat:@"http://csse371-04.csse.rose-hulman.edu/User/%@", userID];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                        error:&error];
    NSArray *jsonArray;
    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Meetings not found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
    }
    else
    {
        NSError *jsonParsingError = nil;
        jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
    }
    if (jsonArray.count > 0)
    {
        for (NSDictionary* users in jsonArray)
        {
            Contact *c = [[Contact alloc] init];
            c.userID = (NSNumber*)[users objectForKey:@"userID"];
            c.name = (NSString *)[users objectForKey:@"name"];
            c.email = (NSString *)[users objectForKey:@"email"];
            return c;
            }
        }
    return nil;
}

-(void) initAttendees
{
    NSArray *attendeeArray = [self.meeting.attendance componentsSeparatedByString:@","];
    for (int i=0; i<[attendeeArray count]; i++)
    {
        [self.userList addObject:[self getContactForID:(NSString *)attendeeArray[i]]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
       
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttendeeCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AttendeeCell"];
    }
    
    Contact *c = (Contact *)[self.userList objectAtIndex:indexPath.row];
    
    cell.textLabel.text =  c.name;
    if (c.name.length == 0){
        cell.textLabel.text = c.email;
    }
    cell.detailTextLabel.text = c.email;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.rowToDelete = indexPath.row;
        UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this meeting?" delegate:self cancelButtonTitle:@"No, just kidding!" otherButtonTitles:@"Yes, please", nil];
        [deleteAlertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.deleteAlertView])
    {
        if (buttonIndex == 1)
        {
            //Perform deletion
            NSString *url = [NSString stringWithFormat:@"http://csse371-04.csse.rose-hulman.edu/Meeting/%d", self.meetingID];
            
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [urlRequest setHTTPMethod:@"DELETE"];
            NSURLResponse * response = nil;
            NSError * error = nil;
            [NSURLConnection sendSynchronousRequest:urlRequest
                                  returningResponse:&response
                                              error:&error];
            //TODO: Add error checking.
            [self.viewMeetingDelegate refreshMeetingList];
        }
    }
    else
    {
        if (buttonIndex == 1)
        {
            [self.userList removeObjectAtIndex:self.rowToDelete];
            [self.attendeeTableView reloadData];
        }
        else
        {
            self.rowToDelete = -1;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddAgenda
{
    if ([self.addAgendaButton.titleLabel.text isEqualToString:@"Add Agenda"])
    {
        self.agendaController = [[iWinViewAndAddViewController alloc] initWithNibName:@"iWinViewAndAddViewController" bundle:nil];
        self.agendaController.meetingID = self.meetingID;
    }
    else
    {
        self.agendaController = [[iWinViewAndAddViewController alloc] initWithNibName:@"iWinViewAndAddViewController" bundle:nil];
        self.agendaController.meetingID = self.meetingID;
    }
    [self.agendaController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self.agendaController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    self.agendaController.delegate = self;
    self.agendaController.isAgendaCreated = [self.addAgendaButton.titleLabel.text isEqualToString:@"Add Agenda"] ? NO : YES;
    [self presentViewController:self.agendaController animated:YES completion:nil];
    self.agendaController.view.superview.bounds = CGRectMake(0,0,768,1003);
}

- (IBAction)onAddAttendees
{
    self.userViewController = [[iWinAddUsersViewController alloc] initWithNibName:@"iWinAddUsersViewController" bundle:nil withPageName:@"Meeting" inEditMode:self.isEditing];
    [self.userViewController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self.userViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    self.userViewController.userDelegate = self;
    [self presentViewController:self.userViewController animated:YES completion:nil];
    self.userViewController.view.superview.bounds = CGRectMake(0,0,768,1003);
}

- (IBAction)onViewMySchedule {
}

-(void)selectedUsers:(NSMutableArray *)userList
{
    self.userList = userList;
    [self.attendeeTableView reloadData];
}

-(void) saveNewMeeting
{
    
    NSMutableArray *userIDJsonDictionary = [[NSMutableArray alloc] init];
    for (int i = 0; i<[self.userList count]; i++)
    {
        Contact *c = (Contact *)self.userList[i];
        NSArray *userIDKeys = [[NSArray alloc] initWithObjects:@"userID", nil];
        NSArray *userIDObjects = [[NSArray alloc] initWithObjects:[c.userID stringValue], nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:userIDObjects forKeys:userIDKeys];
        [userIDJsonDictionary addObject:dict];
    }
    
    
    NSArray *keys = [NSArray arrayWithObjects:@"userID", @"title", @"location", @"datetime", @"endDatetime", @"description", @"attendance", nil];
    NSArray *objects = [NSArray arrayWithObjects:[[NSNumber numberWithInt:self.userID] stringValue], self.titleField.text, self.placeField.text, [NSString stringWithFormat:@"%@ %@", self.startDateLabel.text, self.startTimeLabel.text],[NSString stringWithFormat:@"%@ %@", self.endDateLabel.text, self.endTimeLabel.text], @"Test Meeting", userIDJsonDictionary, nil];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSData *jsonData;
    NSString *jsonString;
    
    if ([NSJSONSerialization isValidJSONObject:jsonDictionary])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *url = [NSString stringWithFormat:@"http://csse371-04.csse.rose-hulman.edu/Meeting/"];
    
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
    NSError *jsonParsingError = nil;
    NSDictionary *deserializedDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:&jsonParsingError];
    self.meetingID = [[deserializedDictionary objectForKey:@"meetingID"] integerValue];
}

- (IBAction)onClickSave
{
    if (!self.isEditing)
    {
        
//        NSManagedObject *newMeeting = [NSEntityDescription insertNewObjectForEntityForName:@"Meeting" inManagedObjectContext:context];
//        NSError *error;
//        
//        
//        [newMeeting setValue:self.titleField.text forKey:@"title"];
//        [newMeeting setValue:self.placeField.text forKey:@"location"];
//        [newMeeting setValue:[NSString stringWithFormat: @"%@ %@ %@ %@", self.startDateLabel.text, self.startTimeLabel.text, self.endDateLabel.text, self.endTimeLabel.text] forKey:@"datetime"];
//        [newMeeting setValue:[NSNumber numberWithInt:0] forKey:@"userID"];
//        [newMeeting setValue:@"false" forKey:@"attendance"];
//        [context save:&error];
        [self saveNewMeeting];
//        UILocalNotification* localNotification = [[UILocalNotificationalloc] init];
//        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
//        localNotification.alertBody = @"Your alert message";
//        localNotification.timeZone = [NSTimeZone defaultTimeZone];
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    }
    else
    {
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:self.context];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %@", self.meetingID];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request
                                                 error:&error];
        
        Meeting *newMeeting = (Meeting*)[result objectAtIndex:0];
        [newMeeting setValue:self.titleField.text forKey:@"title"];
        [newMeeting setValue:self.placeField.text forKey:@"location"];
        [newMeeting setValue:[NSString stringWithFormat: @"%@ %@ %@ %@", self.startDateLabel.text, self.startTimeLabel.text, self.endDateLabel.text, self.endTimeLabel.text] forKey:@"datetime"];
        [newMeeting setValue:@"false" forKey:@"attendance"];
        [self.context save:&error];
        
    }
    [self scheduleNotification];
    [self.viewMeetingDelegate refreshMeetingList];
}

-(void) scheduleNotification
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.context];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %d", self.userID];
    [request setPredicate:predicate];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request
                                                  error:&error];
    
    Settings *settings = (Settings *)[result objectAtIndex:0];
    if ([settings.shouldNotify boolValue])
    {
        [self removeOldNotifications];
        
        NSString *meetingStartDate = [NSString stringWithFormat:@"%@ %@", self.startDateLabel.text, self.startTimeLabel.text];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        NSDate *dateTimeOfMeeting = [formatter dateFromString:meetingStartDate];

        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        
        NSNumber *meetingID = [NSNumber numberWithInt:self.meetingID];
        NSArray *key = [[NSArray alloc] initWithObjects:@"meetingID", nil];
        NSArray *object = [[NSArray alloc] initWithObjects:meetingID, nil];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:object forKeys:key];
        localNotification.userInfo = userInfo;
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        NSDate *fireDate;
        switch ([settings.whenToNotify integerValue]) {
            case 0:
                fireDate = dateTimeOfMeeting;
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts now", self.titleField.text];
                break;
            case 1:
                [dateComponents setMinute:-5];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 5 minutes", self.titleField.text];
                break;
            case 2:
                [dateComponents setMinute:-15];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 15 minutes", self.titleField.text];
                break;
            case 3:
                [dateComponents setMinute:-30];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 30 minutes", self.titleField.text];
                break;
            case 4:
                [dateComponents setHour:-1];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 1 hour", self.titleField.text];
                break;
            case 5:
                [dateComponents setHour:-2];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 2 hours", self.titleField.text];
                break;
            case 6:
                [dateComponents setDay:-1];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 1 day", self.titleField.text];
                break;
            case 7:
                [dateComponents setDay:-2];
                fireDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:dateTimeOfMeeting options:0];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ meeting starts in 2 days", self.titleField.text];
                break;
            default:
                break;
        }
        localNotification.fireDate = fireDate;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}
-(void) removeOldNotifications
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i=0; i<[notifications count]; i++)
    {
        UILocalNotification* notification = [notifications objectAtIndex:i];
        NSDictionary *userInfo = notification.userInfo;
        NSInteger meetingId=[[userInfo valueForKey:@"meetingID"] integerValue];
        if (meetingId == self.meetingID)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
        }
    }
}

- (IBAction)onClickSaveAndAddMore
{
    [self saveNewMeeting];
    
    self.headerLabel.text = @"Schedule a Meeting";
    self.titleField.text = @"";
    self.startDateLabel.text = @"";
    self.endDateLabel.text = @"";
    //self.durationField.text = @"";
    self.placeField.text = @"";
    [self.addAgendaButton setTitle:@"Add Agenda" forState:UIControlStateNormal];
}

- (IBAction)onDeleteMeeting {
    
    
    self.deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this contact?" delegate:self cancelButtonTitle:@"No, just kidding!" otherButtonTitles:@"Yes, please", nil];
    [self.deleteAlertView show];
}

- (IBAction)onClickCancel
{
    //[self.scheduleDelegate cancelClicked];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)startDateClicked
{
    self.isStartDate = YES;
    self.ocCalVC = [[OCCalendarViewController alloc] initAtPoint:CGPointMake(self.startDateLabel.frame.origin.x+84, self.startDateLabel.frame.origin.y+32) inView:self.view];
    [self.ocCalVC setStartDate:self.startDate];
    [self.ocCalVC setEndDate:self.startDate];
    self.ocCalVC.selectionMode = OCSelectionSingleDate;
    self.ocCalVC.delegate = self;
    [self.view addSubview:self.ocCalVC.view];
    
}

- (void)endDateClicked
{
    self.isStartDate = NO;
    
    self.ocCalVC = [[OCCalendarViewController alloc] initAtPoint:CGPointMake(self.endDateLabel.frame.origin.x+84, self.endDateLabel.frame.origin.y+32) inView:self.view];
    self.ocCalVC.selectionMode = OCSelectionSingleDate;
    self.ocCalVC.delegate = self;
    [self.ocCalVC setStartDate:self.endDate];
    [self.ocCalVC setEndDate:self.endDate];
    [self.view addSubview:self.ocCalVC.view];
}

-(void) startTimeClicked
{
    UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(220, 10, 75, 50)];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(saveStartTime) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *popoverView = [[UIView alloc] init];   //view
    [popoverView addSubview:button];
    
    //    UIDatePicker *datePicker=[[UIDatePicker alloc]init];//Date picker
    self.datePicker=[[UIDatePicker alloc]init];//Date picker
    self.datePicker.frame=CGRectMake(0,30,320, 216);
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.datePicker setMinuteInterval:5];
    //[datePicker addTarget:self action:@selector(Result) forControlEvents:UIControlEventValueChanged];
    [popoverView addSubview:self.datePicker];
    
    popoverContent.view = popoverView;
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    //popoverController.delegate=self;
    
    
    [self.popOverController setPopoverContentSize:CGSizeMake(320, 250) animated:NO];
    [self.popOverController presentPopoverFromRect:CGRectMake(self.startTimeLabel.frame.origin.x, self.startTimeLabel.frame.origin.y+2, self.startTimeLabel.frame.size.width, self.startTimeLabel.frame.size.height)  inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) saveStartTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"];
    
    [self.startTimeLabel setText:[outputFormatter stringFromDate:self.datePicker.date]];
    [self.popOverController dismissPopoverAnimated:YES];
}

-(void) endTimeClicked
{
    UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(220, 10, 75, 50)];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(saveEndTime) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *popoverView = [[UIView alloc] init];   //view
    [popoverView addSubview:button];
    
    //UIDatePicker *enddatePicker=[[UIDatePicker alloc]init];//Date picker
    self.enddatePicker=[[UIDatePicker alloc]init];//Date picker
    self.enddatePicker.frame=CGRectMake(0,30,320, 216);
    self.enddatePicker.datePickerMode = UIDatePickerModeTime;
    [self.enddatePicker setMinuteInterval:5];
    //[datePicker addTarget:self action:@selector(Result) forControlEvents:UIControlEventValueChanged];
    [popoverView addSubview:self.enddatePicker];
    
    popoverContent.view = popoverView;
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    //popoverController.delegate=self;
    
    [self.popOverController setPopoverContentSize:CGSizeMake(320, 250) animated:NO];
    [self.popOverController presentPopoverFromRect:CGRectMake(self.endTimeLabel.frame.origin.x, self.endTimeLabel.frame.origin.y+2, self.endTimeLabel.frame.size.width, self.endTimeLabel.frame.size.height)  inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


-(void) saveEndTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"];
    
    [self.endTimeLabel setText:[outputFormatter stringFromDate:self.enddatePicker.date]];
    [self.popOverController dismissPopoverAnimated:YES];
    
    
}

- (void)completedWithDate:(NSDate *)selectedDate
{
    if ([selectedDate compare:[NSDate date]] == NSOrderedDescending)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        if (self.isStartDate)
        {
            self.startDate = selectedDate;
            if ([self.startDate compare:self.endDate] == NSOrderedAscending)
            {
                self.startDateLabel.text = [dateFormatter stringFromDate:selectedDate];
            }
            else
            {
                self.startDateLabel.text = [dateFormatter stringFromDate:selectedDate];
                self.endDateLabel.text = [dateFormatter stringFromDate:selectedDate];
                self.endDate = selectedDate;
            }
        }
        else
        {
            self.endDate = selectedDate;
            if ([self.endDate compare:self.startDate] == NSOrderedDescending)
            {
                self.endDateLabel.text = [dateFormatter stringFromDate:selectedDate];
            }
            else
            {
                self.startDateLabel.text = [dateFormatter stringFromDate:selectedDate];
                self.endDateLabel.text = [dateFormatter stringFromDate:selectedDate];
                self.startDate = selectedDate;
            }
        }
    }
    [self.ocCalVC.view removeFromSuperview];
}

-(void)completedWithNoSelection
{
    [self.ocCalVC.view removeFromSuperview];
}
@end
