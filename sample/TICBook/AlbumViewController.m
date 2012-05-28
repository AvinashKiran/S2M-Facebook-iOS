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

#import "AlbumViewController.h"
#import "PhotoViewController.h"

@interface PhotoWrapper : NSObject {
    UIImage     *_photoImage;
    id          _requestId;
    FBPhoto    *_photoObj;
    BOOL        _isRequested;
}

@property (nonatomic, retain) UIImage   *photoImage;
@property (nonatomic, assign) id        requestId;
@property (nonatomic, retain) FBPhoto  *photoObj;
@property (nonatomic, assign) BOOL      isRequested;

@end

@implementation PhotoWrapper

@synthesize photoImage = _photoImage;
@synthesize requestId = _requestId;
@synthesize photoObj = _photoObj;
@synthesize isRequested = _isRequested;

- (void)dealloc
{
    [_photoObj release];
    [_photoImage release];
    [super dealloc];
}

@end

@interface AlbumViewController() <FBConnectorDelegate>{
    NSMutableDictionary  *_photoDic;
    NSMutableArray  *_requests;
    NSMutableArray  *_photos;
    FBAlbum         *_currentAlbum;
    
}


@end

@implementation AlbumViewController
@synthesize photos = _photos;
@synthesize requests = _requests;
@synthesize photoDic = _photoDic;
@synthesize currentAlbum = _currentAlbum;
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
    [_currentUser release];
    [_photos release];
    [_requests release];
    [_photoDic release];
    [_currentAlbum release];
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
    self.photos = nil;
    self.requests = nil;
    self.photoDic = nil;
    [self.tableView reloadData];
    _photos = [[NSMutableArray alloc] init];
    _requests = [[NSMutableArray alloc] init];
    _photoDic = [[NSMutableDictionary alloc] init];
    self.navigationItem.title = self.currentAlbum.name;
    id requestId = [[FBConnector fbConnectorInstance] photosOfAlbum:self.currentAlbum
                                                             offset:0
                                                              limit:25
                                                       withDelegate:self];
    [_requests addObject:requestId];
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
    return [_photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    PhotoWrapper *wrapperPhoto = [self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text = wrapperPhoto.photoObj.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"id : %@", wrapperPhoto.photoObj.uid];
    UIImageView *imageView = cell.imageView;
    imageView.image = nil;
    
    PhotoWrapper *wrapperObject = [self.photos objectAtIndex:indexPath.row];
    if (wrapperObject)
    {
        cell.imageView.image = wrapperObject.photoImage;
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
    
    PhotoWrapper *wrapperPhoto = [self.photos objectAtIndex:indexPath.row];
    PhotoViewController *photoView = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
    photoView.currentPhoto = wrapperPhoto.photoObj;
    [self.navigationController pushViewController:photoView animated:YES];
    [photoView release];
}


#pragma mark - TICFBConnectorDelegate Methods


- (void)didRequestSuccess:(id)requestId withResult:(id)result
{
    
}

- (void)didRequestFail:(id)requestId userCancelled:(BOOL)cancelled withError:(NSError *)error
{
    
}

- (void)didGetPhotosOfAlbum:(id)requestId withList:(FBAlbumPhotoList *)photoList
{
    [self.requests removeObject:requestId];
    
    for (FBPhoto *photo in photoList.objects)
    {
        PhotoWrapper *newPhoto = [[PhotoWrapper alloc] init];
        newPhoto.photoObj= photo;
        newPhoto.isRequested = NO;
        newPhoto.photoImage = nil;
        newPhoto.requestId = nil;
        [self.photos addObject:newPhoto];
        [newPhoto release];
    }
    
    [self.tableView reloadData];
    if ([photoList hasMore])
    {
        id requestId = [[FBConnector fbConnectorInstance] photosOfAlbum:self.currentAlbum 
                                                                 offset:[self.photos count] 
                                                                  limit:photoList.limit    
                                                           withDelegate:self];
        [self.requests addObject:requestId];
        return;
    }
    [self.tableView reloadData];
    
    PhotoWrapper *wrapperObject = nil;
    for (PhotoWrapper *photoWrapper in self.photos)
    {
        if (photoWrapper.isRequested)
            continue;
        wrapperObject = photoWrapper;
        break;
    }

    id imageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:wrapperObject.photoObj
                         imageType:FBImageType_thumbnail
                         withDelegate:self];
    wrapperObject.isRequested = YES;
    [self.requests addObject:imageRequestId];
    [self.photoDic setObject:wrapperObject forKey:imageRequestId];
    
}
- (void)didNotGetPhotosOfAlbum:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
}


- (void)didDownloadImage:(id)requestId withImageData:(UIImage *)image
{

    [self.requests removeObject:requestId];
    
    PhotoWrapper *recievedWrapper = [self.photoDic objectForKey:requestId];
    recievedWrapper.photoImage = image;
    
    [self.tableView reloadData];
    
    PhotoWrapper *wrapperObject = nil;
    for (PhotoWrapper *photoWrapper in self.photos)
    {
        if (photoWrapper.isRequested)
            continue;
        wrapperObject = photoWrapper;
        break;
    }
    
    if (wrapperObject == nil)
        return;
    
    id imageRequestId = [[FBConnector fbConnectorInstance] 
                         downloadImage:wrapperObject.photoObj
                         imageType:FBImageType_thumbnail
                         withDelegate:self];
    wrapperObject.isRequested = YES;
    [self.requests addObject:imageRequestId];
    [self.photoDic setObject:wrapperObject forKey:imageRequestId];
}
- (void)didNotDownloadImage:(id)requestId withError:(NSError *)error
{
    NSLog(@"error request : %@ , info : %@", requestId, error);
    UIImage *dummyImage = [[[UIImage alloc] init] autorelease];
    [self didDownloadImage:requestId withImageData:dummyImage];
}


@end
