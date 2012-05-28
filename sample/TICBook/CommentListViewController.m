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

#import "CommentListViewController.h"

@interface CommentListViewController() <FBConnectorDelegate>{
    FBBaseObject *_currentObj;
    NSMutableArray  *_commentList;
    NSMutableArray  *_requests;
}

@end

@implementation CommentListViewController
@synthesize currentObj = _currentObj;
@synthesize commentList = _commentList;
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
    for (id requestId in _requests)
        [[FBConnector fbConnectorInstance] removeDeletegate:self withRequestId:requestId];
    
    [_requests release];
    [_currentObj release];
    [_commentList release];
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
    
    self.commentList = nil;
    self.requests = nil;
    
    _commentList = [[NSMutableArray alloc] init];
    _requests = [[NSMutableArray alloc] init];

    
    [self getMoreComments:nil];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    FBComment *comment = [_commentList objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.message;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"from:%@,%@ %@",
                                 comment.owner.name,
                                 comment.like_count > 0 ?  [NSString stringWithFormat:@" likes:%d,", comment.like_count]:@"",
                                 comment.user_likes ? @"unlike" : @"like",
                                 nil];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    FBComment *comment = [_commentList objectAtIndex:indexPath.row];
    
    return comment.canRemove;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        FBComment *comment = [_commentList objectAtIndex:indexPath.row];
        id rq = [[FBConnector fbConnectorInstance] deleteComment:comment withDelegate:self];
        [_requests addObject:rq];
        [_commentList removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];        
        [tableView endUpdates];
        [self.tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    FBComment *comment = [_commentList objectAtIndex:indexPath.row];
    id rq = nil;
    if (comment.user_likes)
    {
        rq = [[FBConnector fbConnectorInstance] removeLike:comment withDelegate:self];
    }
    else
    {
        rq = [[FBConnector fbConnectorInstance] addLikeTo:comment withDelegate:self];
    }
    
    if (rq)
        [_requests addObject:rq];
}

- (IBAction)getMoreComments:(id)sender
{
    id newRequestId = [[FBConnector fbConnectorInstance]
                       commentsOfObject:self.currentObj
                       offset:[_commentList count]
                       limit:25
                       withDelegate:self];
    [_requests addObject:newRequestId];
}

- (IBAction)edit:(id)sender
{
    [self.tableView reloadData];
    if ([self.tableView isEditing])
    {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                      target:self 
                                      action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];

        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                      target:self 
                                      action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];

        [self.tableView setEditing:YES animated:YES];
    }
}
#pragma mark - TICFBConnectorDelegate Methods

- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    [_requests removeObject:requestId];
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{
    [_requests removeObject:requestId];
    NSLog(@"error : %@", error);
}

- (void)didGetComments:(id)requestId withList:(FBCommentList *)comments
{
    [_requests removeObject:requestId];
    [_commentList addObjectsFromArray:comments.objects];
    [self.tableView reloadData];
    if ([comments hasMore])
    {        
        [self getMoreComments:nil];
    }
    else
    {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                      target:self 
                                      action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];
    }
}
@end
