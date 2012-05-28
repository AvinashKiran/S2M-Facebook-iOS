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

#import "FeedListViewController.h"
#import "PostViewController.h"

@interface FeedWrapper : NSObject {
    UIImage     *_ownerImage;
    UIImage     *_feedImage;
    id          _requestId;
    FBBaseUser  *_feedFrom;
    FBPost      *_post;
}
@property (nonatomic, retain) UIImage       *ownerImage;
@property (nonatomic, retain) UIImage       *feedImage;
@property (nonatomic, assign) id            requestId;
@property (nonatomic, retain) FBPost        *post;
@property (nonatomic, retain) FBBaseUser    *feedFrom;

@end

@implementation FeedWrapper
@synthesize ownerImage = _ownerImage;
@synthesize requestId = _requestId;
@synthesize feedFrom = _feedFrom;
@synthesize post = _post;
@synthesize feedImage = _feedImage;

- (void)dealloc
{
    [_feedFrom release];
    [_ownerImage release];
    [_feedImage release];
    [_post release];
    [super dealloc];
}
@end

@interface FeedListViewController()<FBConnectorDelegate>{
    NSMutableArray  *_feeds;
    NSMutableArray  *_requests;
    NSMutableDictionary *_feedDic;
    NSMutableDictionary *_fromImageDic;
    BOOL        _isDownloadingImage;
    NSUInteger      _offet;
    NSUInteger      _limit;
    FBBaseUser         *_currentUser;
}


@end

@implementation FeedListViewController

@synthesize feeds = _feeds;
@synthesize requests = _requests;
@synthesize feedDic = _feedDic;
@synthesize currentUser = _currentUser;
@synthesize fromImageDic = _fromImageDic;

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
    
    [_feeds release];
    [_requests release];
    [_feedDic release];
    [_currentUser release];
    [_fromImageDic release];
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
    self.feedDic = nil;
    self.fromImageDic = nil;
    self.feeds = nil;
    
    
    _feeds = [[NSMutableArray alloc] init];
    _feedDic = [[NSMutableDictionary alloc] init];
    _fromImageDic = [[NSMutableDictionary alloc] init];
    _requests = [[NSMutableArray alloc] init];
    
    _offet = 0;
    _limit = 25;

    self.navigationItem.title = @"Feeds";
    [self getFeedList:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [self.feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    // Configure the cell...
    NSUInteger row = indexPath.row;
    FeedWrapper *wrapperFeed = [self.feeds objectAtIndex:row];
    cell.textLabel.text = wrapperFeed.post.message;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"from : %@", wrapperFeed.feedFrom.name];
    UIImageView *imageView = cell.imageView;
    imageView.image = nil;
    
    if (wrapperFeed)
    {
        cell.imageView.image = wrapperFeed.ownerImage;
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
    
    PostViewController *feedView = [[PostViewController alloc] initWithNibName:@"PostViewController" bundle:nil];
    feedView.currentPost = [[self.feeds objectAtIndex:indexPath.row] post];
    [self.navigationController pushViewController:feedView animated:YES];
    [feedView release];

}


- (IBAction)getFeedList:(id)sender
{
    id requestId = [[FBConnector fbConnectorInstance] feedsOfUser:(FBBaseUser *)self.currentUser
                                                           offset:_offet
                                                            limit:_limit
                                                     withDelegate:self];
    [self.requests addObject:requestId];
    self.navigationItem.rightBarButtonItem = nil;
    
}
#pragma mark - TICFBConnectorDelegate Methods


- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{
    
}

- (void)didGetFeeds:(id)requestId withList:(FBFeedList *)feed
{
    [self.requests removeObject:requestId];
    
    for (FBPost *post in feed.objects)
    {
        FeedWrapper *newPost = [[FeedWrapper alloc] init];
        newPost.feedFrom = post.owner;
        newPost.post = post;
        newPost.requestId = nil;
        newPost.ownerImage = nil;
        newPost.feedImage = nil;
        [self.feeds addObject:newPost];
        [newPost release];
    }
    
    [self.tableView reloadData];
    
    if ([feed hasMore])
    {
        _offet = feed.offset;
        _limit = feed.limit;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                      target:self 
                                      action:@selector(getFeedList:)];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    FeedWrapper *wrapperObject = nil;
    for (FeedWrapper *feedWrapper in self.feeds)
    {
        if (feedWrapper.ownerImage)
            continue;
        
        UIImage *userImage = [self.fromImageDic objectForKey:feedWrapper.feedFrom.uid];
        if (userImage)
        {
            feedWrapper.ownerImage = userImage;
            continue;
        }
        
        wrapperObject = feedWrapper;
        break;
    }
    
    if (wrapperObject == nil || _isDownloadingImage == YES)
        return;
    
    _isDownloadingImage = YES;
    
    id fromImageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:wrapperObject.feedFrom
                         imageType:FBImageType_square
                         withDelegate:self];
    
    
    
    [self.requests addObject:fromImageRequestId];
    [self.feedDic setObject:wrapperObject forKey:fromImageRequestId];

    
    
}

- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image
{
    _isDownloadingImage = NO;
    
    [self.requests removeObject:requestId];
    
    FeedWrapper *recievedWrapper = [self.feedDic objectForKey:requestId];
    recievedWrapper.ownerImage = image;
    
    [self.fromImageDic setObject:image forKey:recievedWrapper.feedFrom.uid];
    
    [self.tableView reloadData];
    
    FeedWrapper *wrapperObject = nil;
    for (FeedWrapper *feedWrapper in self.feeds)
    {
        if (feedWrapper.ownerImage)
            continue;
        
        UIImage *userImage = [self.fromImageDic objectForKey:feedWrapper.feedFrom.uid];
        if (userImage)
        {
            feedWrapper.ownerImage = userImage;
            continue;
        }
        
        wrapperObject = feedWrapper;
        break;
    }
    
    if (wrapperObject == nil)
    {
        return;
    }
    
    _isDownloadingImage = YES;
    
    id imageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:wrapperObject.feedFrom
                         imageType:FBImageType_square
                         withDelegate:self];
    
    [self.feedDic setObject:wrapperObject forKey:imageRequestId];
    [self.requests addObject:imageRequestId];
}

- (void)didNotDownloadImage:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
    UIImage *dummyImage = [[[UIImage alloc] init] autorelease];
    [self didDownloadImage:requestId withImageData:dummyImage];
}



@end
