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


#import "FBInternalRequest.h"
#import "Facebook.h"
@interface FBInternalRequest () <FBSessionDelegate, FBDialogDelegate, FBRequestDelegate>
{
    BOOL _cancelled;
}

@end

@implementation FBInternalRequest
@synthesize internalDelegate = _internalDelegate;
@synthesize delegate = _delegate;
@synthesize requestId = _requestId;
@synthesize cancelled = _cancelled;
@synthesize fbRequest = _fbRequest;

#pragma mark - Memory Management
- (id)init
{
    self = [super init];
    _cancelled = NO;
    return self;
}
- (void)dealloc
{    
    [_fbRequest setDelegate:(id<FBRequestDelegate>)_internalDelegate];
    _internalDelegate = nil;
    _delegate = nil;
    _internalDelegate = nil;
    _fbRequest = nil;
    [_requestId release];
    [super dealloc];
}

#pragma mark - FBSessionDelegate Methods

- (void)fbDidLogin
{
    [_internalDelegate didSessionUpdate:self tocken:nil expirationDate:nil];
}


- (void)fbDidNotLogin:(BOOL)cancelled
{
    _cancelled = cancelled;
    [_internalDelegate didRequestFail:self withError:nil];
    
}

- (void)fbDidLogout
{
    [_internalDelegate didRequestSuccess:self withResult:nil];
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    [_internalDelegate didSessionUpdate:self tocken:accessToken expirationDate:expiresAt];
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    [_internalDelegate didSessionInvalidate:self];
}

#pragma mark -  FBRequestDelegate Methods

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    [_internalDelegate didRequestFail:self withError:error];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    [_internalDelegate didRequestSuccess:self withResult:result];
}

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request
{
    // dummy method.
    // actually these protocol mothods are not optional.
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    // dummy method.
    // actually these protocol mothods are not optional.
}


/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    // dummy method.
    // actually these protocol mothods are not optional.
}


#pragma mark - FBDialogDelegate Methods

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog
{
    [_internalDelegate didRequestSuccess:self withResult:nil];
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog
{
    _cancelled = YES;
    [_internalDelegate didRequestFail:self withError:nil];
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    [_internalDelegate didRequestFail:self withError:error];
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url
{
    // it depends on the policy of Application.
    return [[UIApplication sharedApplication] openURL:url];
}


@end
