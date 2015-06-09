//
//  RTCPeerConnectionFactory+ConnectionID.h
//  Geotalk-HTML5
//
//  Created by Raymond Lai on 8/6/15.
//
//

#ifndef Geotalk_HTML5_RTCPeerConnectionFactory_ConnectionID_h
#define Geotalk_HTML5_RTCPeerConnectionFactory_ConnectionID_h

#import "RTCPeerConnectionFactory.h"

@interface RTCPeerConnectionFactory (ConnectionID)

- (RTCPeerConnection *) peerConnectionWithICEServers:(NSArray *)servers
                                         constraints:(RTCMediaConstraints *)constraints
                                            delegate:(id<RTCPeerConnectionDelegate>)delegate
                                        connectionID:(NSString *) connectionID;

@end

#endif
