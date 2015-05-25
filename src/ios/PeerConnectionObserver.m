//
//  PeerConnectionObserver.m
//  WebRTCApp
//
//  Created by Raymond Lai on 25/5/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPluginResult.h>
#import "PeerConnectionObserver.h"

@implementation PeerConnectionObserver
{
    id<CDVCommandDelegate> _delegate;
    NSString* _connectionID;
    RTCPeerConnection* _connection;
}

-(id) initWithDelegate:(id<CDVCommandDelegate>)delegate
          connectionID:(NSString *)connectionID
        peerConnection:(RTCPeerConnection *) connection
{
    if([super init])
    {
        _delegate = delegate;
        _connectionID = connectionID;
        _connection = connection;
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

}

//RTCPeerConnection.onicecandidate
-(void) peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"sdp", candidate.sdp,
                            @"sdpMid", candidate.sdpMid,
                            @"sdpMLineIndex", candidate.sdpMLineIndex,
                          nil];
    
    if([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                        options:NSJSONWritingPrettyPrinted
                                          error:&err];
        NSString *iceCandidateJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCConnection.onicecandidate('%@', %@);",
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
    
    NSString *js = [NSString stringWithFormat: @"plugin.iosWebRTCPeerConnection.signalingStateChanged('%@', '%@11')", _connectionID, state];
    
    [_delegate evalJs:js];
}

//RTCPeerConnection.onnegotiationneeded
-(void) peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    
}

@end