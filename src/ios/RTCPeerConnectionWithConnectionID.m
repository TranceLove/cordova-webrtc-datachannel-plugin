//
//  RTCPeerConnectionWithConnectionID.m
//  Geotalk-HTML5
//
//  Created by Raymond Lai on 9/6/15.
//
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnectionWithConnectionID.h"

@implementation RTCPeerConnectionWithConnectionID
{
    RTCPeerConnection *_peerConnection;
}

-(id)initWithRTCPeerConnection:(RTCPeerConnection *)peerConnection
{
    _peerConnection = peerConnection;
    _connectionID = [[NSUUID UUID] UUIDString];
    
    return self;
}

-(id<RTCPeerConnectionDelegate>) delegate
{
    return _peerConnection.delegate;
}

-(void) setDelegate:(id<RTCPeerConnectionDelegate>)delegate
{
    _peerConnection.delegate = delegate;
}

-(NSArray*) localStreams
{
    return _peerConnection.localStreams;
}

-(RTCSessionDescription*) localDescription
{
    return _peerConnection.localDescription;
}

-(RTCSessionDescription*) remoteDescription
{
    return _peerConnection.remoteDescription;
}

-(RTCSignalingState) signalingState
{
    return _peerConnection.signalingState;
}

-(RTCICEConnectionState) iceConnectionState
{
    return _peerConnection.iceConnectionState;
}

-(RTCICEGatheringState) iceGatheringState
{
    return _peerConnection.iceGatheringState;
}

-(BOOL)addStream:(RTCMediaStream *)stream
{
    return [_peerConnection addStream:stream];
}

-(void)removeStream:(RTCMediaStream *)stream
{
    [_peerConnection removeStream:stream];
}

//TODO: wrapper
-(RTCDataChannel*)createDataChannelWithLabel:(NSString*)label
                                       config:(RTCDataChannelInit*)config
{
    return [_peerConnection createDataChannelWithLabel:label
                                                config:config];
}


-(void)createOfferWithDelegate:(id<RTCSessionDescriptionDelegate>)delegate
                    constraints:(RTCMediaConstraints *)constraints
{
    [_peerConnection createOfferWithDelegate:delegate
                                 constraints:constraints];
}

-(void)createAnswerWithDelegate:(id<RTCSessionDescriptionDelegate>)delegate
                     constraints:(RTCMediaConstraints *)constraints
{
    [_peerConnection createAnswerWithDelegate:delegate
                                  constraints:constraints];
}

-(void)setLocalDescriptionWithDelegate:(id<RTCSessionDescriptionDelegate>)delegate
                     sessionDescription:(RTCSessionDescription *)sdp
{
    [_peerConnection setLocalDescriptionWithDelegate:delegate sessionDescription:sdp];
}

-(void)setRemoteDescriptionWithDelegate:(id<RTCSessionDescriptionDelegate>)delegate
                     sessionDescription:(RTCSessionDescription *)sdp
{
    [_peerConnection setRemoteDescriptionWithDelegate:delegate
                                   sessionDescription:sdp];
}

-(BOOL)updateICEServers:(NSArray *)servers
            constraints:(RTCMediaConstraints *)constraints
{
    return [_peerConnection updateICEServers:servers
                                 constraints:constraints];
}

-(BOOL)addICECandidate:(RTCICECandidate *)candidate
{
    return [_peerConnection addICECandidate:candidate];
}

-(void)close
{
    [_peerConnection close];
}

-(BOOL)getStatsWithDelegate:(id<RTCStatsDelegate>)delegate
            mediaStreamTrack:(RTCMediaStreamTrack*)mediaStreamTrack
            statsOutputLevel:(RTCStatsOutputLevel)statsOutputLevel
{
    return [_peerConnection getStatsWithDelegate:delegate
                                mediaStreamTrack:mediaStreamTrack
                                statsOutputLevel:statsOutputLevel];
}


@end