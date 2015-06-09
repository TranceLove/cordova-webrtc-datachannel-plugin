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
#import <Cordova/NSData+Base64.h>
#import "RTCPeerConnectionObserver.h"
#import "RTCPeerConnectionHolder.h"

@implementation RTCPeerConnectionObserver
{
    NSLock *sdpMLineIndexLock;
    unsigned int _sdpMLineIndex;
}

-(id) initWithDelegate:(id<CDVCommandDelegate>)delegate
           connections:(NSDictionary *)connectionHolders
{
    if([super init])
    {
        _delegate = delegate;
        _connectionHolders = connectionHolders;
        _sdpMLineIndex = 0;
    }
    return self;
}

//RTCPeerConnection.onaddstream
-(void) peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
{

}

//RTCDataChannel.onmessage
-(void) channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    NSString *receivedData;
    NSString *dataType;
    NSUInteger length = buffer.data.length;

    //FIXME: Converting NSData to base64 can cause app to run out of memory!
    if(buffer.isBinary)
    {
        dataType = @"binary";
        receivedData = [buffer.data cdv_base64EncodedString];
    }
    else
    {
        dataType = @"string";
        receivedData = [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding];
    }

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          dataType, @"type",
                          [NSNumber numberWithUnsignedLong: length], @"length",
                          receivedData, @"data",
                          nil];

    if([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:nil
                                                         error:&err];
        NSString *messageObj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.dataChannelOnMessage('%@', '%@', %@);",
                    channel.connectionID, channel.label, messageObj];

        [self.delegate evalJs:js];
    }
}

//No counter part. But still need to notify JS interface
-(void) channelDidChangeState:(RTCDataChannel *)channel
{
    NSString *readyState;

    switch(channel.state)
    {
        case kRTCDataChannelStateOpen:
            readyState = @"open";
            break;
        case kRTCDataChannelStateClosed:
            readyState = @"closed";
            break;
        case kRTCDataChannelStateClosing:
            readyState = @"closing";
            break;
        case kRTCDataChannelStateConnecting:
            readyState = @"connecting";
            break;
    }

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.dataChannelStateChanged('%@', '%@', '%@');",
                    channel.connectionID, channel.label, readyState];

    [self.delegate evalJs:js];
}

//RTCPeerConnection.ondatachannel
-(void) peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    NSLog(@"Data channel opened");

    NSString *readyState;

    switch(dataChannel.state)
    {
        case kRTCDataChannelStateOpen:
            readyState = @"open";
            break;
        case kRTCDataChannelStateClosed:
            readyState = @"closed";
            break;
        case kRTCDataChannelStateClosing:
            readyState = @"closing";
            break;
        case kRTCDataChannelStateConnecting:
            readyState = @"connecting";
            break;
    }

    NSLog(@"Label: %@", dataChannel.label);
    NSLog(@"Protocol? %@", dataChannel.protocol);
    NSLog(@"Stream ID: %d", dataChannel.streamId);
    NSLog(@"Max retransmits: %d", dataChannel.maxRetransmits);
    NSLog(@"Max retransmit time: %d", dataChannel.maxRetransmitTime);
    NSLog(@"Negotiated? %d", dataChannel.isNegotiated ? 1 : 0);
    NSLog(@"Ordered? %d", dataChannel.isOrdered ? 1 : 0);
    NSLog(@"Reliable? %d", dataChannel.isReliable ? 1 : 0);
    NSLog(@"Ready state: %@", readyState);

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          dataChannel.label, @"label",
                          dataChannel.protocol, @"protocol",
                          [NSNumber numberWithLong:dataChannel.streamId], @"id",
                          [NSNumber numberWithUnsignedLong:dataChannel.maxRetransmits], @"maxRetransmits",
                          [NSNumber numberWithUnsignedLong:dataChannel.maxRetransmitTime], @"maxRetransmitTime",
                          dataChannel.isNegotiated, @"negotiated",
                          dataChannel.isOrdered, @"ordered",
                          dataChannel.isReliable, @"reliable",
                          readyState, @"readyState",
                          nil];

    if([NSJSONSerialization isValidJSONObject:dict])
    {
        dataChannel.delegate = self;
        dataChannel.connectionID = peerConnection.connectionID;
        RTCPeerConnectionHolder *holder = [self.connectionHolders valueForKey:peerConnection.connectionID];
        [holder.dataChannels setValue:dataChannel forKey:dataChannel.label];

        NSLog(@"dict: %@", dict);

        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:nil
                                                         error:&err];
        NSString *dataChannelJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.ondatachannel('%@', %@);",
                        peerConnection.connectionID, dataChannelJson];

        [self.delegate evalJs:js];
    }
}

//RTCPeerConnection.onicecandidate
-(void) peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
    NSString *sdpMLineIndex = nil;
    if(candidate.sdpMLineIndex >= 0)
    {
        sdpMLineIndex = [NSString stringWithFormat: @"%ld", (long)candidate.sdpMLineIndex];
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
                        peerConnection.connectionID, iceCandidateJson];

        [self.delegate evalJs:js];
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

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.oniceconnectionstatechange('%@', '%@')", peerConnection.connectionID, state];

    [self.delegate evalJs:js];
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

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.iceGatheringStateChanged('%@', '%@')", peerConnection.connectionID, state];

    [self.delegate evalJs:js];
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

    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.signalingStateChanged('%@', '%@')", peerConnection.connectionID, state];

    [self.delegate evalJs:js];
}

//RTCPeerConnection.onnegotiationneeded
-(void) peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{

}

@end
