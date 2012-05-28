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

#import "AlbumListViewController.h"
#import "AlbumViewController.h"

@interface AlbumListViewController() <FBConnectorDelegate>{
    NSMutableArray *_albums;
    NSMutableArray *_requests;
    NSMutableArray *_images;
    NSUInteger       _downloadedImageCount;
}

@end

@implementation AlbumListViewController
@synthesize albums = _albums;
@synthesize requests = _requests;
@synthesize images = _images;
@synthesize currentUser = _currentUser;

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
    for (id requestId in self.requests)
    {
        [fbConnector removeDeletegate:self withRequestId:requestId];
    }
    
    [_albums release];
    [_requests release];
    [_images release];
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
    
    self.albums = nil;
    self.requests = nil;
    self.images = nil;
    
    _albums = [[NSMutableArray alloc] init];
    _requests = [[NSMutableArray alloc] init];
    _images = [[NSMutableArray alloc] init];
    
    id requestId = [[FBConnector fbConnectorInstance] albumsOfUser:self.currentUser
                                                            offset:0
                                                             limit:25
                                                       pagingToken:nil
                                                      withDelegate:self];
    [_requests addObject:requestId];
    self.navigationItem.title = @"Albums";
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
    return [self.albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSUInteger row = indexPath.row;
    FBAlbum *album = [self.albums objectAtIndex:row];
    cell.textLabel.text = album.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"count : %d", album.count];
    if (album.location)
    {
        NSString *newString = [NSString stringWithFormat:@"%d pics, at : %@", album.count, album.location];
        cell.detailTextLabel.text = newString;
    }
    UIImageView *imageView = cell.imageView;
    imageView.image = nil;
    
    if ([_images count] > indexPath.row) {
        UIImage *image = [_images objectAtIndex:indexPath.row];
        imageView.image = image;
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
    AlbumViewController *albumView = [[AlbumViewController alloc] initWithNibName:@"AlbumViewController" bundle:nil];
    albumView.currentAlbum = [self.albums objectAtIndex:indexPath.row];
    albumView.currentUser = self.currentUser;
    [self.navigationController pushViewController:albumView animated:YES];
    [albumView release];
    
}

#pragma mark - TICFBConnectorDelegate Methods


- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{

}

- (void)didGetAlbums:(id)requestId withList:(FBAlbumList *)albums
{
    [self.albums addObjectsFromArray:albums.objects];
    [self.requests removeObjectAtIndex:0];
    [self.tableView reloadData];
    if ([albums hasMore])
    {
        id requestId = [[FBConnector fbConnectorInstance] albumsOfUser:self.currentUser
                                                 offset:albums.offset
                                                  limit:albums.limit
                                            pagingToken:albums.token
                                           withDelegate:self];
        [self.requests addObject:requestId];
        return;
    }
    
    if ([self.albums count] <= 0)
        return;
    
    FBBaseObject *object = [[FBBaseObject alloc] init];
    FBAlbum *currentAlbum = [_albums objectAtIndex:_downloadedImageCount];
    object.uid = currentAlbum.cover_photo;
    id imageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:object
                         imageType:FBImageType_thumbnail
                         withDelegate:self];
    [self.requests addObject:imageRequestId];
    [object release];

}
- (void)didNotGetAlbums:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
}

- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image
{
    [_requests removeObjectAtIndex:0];
    _downloadedImageCount++;
    [self.images addObject:image];
    [self.tableView reloadData];
    
    if (_downloadedImageCount < [self.albums count])
    {
        FBBaseObject *object = [[FBBaseObject alloc] init];
        FBAlbum *currentAlbum = [_albums objectAtIndex:_downloadedImageCount];
        object.uid = currentAlbum.cover_photo;
        id imageRequestId = [[FBConnector fbConnectorInstance] 
                             downloadImage:object
                             imageType:FBImageType_thumbnail
                             withDelegate:self];
        [self.requests addObject:imageRequestId];
        [object release];
    }
}
- (void)didNotDownloadImage:(id)requestId withError:(NSError *)error
{
    UIImage *dummyImage = [[[UIImage alloc] init] autorelease];
    [self didDownloadImage:requestId withImageData:dummyImage];
}

@end
