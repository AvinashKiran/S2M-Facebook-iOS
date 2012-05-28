/*
 Copyright 2012 SinnerSchrader Mobile GmbH.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "FriendListViewController.h"
#import "FeedListViewController.h"

@interface FriendWrapper : NSObject {
    UIImage     *_friendImage;
    id          _requestId;
    FBFriend    *_friendObj;
    BOOL        _isRequested;
}
@property (nonatomic, retain) UIImage   *friendImage;
@property (nonatomic, assign) id        requestId;
@property (nonatomic, retain) FBFriend  *friendObj;
@property (nonatomic, assign) BOOL      isRequested;
@end

@implementation FriendWrapper

@synthesize friendImage = _friendImage;
@synthesize requestId = _requestId;
@synthesize friendObj = _friendObj;
@synthesize isRequested = _isRequested;

- (void)dealloc
{
    [_friendObj release];
    [_friendImage release];
    [super dealloc];
}
@end

@interface FriendListViewController() <FBConnectorDelegate>{
    NSMutableArray  *_friends;
    NSMutableArray  *_requests;
    NSMutableDictionary *friendDic;
    BOOL        _isDownloadingImage;
    NSUInteger      _offset;
    NSUInteger      _limit;
    FBUser         *_currentUser;
}


@end

@implementation FriendListViewController

@synthesize friendDic = _friendDic;
@synthesize friends = _friends;
@synthesize currentUser = _currentUser;
@synthesize requests = _requests;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    FBConnector *fbConnector = [FBConnector fbConnectorInstance];
    for (id requestId in _requests)
    {
        [fbConnector removeDeletegate:self withRequestId:requestId];
    }
    
    [_friendDic release];
    [_friends release];
    [_requests release];
    [_currentUser release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    FBConnector *fbConnector = [FBConnector fbConnectorInstance];
    for (id requestId in _requests)
    {
        [fbConnector removeDeletegate:self withRequestId:requestId];
    }
    self.requests = nil;
    self.friendDic = nil;
    self.friends = nil;
    
    
    _friends = [[NSMutableArray alloc] init];
    _friendDic = [[NSMutableDictionary alloc] init];
    _requests = [[NSMutableArray alloc] init];
    _limit = 25;
    [self getFriendList:nil];
    self.navigationItem.title = @"Friends";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.requests = nil;
    self.friendDic = nil;
    self.friends = nil;
    _offset = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSUInteger row = indexPath.row;
    FriendWrapper *wrapperFriend = [self.friends objectAtIndex:row];
    cell.textLabel.text = wrapperFriend.friendObj.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"id : %@", wrapperFriend.friendObj.uid];
    UIImageView *imageView = cell.imageView;
    imageView.image = nil;
    
    FriendWrapper *wrapperObject = [self.friends objectAtIndex:indexPath.row];
    if (wrapperObject)
    {
        cell.imageView.image = wrapperObject.friendImage;
    }
    
    return cell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    FeedListViewController *newFeedListViewController = [[FeedListViewController alloc] initWithNibName:@"FeedListViewController" bundle:nil];
    FriendWrapper *selectedUser = [self.friends objectAtIndex:indexPath.row];
    newFeedListViewController.currentUser = selectedUser.friendObj;
    UINavigationController *naviController= self.navigationController;
    [naviController pushViewController:newFeedListViewController animated:YES];
    [newFeedListViewController release];
}

- (IBAction)getFriendList:(id)sender
{
    id requestId = [[FBConnector fbConnectorInstance] friendsOfUser:self.currentUser
                                                             offset:[self.friends count] 
                                                              limit:_limit
                                                       withDelegate:self];
    [self.requests addObject:requestId];
}

#pragma mark - TICFBConnectorDelegate Methods


- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{
    
}

- (void)didGetFriends:(id)requestId withList:(FBFriendList *)friendsList
{
    [self.requests removeObject:requestId];
    
    for (FBFriend *friend in friendsList.objects)
    {
        FriendWrapper *newFriend = [[FriendWrapper alloc] init];
        newFriend.friendObj = friend;
        newFriend.isRequested = NO;
        newFriend.friendImage = nil;
        newFriend.requestId = nil;
        [self.friends addObject:newFriend];
        [newFriend release];
    }
    [self.tableView reloadData];
    
    if ([friendsList hasMore])
    {
        _limit = friendsList.limit;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                      target:self 
                                      action:@selector(getFriendList:)];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if ([self.friends count] <= 0 || _isDownloadingImage == YES)
        return;
    
    
    FriendWrapper *wrapperObject = nil;
    for (FriendWrapper *friendWrapper in self.friends)
    {
        if (friendWrapper.isRequested)
            continue;
        wrapperObject = friendWrapper;
        break;
    }
    
    if (wrapperObject == nil || _isDownloadingImage == YES)
        return;
    
    id imageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:wrapperObject.friendObj
                         imageType:FBImageType_square
                         withDelegate:self];
    wrapperObject.isRequested = YES;
    [self.friendDic setObject:wrapperObject forKey:imageRequestId];
    [self.requests addObject:imageRequestId];
    
}
- (void)didNotGetFriends:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
    [self.requests removeObject:requestId];
}

- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image
{
    [self.requests removeObject:requestId];
    
    FriendWrapper *recievedWrapper = [self.friendDic objectForKey:requestId];
    recievedWrapper.friendImage = image;
    
    [self.tableView reloadData];
    
    FriendWrapper *wrapperObject = nil;
    for (FriendWrapper *friendWrapper in self.friends)
    {
        if (friendWrapper.isRequested)
            continue;
        wrapperObject = friendWrapper;
        break;
    }
    
    if (wrapperObject == nil)
    {
        _isDownloadingImage = NO;
        return;
    }
    
    _isDownloadingImage = YES;
    
    id imageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:wrapperObject.friendObj
                         imageType:FBImageType_square
                         withDelegate:self];
    wrapperObject.isRequested = YES;
    
    [self.friendDic setObject:wrapperObject forKey:imageRequestId];
    [self.requests addObject:imageRequestId];
}
- (void)didNotDownloadImage:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
    UIImage *dummyImage = [[[UIImage alloc] init] autorelease];
    [self didDownloadImage:requestId withImageData:dummyImage];
}



@end
