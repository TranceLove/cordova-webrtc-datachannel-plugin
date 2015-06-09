//
//  RTCPeerConnectionWithConnectionID.h
//  Geotalk-HTML5
//
//  Created by Raymond Lai on 9/6/15.
//
//

#ifndef Geotalk_HTML5_RTCPeerConnectionWithConnectionID_h
#define Geotalk_HTML5_RTCPeerConnectionWithConnectionID_h

#import "RTCPeerConnection.h"

@interface RTCPeerConnectionWithConnectionID : RTCPeerConnection

@property (nonatomic,readonly) NSString* connectionID;

-(id)initWithRTCPeerConnection:(RTCPeerConnection*)peerConnection;

@end

#endif
