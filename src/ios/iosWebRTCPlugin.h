//
//  WebRTCPlugin.h
//  WebRTCPlugin
//
//  Created by Raymond Lai on 16/5/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

#import "RTCICEServer.h"
#import "RTCMediaConstraints.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCPeerConnectionHolder+Internal.h"

@interface iosWebRTCPlugin : CDVPlugin

-(void)createRTCPeerConnection:(CDVInvokedUrlCommand*)command;

@end
