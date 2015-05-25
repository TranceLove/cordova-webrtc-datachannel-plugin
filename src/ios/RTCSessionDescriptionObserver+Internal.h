//
//  RTCSessionDescriptionObserver+Internal.h
//  WebRTCApp
//
//  Created by Raymond Lai on 25/5/15.
//
//

#ifndef WebRTCApp_RTCSessionDescriptionObserver_Internal_h
#define WebRTCApp_RTCSessionDescriptionObserver_Internal_h

#import <Cordova/CDVCommandDelegate.h>
#import <Cordova/CDV.h>
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCPeerConnectionHolder+Internal.h"

@interface RTCSessionDescriptionObserver : NSObject<RTCSessionDescriptionDelegate>

-(id)initWithDelegate:(id<CDVCommandDelegate>)commandDelegate
              command:(CDVInvokedUrlCommand*) command
           connection:(RTCPeerConnectionHolder*) connection;

@end

#endif
