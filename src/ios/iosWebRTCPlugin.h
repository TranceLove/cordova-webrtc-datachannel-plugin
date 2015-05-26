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

-(void)createLocalOffer:(CDVInvokedUrlCommand*)command;

-(void)createAnswer:(CDVInvokedUrlCommand*)command;

-(void)setLocalOffer:(CDVInvokedUrlCommand*)command;

-(void)setRemoteOffer:(CDVInvokedUrlCommand*)command;

@end
