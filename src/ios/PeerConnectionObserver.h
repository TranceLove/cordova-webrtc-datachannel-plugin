//
//  PeerConnectionObserver.h
//  WebRTCApp
//
//  Created by Raymond Lai on 25/5/15.
//
//

#ifndef WebRTCApp_PeerConnectionObserver_h
#define WebRTCApp_PeerConnectionObserver_h

#import <Cordova/CDVCommandDelegate.h>
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnection.h"
#import "RTCICECandidate.h"
#import "RTCDataChannel.h"

@interface PeerConnectionObserver : NSObject<RTCPeerConnectionDelegate>

-(id)initWithDelegate: (id<CDVCommandDelegate>) delegate
         connectionID: (NSString*) connectionID
       peerConnection: (RTCPeerConnection*) connection;

@end

#endif
