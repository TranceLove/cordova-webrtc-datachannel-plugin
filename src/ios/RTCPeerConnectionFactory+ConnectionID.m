//
//  RTCPeerConnectionFactory+ConnectionID.m
//  Geotalk-HTML5
//
//  Created by Raymond Lai on 8/6/15.
//
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnectionFactory+ConnectionID.h"
#import "RTCPeerConnection+ConnectionID.h"

@implementation RTCPeerConnectionFactory (ConnectionID)

- (RTCPeerConnection*) peerConnectionWithICEServers:(NSArray *)servers
                                        constraints:(RTCMediaConstraints *)constraints
                                           delegate:(id<RTCPeerConnectionDelegate>)delegate
                                       connectionID:(NSString *)connectionID
{
    RTCPeerConnection *retval = [self peerConnectionWithICEServers:servers
                                                       constraints:constraints
                                                          delegate:delegate];
    
    retval.connectionID = connectionID;
    
    return retval;
}

@end