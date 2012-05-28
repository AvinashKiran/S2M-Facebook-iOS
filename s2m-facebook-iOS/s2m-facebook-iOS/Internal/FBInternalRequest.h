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

#import <Foundation/Foundation.h>

@class FBRequest;
@protocol FBConnectorDelegate;
@protocol FBInternalRequestDelegate;

@interface FBInternalRequest : NSObject
{
    id<FBInternalRequestDelegate>   _internalDelegate;
    id<FBConnectorDelegate>        _delegate;
    FBRequest                       *_fbRequest;
    NSString                         *_requestId;
    NSUInteger                      _offset;
    NSUInteger                      _limit;
}
@property (nonatomic, assign) id<FBInternalRequestDelegate>     internalDelegate;
@property (nonatomic, assign) id<FBConnectorDelegate>          delegate;
@property (nonatomic, retain) NSString                          *requestId;
@property (nonatomic, assign) FBRequest                         *fbRequest;
@property (nonatomic, readonly, getter = isCancelled) BOOL      cancelled;
@end

@protocol FBInternalRequestDelegate <NSObject>
@required
- (void)didSessionUpdate:(FBInternalRequest *)request tocken:(NSString*)token expirationDate:(NSDate*)expirationDate;
- (void)didSessionInvalidate:(FBInternalRequest *)request;
- (void)didRequestSuccess:(FBInternalRequest *)request withResult:(id)result;
- (void)didRequestFail:(FBInternalRequest *)request withError:(NSError *)error;
@end
