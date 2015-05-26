//
//  RTCSessionDescriptionObserver+Internal.m
//  WebRTCApp
//
//  Created by Raymond Lai on 25/5/15.
//
//

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

}

@end
