//
//  AddParticipantsTableViewController.m
//  tournamentor
//
//  Created by Zachary Mallicoat on 4/22/15.
//  Copyright (c) 2015 Zachary Mallicoat. All rights reserved.
//

#import "AddParticipantsTableViewController.h"
#import "TournamentListTableViewController.h"
#import <MBProgressHUD.h>


@interface AddParticipantsTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *counter;
@property (weak, nonatomic) IBOutlet UIButton *addUsersAndStart;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (nonatomic) NSMutableArray *participantsArray;
@property (nonatomic) NSMutableArray *participantCountArray;
@property (nonatomic) NSMutableArray *existingParticipantsArray;
@property (nonatomic) NSMutableArray *extraParticipantsArray;
@property (nonatomic) BOOL hasParticipants;

@end

@implementation AddParticipantsTableViewController {
    int num;
    MBProgressHUD *hud;
}
-(void)viewDidLoad {
    
    self.participantsArray = [[NSMutableArray alloc]init];
    self.participantCountArray = [[NSMutableArray alloc]init];
    self.existingParticipantsArray = [[NSMutableArray alloc] init];
    self.extraParticipantsArray = [[NSMutableArray alloc] init];
    
    self.minusButton.hidden = YES;
    self.plusButton.hidden = YES;
    
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithTitle:@"Add Users" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    [hud show:YES];
    
        ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc] init];
        
        [communicator getParticipants:self.tournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey block:^(NSArray *participants, NSError *error) {
            if (!error){
                
                self.minusButton.hidden = NO;
                self.plusButton.hidden = NO;
                
                
                
                if (participants.count > 0){
                    self.hasParticipants = YES;
                }
                
                [self.existingParticipantsArray addObjectsFromArray:participants];
                [self.participantsArray addObjectsFromArray:participants];
                
                for (int i = 0; i < participants.count; i++){
                    num = i + 1;
//                    Participant *object = [[Participant alloc]init];
//                    [self.participantsArray addObject:object.name];
                }
                NSString *strFromInt = [NSString stringWithFormat:@"%d",num];
                self.counter.text = strFromInt;
                
                if (self.participantsArray.count > 0){
                    int i;
                    for (i=0;i<self.participantsArray.count; i++){
                        [self.participantCountArray addObject:[NSString stringWithFormat:@"#%d", i+1]];
                    }
                }
                
                
                [self.participantsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([[self existingParticipantsArray] containsObject:obj] == NO)
                    {
                        [self.extraParticipantsArray addObject:obj];
                    }
                }];
               // __extraParticipantsArray[0] = self.existingParticipantsArray[self.existingParticipantsArray.count];
                
                [self.tableView reloadData];
                
                [hud hide:YES];
            }
            else {
                NSLog(@"Add participants error:%@", error);
                [hud hide:YES];
            }
        }];
}


-(void)viewWillAppear:(BOOL)animated {
    if (self.extraParticipantsArray.count == 0) {
        [self.addUsersAndStart setTitle:@"Start Tournament" forState:UIControlStateNormal];
    }
}


-(void)done {
    
    if (self.hasParticipants){
        
        ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc] init];
        
        [communicator updateParticipants:self.tournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey withParticipants:self.extraParticipantsArray block:^(NSError *error) {
            
            if(!error){
                [self performSegueWithIdentifier:@"doneEditingTournament" sender:self];
            }
            else{
            }
        }];
        
    }
    else{

        
        
        ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc] init];
        
        [communicator updateParticipants:self.tournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey withParticipants:self.participantsArray block:^(NSError *error) {

            if(!error){
                [self performSegueWithIdentifier:@"doneEditingTournament" sender:self];
            }
            else{
                NSLog(@"Error adding participants: %@", error);
            }
        }];
    }

}
     
- (IBAction)pushedAddUsersAndStart:(id)sender {
    
    if (self.hasParticipants){
        
        ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc] init];
        
        [communicator updateParticipants:self.tournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey withParticipants:self.extraParticipantsArray block:^(NSError *error) {
            
            if(!error){
                [communicator startTournament:self.tournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey block:^(NSError *error) {
                    if(!error) {
                        [self performSegueWithIdentifier:@"doneEditingTournament" sender:self];
                    }
                    
                }];
            }
            else{
                
            }
        }];
        
        
        
    }
    else{
        ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc] init];
        
        [communicator startTournament:self.tournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey block:^(NSError *error) {
            if(!error) {
                [self performSegueWithIdentifier:@"doneEditingTournament" sender:self];
            }
            
        }];
    }
}

     
- (IBAction)addRow:(id)sender {
    num++;
    
    [self.addUsersAndStart setTitle:@"Add Users + Start" forState:UIControlStateNormal];
    
    self.counter.text = [NSString stringWithFormat:@"%i",num];
    Participant *newParticipant = [[Participant alloc]init];
    
    
    [self.participantsArray addObject:newParticipant];
    
    [self.extraParticipantsArray addObject:newParticipant];
    
    [self.participantCountArray addObject:[NSString stringWithFormat:@"#%d",num]];

//    [self.participantsArray addObject:self.participantCountArray[num]];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.participantsArray.count-1 inSection:0];
//    Participant *object = [self.participantsArray objectAtIndex:indexPath.row];
//    AddParticipantTableViewCell *myCell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    myCell.participantName.text = object.name;
    
    [self.tableView reloadData];
    
}
- (IBAction)deleteRow:(id)sender {

 
    if (self.extraParticipantsArray.count > 0) {
        
        num--;
        self.counter.text = [NSString stringWithFormat:@"%i",num];
        
        [self.participantsArray removeLastObject];
        
        [self.extraParticipantsArray removeLastObject];
        
        [self.participantCountArray removeLastObject];
        
        
        [self.tableView reloadData];
    }
    if (self.extraParticipantsArray.count == 0) {
        [self.addUsersAndStart setTitle:@"Start Tournament" forState:UIControlStateNormal];

    }
    
    

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.participantsArray.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddParticipantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    Participant *object = [self.participantsArray objectAtIndex:indexPath.row];
    [cell setupParticipant:object andTag:indexPath.row andParticipantsCount:self.participantCountArray];
    
    if (indexPath.row & 1) {
        cell.backgroundColor = [UIColor colorWithRed:0.267 green:0.267 blue:0.267 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:1];
    }
    
    [[cell.participantName superview] bringSubviewToFront:cell.participantName];
    
    
    return cell;
    
}



@end