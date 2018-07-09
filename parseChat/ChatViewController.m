//
//  ChatViewController.m
//  parseChat
//
//  Created by Lizbeth Alejandra Gonzalez on 7/9/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "ChatViewController.h"
#import "Parse.h"
#import "ChatCell.h"



@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    self.chatTableView.rowHeight = 130;
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(refreshControl) userInfo:nil repeats:true];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)send:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_fbu2018"];
    chatMessage[@"text"] = self.message.text;
    chatMessage[@"user"] = PFUser.currentUser; // this is a key
    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The message was saved!");
        } else {
            NSLog(@"Problem saving message: %@", error.localizedDescription);
        }
    }];
    //On successful message save, clear the text from the text chat field.
    self.message.text = @"";
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath: indexPath];
    PFObject *chatMessage = self.messages[indexPath.row]; // self.filteredData
    self.message.text = chatMessage[@"text"];
    PFUser *user = chatMessage[@"user"];
    if (user != nil) {
        // User found! update username label with username
        cell.usernameLabel.text = user.username;
    } else {
        // No user found, set default username
        cell.usernameLabel.text = @"🤖";
    }
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
    
}

-(void)beginRefresh {

    PFQuery *query = [PFQuery queryWithClassName:@"Message_fbu2018"];
    query.limit = 20; //what you can retrieve
    [query orderByDescending:@"createdAt"]; //recent
    [query includeKey:@"user"]; // make sure attribute of message is included
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.messages = posts;
            
            // do something with the array of object returned by the call
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.chatTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    
    
    
 
  
   
}




@end
