/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 Raymond Lai (TranceLove) <airwave209gt@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <Cordova/CDVPluginResult.h>
#import "RTCSessionDescriptionObserver+Internal.h"

@implementation RTCSessionDescriptionObserver
{
    id<CDVCommandDelegate> _delegate;
    CDVInvokedUrlCommand* _command;
    RTCPeerConnectionHolder* _connection;
}

-(id) initWithDelegate:(id<CDVCommandDelegate>)commandDelegate
               command:(CDVInvokedUrlCommand*)command
            connection:(RTCPeerConnectionHolder*)connection
{
    if([super init])
    {
        _command = command;
        _delegate = commandDelegate;
        _connection = connection;

    }
    return self;
}

-(void) peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
{
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys: sdp.type, @"type", sdp.description, @"sdp", nil];
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsDictionary:dict];

    [_delegate sendPluginResult:result callbackId:_command.callbackId];
}

-(void) peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"Have error? %d", error != nil);

    CDVPluginResult *result = nil;
    if(error != nil)
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:error.description];
    }
    else
    {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }

    [_delegate sendPluginResult:result callbackId:_command.callbackId];
}

@end
