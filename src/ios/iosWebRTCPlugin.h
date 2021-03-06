/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 Raymond Lai (TranceLove) <airwave209gt@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef WebRTCPlugin_iosWebRTCPlugin_h
#define WebRTCPlugin_iosWebRTCPlugin_h

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

#import "RTCICEServer.h"
#import "RTCMediaConstraints.h"
#import "RTCPeerConnectionObserver.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCPeerConnectionHolder.h"

@interface iosWebRTCPlugin : CDVPlugin

@property (atomic,readonly) RTCPeerConnectionFactory *factory;
@property (atomic,readonly) NSMutableDictionary *connections;
@property (atomic,readonly) RTCPeerConnectionObserver *peerConnectionObserver;

-(void)createRTCPeerConnection:(CDVInvokedUrlCommand*)command;

-(void)createDataChannel:(CDVInvokedUrlCommand*)command;

-(void)createLocalOffer:(CDVInvokedUrlCommand*)command;

-(void)createAnswer:(CDVInvokedUrlCommand*)command;

-(void)setLocalOffer:(CDVInvokedUrlCommand*)command;

-(void)setRemoteOffer:(CDVInvokedUrlCommand*)command;

-(void)addIceCandidate:(CDVInvokedUrlCommand*)command;

-(void)sendDataOnDataChannel:(CDVInvokedUrlCommand*)command;

-(void)sendStringOnDataChannel:(CDVInvokedUrlCommand*)command;

-(void)closeDataChannel:(CDVInvokedUrlCommand*)command;

-(void)closeRTCPeerConnection:(CDVInvokedUrlCommand*)command;

@end

#endif
