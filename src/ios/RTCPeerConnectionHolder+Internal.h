//
//  RTCPeerConnection+Internal.h
//  WebRTCApp
//
//  Created by Raymond Lai on 25/5/15.
//
//

#ifndef WebRTCApp_RTCPeerConnection_Internal_h
#define WebRTCApp_RTCPeerConnection_Internal_h

#import "RTCPeerConnection.h"
#import "RTCMediaConstraints.h"
#import "PeerConnectionObserver.h"

@interface RTCPeerConnectionHolder : NSObject

@property (atomic,strong) NSString* connectionID;
@property (atomic,strong) RTCPeerConnection* connection;
@property (atomic,strong) RTCMediaConstraints* mediaConstraints;
//@property (nonatomic) NSString* provisionalCallbackID;
@property (nonatomic) NSMutableDictionary *dataChannels;
@property (atomic,strong) PeerConnectionObserver *connectionObserver;

-(id)initWithRTCPeerConnection: (RTCPeerConnection*) connection
              mediaConstraints: (RTCMediaConstraints*) mediaConstraints
                  connectionID: (NSString*) connectionID
            connectionObserver: (PeerConnectionObserver*) connectionObserver;

@end

#endif
