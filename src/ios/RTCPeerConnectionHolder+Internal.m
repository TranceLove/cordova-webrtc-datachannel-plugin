//
//  RTCPeerConnectionHolder+Internal.m
//  WebRTCApp
//
//  Created by Raymond Lai on 25/5/15.
//
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnectionHolder+Internal.h"

@implementation RTCPeerConnectionHolder

-(id)initWithRTCPeerConnection:(RTCPeerConnection *)connection
              mediaConstraints:(RTCMediaConstraints *)mediaConstraints
                  connectionID:(NSString *)connectionID
            connectionObserver:(PeerConnectionObserver *)connectionObserver

{
    if([super init])
    {
        self.connectionID = connectionID;
        self.mediaConstraints = mediaConstraints;
        self.connection = connection;
        self.connectionObserver = connectionObserver;
        self.dataChannels = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}

@end