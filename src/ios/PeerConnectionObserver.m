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
#import "PeerConnectionObserver.h"

@implementation PeerConnectionObserver
{
    id<CDVCommandDelegate> _delegate;
    NSString* _connectionID;
    NSLock *sdpMLineIndexLock;
    unsigned int _sdpMLineIndex;
}

-(id) initWithDelegate:(id<CDVCommandDelegate>)delegate
          connectionID:(NSString *)connectionID
{
    if([super init])
    {
        _delegate = delegate;
        _connectionID = connectionID;
        _sdpMLineIndex = 0;
    }
    return self;
}

//RTCPeerConnection.onaddstream
-(void) peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
{

}

//RTCPeerConnection.ondatachannel
-(void) peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    NSLog(@"Data channel opened: %@", dataChannel.label);
}

//RTCPeerConnection.onicecandidate
-(void) peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
    NSString *sdpMLineIndex = nil;
    if(candidate.sdpMLineIndex >= 0)
    {
        sdpMLineIndex = [NSString stringWithFormat: @"%d", candidate.sdpMLineIndex];
    }
    else
    {
        sdpMLineIndex = [NSString stringWithFormat: @"%d", _sdpMLineIndex];
        [sdpMLineIndexLock lock];
        _sdpMLineIndex++;
        [sdpMLineIndexLock unlock];
    }

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                            candidate.sdp, @"candidate",
                            candidate.sdpMid, @"sdpMid",
                            sdpMLineIndex, @"sdpMLineIndex",
                          nil];

    if([NSJSONSerialization isValidJSONObject:dict])
    {
        NSLog(@"Dict: %@", dict);

        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:nil
                                                         error:&err];
        NSString *iceCandidateJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.onicecandidate('%@', %@);",
                        _connectionID, iceCandidateJson];

        [_delegate evalJs:js];
    }
}

//RTCPeerConnection.oniceconnectionstatechange
-(void) peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSString *state;

    switch(newState)
    {
        case RTCICEConnectionNew:
            state = @"new";
            break;
        case RTCICEConnectionChecking:
            state = @"checking";
            break;
        case RTCICEConnectionClosed:
            state = @"closed";
            break;
        case RTCICEConnectionCompleted:
            state = @"completed";
            break;
        case RTCICEConnectionConnected:
            state = @"connected";
            break;
        case RTCICEConnectionDisconnected:
            state = @"disconnected";
            break;
        case RTCICEConnectionFailed:
            state = @"failed";
            break;
    }

    NSLog(@"ICE connection state changed: %@", state);

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.oniceconnectionstatechange('%@', '%@')", _connectionID, state];

    [_delegate evalJs:js];
}

//No counter part. But still need to notify JS interface
-(void) peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSString *state;

    switch(newState)
    {
        case RTCICEGatheringNew:
            state = @"new";
            break;
        case RTCICEGatheringGathering:
            state = @"gathering";
            break;
        case RTCICEGatheringComplete:
            state = @"complete";
            break;
    }

    NSLog(@"ICE gathering state changed: %@", state);

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.iceGatheringStateChanged('%@', '%@')", _connectionID, state];

    [_delegate evalJs:js];
}

//RTCPeerConnection.onremovestream
-(void) peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
{

}

//No counter part. But still need to notify JS interface
-(void) peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSString *state;

    switch(stateChanged)
    {
        case RTCSignalingClosed:
            state = @"closed";
            break;
        case RTCSignalingHaveLocalOffer:
            state = @"have-local-offer";
            break;
        case RTCSignalingHaveRemoteOffer:
            state = @"have-remote-offer";
            break;
        case RTCSignalingHaveLocalPrAnswer:
            state = @"have-local-pranswer";
            break;
        case RTCSignalingHaveRemotePrAnswer:
            state = @"have-remote-pranswer";
            break;
        case RTCSignalingStable:
            state = @"stable";
            break;
    }

    NSLog(@"Signaling state changed: %@", state);

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.signalingStateChanged('%@', '%@')", _connectionID, state];

    [_delegate evalJs:js];
}

//RTCPeerConnection.onnegotiationneeded
-(void) peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{

}

@end
