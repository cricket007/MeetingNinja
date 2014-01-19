//
//  iWinRegisterViewController.m
//  MeetingBuilder
//
//  Created by CSSE Department on 10/2/13.
//  Copyright (c) 2013 CSSE371. All rights reserved.
//

#import "iWinRegisterViewController.h"
#include <CommonCrypto/CommonDigest.h>
#import "iWinAppDelegate.h"
#import "Contact.h"

@interface iWinRegisterViewController ()
@property (strong, nonatomic) iWinAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation iWinRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validatePhoneNumber
{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if (self.phoneNumberField.text.length == 0) {
        return YES;
    }
    if (self.phoneNumberField.text.length > 12 || self.phoneNumberField.text.length < 8) {
        return NO;
    }
    NSArray *phoneParts = [self.phoneNumberField.text componentsSeparatedByString:@"-"];
    for (NSString *stringPart in phoneParts) {
        if ([stringPart rangeOfCharacterFromSet:notDigits].location != NSNotFound)
        {
                        return NO;
        }
    }
    return YES;

}

- (NSString*)validateRegistration
{
    NSString *name = [[self.nameField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [[self.emailField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordField text];
    NSString *confirmPassword = [self.confirmPasswordField text];
    NSString *emailSymbol = @"@";
    
    if (name.length == 0) {
        return @"Please enter your name!";
    }
    if (password.length < 6) {
        return @"Password must be at least 6 characters!";
    }
    if (![password isEqualToString:confirmPassword]) {
        return @"Please enter matching passwords!";
    }
    if (![self validatePhoneNumber]) {
        return @"Please enter a valid phone number!";
    }
    if (email.length == 0 || [email rangeOfString:emailSymbol].location == NSNotFound) {
        return @"Please enter a valid email address!";
    }
    return @"";
}

- (IBAction)onClickRegister:(id)sender
{
    NSString *error = [self validateRegistration];
    if (error.length == 0)
    {
        NSString *email = [[self.emailField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = [self sha256HashFor: [self.passwordField text]];
        
        //register
        NSArray *keys = [NSArray arrayWithObjects:@"name", @"password", @"email", @"phone", @"company", @"title", @"location", nil];
        NSArray *objects = [NSArray arrayWithObjects:self.nameField.text, password, email, self.phoneNumberField.text, self.companyField.text, self.titleField.text, self.locationField.text,nil];
        
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSData *jsonData;
        NSString *jsonString;
        
        if ([NSJSONSerialization isValidJSONObject:jsonDictionary])
        {
            jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSString *url = [NSString stringWithFormat:@"http://csse371-04.csse.rose-hulman.edu/User/"];
        
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
        NSInteger userID = -1;
        if (error) {
            // Handle error.
        }
        else
        {
            NSError *jsonParsingError = nil;
            NSDictionary *deserializedDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
            userID = [[deserializedDictionary objectForKey:@"userID"] integerValue];
            [self createContactWithID:userID withEmail:email withPassword:self.passwordField.text];
        }
        [self.registerDelegate onRegister:userID];
    }
    else
    {
        [self failRegisterValidation:error];
    }

}

-(void)createContactWithID:(NSInteger)userID withEmail:(NSString*)email withPassword:(NSString*)password
{
    NSArray *result = [self getEntity:@"Contact" withID:userID];
    NSError *error;
    if ([result count] == 0)
    {
        NSManagedObject *newSetting = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
        [newSetting setValue:[NSNumber numberWithInt:userID] forKey:@"userID"];
        [newSetting setValue:email forKey:@"email"];
        [self.context save:&error];
    }
    else
    {
        Contact *updateContact = (Contact*)[result objectAtIndex:0];
        [updateContact setValue:email forKey:@"email"];
        [self.context save:&error];
    }
    [self createSettingsWithID:userID withEmail:email withPassword:password];
}

-(void)createSettingsWithID:(NSInteger)userID withEmail:(NSString*)email withPassword:(NSString*)password
{
    NSArray *result = [self getEntity:@"Settings" withID:userID];
    NSError *error;
    if ([result count] == 0)
    {
        NSManagedObject *newSetting = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.context];
        NSError *error;
        [newSetting setValue:[NSNumber numberWithInt:userID] forKey:@"userID"];
        [newSetting setValue:email forKey:@"email"];
        [newSetting setValue:password forKey:@"password"];
        [self.context save:&error];
    }
    else
    {
        Contact *updateSettings = (Contact*)[result objectAtIndex:0];
        [updateSettings setValue:email forKey:@"email"];
        [updateSettings setValue:password forKey:@"password"];
        [self.context save:&error];
    }
}

-(NSArray*)getEntity:(NSString*)entity withID:(NSInteger)userID
{
    NSEntityDescription *entityDesc;
    if ([entity isEqualToString:@"Settings"])
    {
        entityDesc = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.context];
    }
    else
    {
        entityDesc = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.context];
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %d", userID];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request
                                                  error:&error];
    return result;
}

-(NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (void)failRegisterValidation:(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)onClickCancel:(id)sender
{
    [self.registerDelegate onCancel];
}

@end