/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "PersonalInfoController.h"
#import "Strings.h"

@interface PersonalInfoController ()
@property (weak, nonatomic) IBOutlet UIView *separator0;
@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UIView *separator3;

@end

@implementation PersonalInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(kUI_PersonalInfo, nil);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.labelFirstName.text = NSLocalizedString(kUI_FirstName, nil);
    self.labelLastName .text = NSLocalizedString(kUI_LastName,  nil);
    self.labelEmail    .text = NSLocalizedString(kUI_Email,     nil);
    self.labelPhone    .text = NSLocalizedString(kUI_Phone,     nil);
    
    self.textFieldFirstName .placeholder = @"tap edit to insert";
    self.textFieldLastName  .placeholder = @"tap edit to insert";
    self.textFieldEmail     .placeholder = @"tap edit to insert";
    self.textFieldPhone     .placeholder = @"tap edit to insert";
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    self.textFieldFirstName.text = [preferences stringForKey:kOpen311_FirstName];
    self.textFieldLastName .text = [preferences stringForKey:kOpen311_LastName];
    self.textFieldEmail    .text = [preferences stringForKey:kOpen311_Email];
    self.textFieldPhone    .text = [preferences stringForKey:kOpen311_Phone];
	
    self.textFieldFirstName.enabled = NO;
    self.textFieldLastName.enabled = NO;
    self.textFieldEmail.enabled = NO;
    self.textFieldPhone.enabled = NO;
    
    [self.separator0 setHidden:YES];
    [self.separator1 setHidden:YES];
    [self.separator2 setHidden:YES];
    [self.separator3 setHidden:YES];
    
    // uncomment for the view to scroll when keyboard is shown
    //[self registerForKeyboardNotifications];
    
    
    
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setValue:self.textFieldFirstName.text forKey:kOpen311_FirstName];
    [preferences setValue:self.textFieldLastName .text forKey:kOpen311_LastName];
    [preferences setValue:self.textFieldEmail    .text forKey:kOpen311_Email];
    [preferences setValue:self.textFieldPhone    .text forKey:kOpen311_Phone];
    
    [super viewWillDisappear:animated];
}

- (void) hideKeyboard {
		[self.textFieldFirstName resignFirstResponder];
    	[self.textFieldLastName resignFirstResponder];
		[self.textFieldEmail resignFirstResponder];
		[self.textFieldPhone resignFirstResponder];
}

#pragma mark - Table view handlers

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(kUI_PersonalInfo, nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = NSLocalizedString(kUI_PersonalInfo, nil);
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:78/255.0f green:84/255.0f blue:102/255.0f alpha:1];
//    label.shadowColor = [UIColor grayColor];
//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont fontWithName:@"Heiti SC" size:15];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if      (indexPath.row == 0) { [self.textFieldFirstName becomeFirstResponder]; }
    else if (indexPath.row == 1) { [self.textFieldLastName  becomeFirstResponder]; }
    else if (indexPath.row == 2) { [self.textFieldEmail     becomeFirstResponder]; }
    else if (indexPath.row == 3) { [self.textFieldPhone  becomeFirstResponder];    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing) {
        self.textFieldFirstName.clearButtonMode = UITextFieldViewModeAlways;
        self.textFieldLastName.clearButtonMode = UITextFieldViewModeAlways;
        self.textFieldEmail.clearButtonMode = UITextFieldViewModeAlways;
        self.textFieldPhone.clearButtonMode = UITextFieldViewModeAlways;

        self.textFieldFirstName.enabled = YES;
        self.textFieldLastName.enabled = YES;
        self.textFieldEmail.enabled = YES;
        self.textFieldPhone.enabled = YES;
        
        self.textFieldFirstName .placeholder = @"";
        self.textFieldLastName  .placeholder = @"";
        self.textFieldEmail     .placeholder = @"";
        self.textFieldPhone     .placeholder = @"";
        
        [self.separator0 setHidden:NO];
        [self.separator1 setHidden:NO];
        [self.separator2 setHidden:NO];
        [self.separator3 setHidden:NO];

    }
    else {
        self.textFieldFirstName.clearButtonMode = UITextFieldViewModeNever;
        self.textFieldLastName.clearButtonMode = UITextFieldViewModeNever;
        self.textFieldEmail.clearButtonMode = UITextFieldViewModeNever;
        self.textFieldPhone.clearButtonMode = UITextFieldViewModeNever;
        
        self.textFieldFirstName.enabled = NO;
        self.textFieldLastName.enabled = NO;
        self.textFieldEmail.enabled = NO;
        self.textFieldPhone.enabled = NO;
        
        self.textFieldFirstName .placeholder = @"tap edit to insert";
        self.textFieldLastName  .placeholder = @"tap edit to insert";
        self.textFieldEmail     .placeholder = @"tap edit to insert";
        self.textFieldPhone     .placeholder = @"tap edit to insert";
        
        [self.separator0 setHidden:YES];
        [self.separator1 setHidden:YES];
        [self.separator2 setHidden:YES];
        [self.separator3 setHidden:YES];
        
        
    }
}

#pragma mark - keyboard events

#define kOFFSET_FOR_KEYBOARD 30.0

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


@end
