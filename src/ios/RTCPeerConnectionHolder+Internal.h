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

#ifndef WebRTCApp_RTCPeerConnection_Internal_h
#define WebRTCApp_RTCPeerConnection_Internal_h

#import "RTCPeerConnection.h"
#import "RTCMediaConstraints.h"
#import "PeerConnectionObserver.h"

@interface RTCPeerConnectionHolder : NSObject

@property (atomic,strong) NSString* connectionID;
@property (atomic,strong) RTCPeerConnection* connection;
@property (atomic,strong) RTCMediaConstraints* mediaConstraints;
//@property (nonatomic) NSString* provisionalCallbackID;
@property (nonatomic) NSMutableDictionary *dataChannels;
@property (atomic,strong) PeerConnectionObserver *connectionObserver;

-(id)initWithRTCPeerConnection: (RTCPeerConnection*) connection
              mediaConstraints: (RTCMediaConstraints*) mediaConstraints
                  connectionID: (NSString*) connectionID
            connectionObserver: (PeerConnectionObserver*) connectionObserver;

@end

#endif
