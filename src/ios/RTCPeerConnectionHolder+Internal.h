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

@interface RTCPeerConnectionHolder : NSObject

@property (atomic,strong) NSString* connectionID;
@property (atomic,strong) RTCPeerConnection* connection;
@property (nonatomic) NSString* provisionalCallbackID;

-(id)initWithRTCPeerConnection: (RTCPeerConnection*) connection
                  connectionID: (NSString*) connectionID;

@end

#endif
