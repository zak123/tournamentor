//
//  MatchListTableViewController.m
//  tournamentor
//
//  Created by Zachary Mallicoat on 4/21/15.
//  Copyright (c) 2015 Zachary Mallicoat. All rights reserved.
//

#import "MatchListTableViewController.h"
#import <UAProgressView.h>
#import "BracketCollectionView.h"


@interface MatchListTableViewController () < UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSArray *matches;


@property (weak, nonatomic) IBOutlet BracketCollectionView *bracketView;


@end

@implementation MatchListTableViewController

static NSString * const reuseIdentifier = @"matchCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated {
    [self setTitle:self.selectedTournament.tournamentName];
    
    ChallongeCommunicator *communicator = [[ChallongeCommunicator alloc]init];
    
    [communicator getMatchesForTournament:self.selectedTournament.tournamentURL withUsername:self.currentUser.name andAPIKey:self.currentUser.apiKey block:^(NSArray *matchArray, NSError *error) {
        NSLog(@"%@", matchArray);
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                self.matches = matchArray;
                [self.tableView reloadData];
                self.bracketView.matches = self.matches;
                
            });
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.matches.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MatchListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchCell" forIndexPath:indexPath];
    
    Match *cellMatch = _matches[indexPath.row];
    
    cell.roundLabel.text = cellMatch.state;
    
 

    if (cellMatch.score.length > 1) {
        
        cell.player1Label.text = [NSString stringWithFormat:@"%@ -", cellMatch.player1_name];
        cell.player2Label.text = [NSString stringWithFormat:@"%@ -", cellMatch.player2_name];
        
        NSArray *scoresArray = [cellMatch.score componentsSeparatedByString:@"-"];
        
        cell.player1Score.text = [NSString stringWithFormat:@"%.0f", [scoresArray[0] doubleValue]];
        
        cell.player2Score.text = [NSString stringWithFormat:@"%.0f", [scoresArray[1] doubleValue]];
        

        
    } else {
        cell.player1Label.text = cellMatch.player1_name;
        cell.player2Label.text = cellMatch.player2_name;
        cell.player1Score.text = nil;
        cell.player2Score.text = nil;
    }
    
    
    return cell;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //#warning Incomplete method implementation -- Return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //#warning Incomplete method implementation -- Return the number of items in the section
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *matchCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell
    Match *match = [[Match alloc] init];
    
    
    return matchCollectionViewCell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPickedMatch"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        MatchEditTableViewController *dVC = (MatchEditTableViewController *)segue.destinationViewController;
        
        dVC.selectedMatch = self.matches[indexPath.row];
        dVC.currentUser = self.currentUser;
        dVC.currentTournament = self.selectedTournament;
        
        
    }
    


}


@end
