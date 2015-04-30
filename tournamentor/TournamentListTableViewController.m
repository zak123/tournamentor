//
//  TournamentListTableViewController.m
//  tournamentor
//
//  Created by Zachary Mallicoat on 4/18/15.
//  Copyright (c) 2015 Zachary Mallicoat. All rights reserved.
//

#import "TournamentListTableViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>
#import "WebViewController.h"
#import "AddParticipantsTableViewController.h"

@interface TournamentListTableViewController () <UIActionSheetDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray *tournaments;



@end

@implementation TournamentListTableViewController {
    MBProgressHUD *_hud;
    NSIndexPath *longPressedTournament;
    BOOL shouldAnimate;
    BOOL didLoad;
}


-(void)viewWillAppear:(BOOL)animated{
    if (!didLoad) {
    ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc]init];
    
    [communicator getTournaments:self.user.name withKey:self.user.apiKey block:^(NSArray *tournamentsArray, NSError *error) {
        
        
        if (error) {
            
            shouldAnimate = NO;
            [self.refreshControl endRefreshing];
            NSLog(@"Error getting tournaments: %@", error);
            
            if (self.user.apiKey.length < 1) {
            }
            else {
                [self.refreshControl endRefreshing];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Your sign in information is not valid or network is too slow. You can try to sign out and sign back in again." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [alert addButtonWithTitle:@"OK"];
                [alert show];
                
                //                [self performSegueWithIdentifier:@"needsApiKey" sender:self];
                //            [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                _tournaments = [[tournamentsArray reverseObjectEnumerator] allObjects];
                
              
                shouldAnimate = NO;
                
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                
                
            });
            
        }
        
        
        
    }];
    
    }
    
    
    

    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    shouldAnimate = YES;
    didLoad = YES;
    // show refresh controll (pull2refresh)
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.267 green:0.267 blue:0.267 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateTournaments)
                  forControlEvents:UIControlEventValueChanged];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.267 green:0.267 blue:0.267 alpha:1];
    
//    [self showActionSheet];
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc]
                                      initWithImage:[UIImage imageNamed:@"signout"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(signOut)];
    
    self.navigationItem.leftBarButtonItem = signOutButton;
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    
    lpgr.minimumPressDuration = 0.6; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"Loading";
    
    
    self.user = [[User alloc]init];
    
    self.user.name = [[SSKeychain accountsForService:@"Challonge"][0] valueForKey:@"acct"];
    self.user.apiKey = [SSKeychain passwordForService:@"Challonge" account:self.user.name];
    
    [self setTitle:@"Tournaments"];
    
    [self updateTournaments];
    
    
    
}


- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

-(void) signOut {
    // sign user out (delete keychain) so that they can then reset the keychain to their desired challonge username
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    
    NSArray *accounts = [query fetchAll:nil];
    
    for (id account in accounts) {
        
        SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
        
        query.service = @"Challonge";
        query.account = [account valueForKey:@"acct"];
        
        [query deleteItem:nil];
        
    }

    
//    [[SSKeychain accountsForService:@"Challonge"][0] valueForKey:@"acct"];
    
    [self performSegueWithIdentifier:@"needsApiKey" sender:self];

}

-(void) updateTournaments {
    [_hud show:YES];
    
    ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc]init];
    
    [communicator getTournaments:self.user.name withKey:self.user.apiKey block:^(NSArray *tournamentsArray, NSError *error) {
        
        
        if (error) {
            didLoad = NO;
            [_hud hide:YES];
            [self.refreshControl endRefreshing];
            NSLog(@"Getting tournaments failed with error: %@", error);
            
            if (self.user.apiKey.length < 1) {
                [self performSegueWithIdentifier:@"needsApiKey" sender:self];

            }
            else {
                [self.refreshControl endRefreshing];

                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Your sign in information is not valid or network is too slow. You can try to sign out and sign back in again." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [alert addButtonWithTitle:@"OK"];
                [alert show];
                
            }
        }
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                _tournaments = [[tournamentsArray reverseObjectEnumerator] allObjects];
                didLoad = NO;
                
                shouldAnimate = YES;
                [self.tableView reloadData];
                [_hud hide:YES];
                [self.refreshControl endRefreshing];

                
 
                
                
            });
            
        }
        
        
        
    }];

    
    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        
        longPressedTournament = [self.tableView indexPathForRowAtPoint:p];
        if (longPressedTournament == nil) {
        } else {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:longPressedTournament];
            if (cell.isHighlighted) {
                [self showActionSheetForCell];
            }
        }
    }
}



-(void)showActionSheetForCell {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Tournament"
                                                    otherButtonTitles:@"Start Tournament", @"Reset The Bracket", @"End Tournament", nil];
    
    [actionSheet showInView:self.view];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc]init];
    Tournament *selectedTournament = self.tournaments[longPressedTournament.row];

    
    if (alertView.tag == 100) {
        
        if (buttonIndex == 1) {
            
            [communicator deleteTournament:selectedTournament.tournamentURL withUsername:self.user.name andAPIKey:self.user.apiKey block:^(NSError *error) {
                if (!error) {
                    [self updateTournaments];
                }
                else {
                    NSLog(@"%@", error);
                }
            }];
            
        }

    }
    if (alertView.tag == 101) {
        
        [communicator resetTournament:selectedTournament.tournamentURL withUsername:self.user.name andAPIKey:self.user.apiKey block:^(NSError *error) {
            if (!error) {
                [self updateTournaments];
                
            }
            else {
                NSLog(@"Error resetting tournament: %@", error);
            }
        }];

    }
 }



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc]init];
    Tournament *selectedTournament = self.tournaments[longPressedTournament.row];
    NSString *deleteMessage = [NSString stringWithFormat:@"Are you sure you want to delete %@", selectedTournament.tournamentName];
    NSString *resetMessage = [NSString stringWithFormat:@"Are you sure you want to reset the bracket for %@", selectedTournament.tournamentName];
    
    if (buttonIndex == 0) {
        UIAlertView *confirmation = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:deleteMessage  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        confirmation.tag = 100;
        [confirmation show];
        
        // delete tournament at this index
        
    }
    if (buttonIndex == 1) {
        [communicator startTournament:selectedTournament.tournamentURL withUsername:self.user.name andAPIKey:self.user.apiKey block:^(NSError *error) {
            if (!error) {
                [self updateTournaments];

            }
            else {
                NSLog(@"Error starting tournament: %@", error);
            }
        }];
        
    }
    if (buttonIndex == 2) {
        
        UIAlertView *confirmation = [[UIAlertView alloc]initWithTitle:@"Are you sure?" message:resetMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        confirmation.tag = 101;
        [confirmation show];
}
    if (buttonIndex == 3) {
        [communicator endTournament:selectedTournament.tournamentURL withUsername:self.user.name andAPIKey:self.user.apiKey block:^(NSError *error) {
            if (!error) {
                [self updateTournaments];

            }
            else {
                NSLog(@"Error ending tournament: %@", error);
            }
        }];
    }
  
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tournaments.count;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    shouldAnimate = NO;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TournamentListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Tournament *cellTourn = _tournaments[indexPath.row];
    
    
    cell.tournamentNameLabel.text = cellTourn.tournamentName;
    
    if ([cellTourn.state isEqual:@"pending"]) {
        cell.tournamentImage.image = [UIImage imageNamed:@"pending"];
    }
    if ([cellTourn.state isEqual:@"underway"]) {
        cell.tournamentImage.image = [UIImage imageNamed:@"underway"];
    }
    if ([cellTourn.state isEqual:@"complete"]) {
        cell.tournamentImage.image = [UIImage imageNamed:@"complete"];
    }
    
    float progressFloat = [cellTourn.progress floatValue];
    
    cell.backgroundColor = [UIColor clearColor];
    int fillWidth = (progressFloat/100.0) * cell.frame.size.width;
    
    if (indexPath.row & 1) {
        cell.backgroundColor = [UIColor colorWithRed:0.267 green:0.267 blue:0.267 alpha:1];
    }
    else {
        cell.backgroundColor = [UIColor colorWithRed:0.231 green:0.231 blue:0.231 alpha:1];
    }
    
    if (shouldAnimate) {
    __block CGRect rect = CGRectMake(0, 70, 0, cell.frame.size.height-80);
    __block UIView * view = [[UIView alloc] initWithFrame:rect];

    view.backgroundColor = [UIColor colorWithRed:0.373 green:0.706 blue:0.376 alpha:1];
    view.tag = 100;
    
    
    for (UIView *subview in cell.contentView.subviews) {
        if (subview.tag == 100) {
            [subview removeFromSuperview];
        }
    }
    
    [cell.contentView addSubview:view];
    [cell.contentView sendSubviewToBack:view];
    
    
    [UIView animateWithDuration:1 animations:^{

        rect.size.width = fillWidth;
        view.frame = rect;
    }];
    }
    else {
        __block CGRect rect = CGRectMake(0, 70, fillWidth, cell.frame.size.height-80);
        __block UIView * view = [[UIView alloc] initWithFrame:rect];
        
        view.backgroundColor = [UIColor colorWithRed:0.373 green:0.706 blue:0.376 alpha:1];
        view.tag = 100;
        
        
        for (UIView *subview in cell.contentView.subviews) {
            if (subview.tag == 100) {
                [subview removeFromSuperview];
            }
        }
        
        [cell.contentView addSubview:view];
        [cell.contentView sendSubviewToBack:view];
        

    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Tournament *cellTourn = _tournaments[indexPath.row];
    
    if([cellTourn.state isEqualToString:@"pending"]){

        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        AddParticipantsTableViewController *addParticipantsTableViewController;
        addParticipantsTableViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"AddParticipantsTableViewControllerStoryboardID"];

        addParticipantsTableViewController.tournament = self.tournaments[indexPath.row];
        addParticipantsTableViewController.currentUser = self.user;
        
        [self.navigationController pushViewController:addParticipantsTableViewController animated:YES];
        
    }
    else if ([cellTourn.state isEqualToString:@"underway"] || [cellTourn.state isEqualToString:@"complete"]){

        [self performSegueWithIdentifier:@"showMatches" sender:cellTourn];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"showMatches"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        MatchListTableViewController *dVC = (MatchListTableViewController *)segue.destinationViewController;
        
        dVC.selectedTournament = self.tournaments[indexPath.row];
        dVC.currentUser = self.user;
    }
    
    if ([segue.identifier isEqualToString:@"addTournament"]) {
        
        
        NewTournamentViewController *dVC = (NewTournamentViewController *)segue.destinationViewController;
        
        dVC.currentUser = self.user;
        
    }
    
}


@end
