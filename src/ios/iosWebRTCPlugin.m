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

#import "iosWebRTCPlugin.h"
#import "RTCPair.h"
#import "RTCICECandidate.h"
#import "RTCSessionDescription.h"
#import "RTCDataChannel.h"
#import "RTCPeerConnectionWithConnectionID.h"
#import "RTCSessionDescriptionObserver.h"

@interface iosWebRTCPlugin()

-(void)_doSendDataOnDataChannel:(NSString *)connectionID
               dataChannelLabel:(NSString *)dataChannelLabel
                           data:(NSData *)data
                       isBinary:(BOOL)isBinary
                        command:(CDVInvokedUrlCommand*)command;

-(void)_doCloseDataChannel:(NSString *)connectionID
          dataChannelLabel:(NSString *)dataChannelLabel;

-(void)_doCloseRTCPeerConnection:(NSString *)connectionID;

@end

@implementation iosWebRTCPlugin

-(void)pluginInitialize
{
    [RTCPeerConnectionFactory initializeSSL];
    _factory = [[RTCPeerConnectionFactory alloc] init];
    _connections = [[NSMutableDictionary alloc] init];
    _peerConnectionObserver = [[RTCPeerConnectionObserver alloc] initWithDelegate:self.commandDelegate
                                                                   connections:self.connections];
}

-(void)onAppTerminate
{
    [RTCPeerConnectionFactory deinitializeSSL];
    for(NSString *connectionID in self.connections)
    {
        [self _doCloseRTCPeerConnection: connectionID];
    }
    [super onAppTerminate];
}

-(void)createRTCPeerConnection:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSDictionary *options = [command argumentAtIndex:0];
        //ICE servers
        NSArray *iceServerConfigs = [options valueForKey:@"iceServers"];
        NSMutableArray *iceServers = [[NSMutableArray alloc] init];
        for(NSDictionary *iceServerConfig in iceServerConfigs)
        {
            NSString *username = @"";
            NSString *password = @"";
            RTCICEServer *iceServer = [[RTCICEServer alloc] initWithURI: [NSURL URLWithString:[iceServerConfig valueForKey:@"url"]]
                                                               username: username
                                                               password: password];
            [iceServers addObject: iceServer];
        }

        //TODO: Implement video and audio bridges
        NSArray *mandatoryConstraints = [[NSArray alloc] initWithObjects:
                                         [[RTCPair alloc] initWithKey: @"OfferToReceiveAudio" value: @"false"],
                                         [[RTCPair alloc] initWithKey: @"OfferToReceiveVideo" value: @"false"],
                                         nil
                                         ];

        NSArray *optionalConstraints = [[NSArray alloc] initWithObjects:
                                        [[RTCPair alloc] initWithKey: @"RtpDataChannels" value: @"false"],
                                        nil
                                        ];

        RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                                 optionalConstraints:optionalConstraints];

        NSMutableDictionary *dataChannels = [[NSMutableDictionary alloc]init];



        RTCPeerConnection *_connection = [self.factory peerConnectionWithICEServers:iceServers
                                                                       constraints:constraints
                                                                          delegate:self.peerConnectionObserver];

        RTCPeerConnectionWithConnectionID *connection = [[RTCPeerConnectionWithConnectionID alloc] initWithRTCPeerConnection:_connection];

        RTCPeerConnectionHolder *connectionHolder = [[RTCPeerConnectionHolder alloc]initWithRTCPeerConnection:connection
                                                                                             mediaConstraints:constraints
                                                                                                 dataChannels:dataChannels];

        [self.connections setValue:connectionHolder forKey:connection.connectionID];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:connection.connectionID, @"connectionID", nil]];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)createDataChannel:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];
        NSString *label = [command argumentAtIndex:1];

        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        RTCDataChannelInit *config = [[RTCDataChannelInit alloc] init];

        RTCDataChannel *_dataChannel = [holder.connection createDataChannelWithLabel:label
                                                                             config:config];

        RTCDataChannelWithConnectionID *dataChannel = [[RTCDataChannelWithConnectionID alloc] initWithRTCDataChannel:_dataChannel
                                                                                                        connectionID:connectionID];

        [holder.dataChannels setValue:dataChannel
                               forKey:label];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                                   connectionID,@"connectionID",
                                                                                                                   label, @"label",
                                                                                                                   nil]];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)createLocalOffer:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];

        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        RTCSessionDescriptionObserver *observer = [[RTCSessionDescriptionObserver alloc] initWithDelegate:self.commandDelegate
                                                                                                  command:command
                                                                                               connection:holder];

        [holder.connection createOfferWithDelegate:observer
                                       constraints:holder.mediaConstraints];
    }];
}

-(void)createAnswer:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];

        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        RTCSessionDescriptionObserver *observer = [[RTCSessionDescriptionObserver alloc] initWithDelegate:self.commandDelegate
                                                                                                  command:command
                                                                                               connection:holder];

        [holder.connection createAnswerWithDelegate:observer
                                        constraints:holder.mediaConstraints];
    }];
}

-(void)setLocalOffer:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];
        NSDictionary *options = [command argumentAtIndex:1];

        NSLog(@"Options: %@", options);

        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:[options valueForKey:@"type"] sdp:[options valueForKey:@"sdp"]];

        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        RTCSessionDescriptionObserver *observer = [[RTCSessionDescriptionObserver alloc] initWithDelegate:self.commandDelegate
                                                                                                  command:command
                                                                                               connection:holder];

        [holder.connection setLocalDescriptionWithDelegate:observer
                                        sessionDescription:sdp];
    }];
}

-(void)setRemoteOffer:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];
        NSDictionary *options = [command argumentAtIndex:1];

        NSLog(@"Options: %@", options);

        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:[options valueForKey:@"type"] sdp:[options valueForKey:@"sdp"]];

        NSLog(@"sdp: %@", sdp);

        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        RTCSessionDescriptionObserver *observer = [[RTCSessionDescriptionObserver alloc] initWithDelegate:self.commandDelegate
                                                                                                  command:command
                                                                                               connection:holder];

        [holder.connection setRemoteDescriptionWithDelegate:observer
                                         sessionDescription:sdp];
    }];
}

-(void)addIceCandidate:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];
        NSDictionary *iceCandidateInfo = [command argumentAtIndex:1];

        NSLog(@"ICE candidate info: %@", iceCandidateInfo);

        NSString *sdpMid = [iceCandidateInfo valueForKey:@"sdpMid"];
        NSString *sdpMLineIndex = [iceCandidateInfo valueForKey:@"sdpMLineIndex"];
        NSString *sdp = [iceCandidateInfo valueForKey:@"candidate"];

        RTCICECandidate *iceCandidate = [[RTCICECandidate alloc] initWithMid:sdpMid
                                                                       index:[sdpMLineIndex intValue]
                                                                         sdp:sdp];
        NSLog(@"Attach ICE candidate: %@", iceCandidate);

        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        [holder.connection addICECandidate:iceCandidate];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)_doSendDataOnDataChannel:(NSString *)connectionID
               dataChannelLabel:(NSString *)dataChannelLabel
                           data:(NSData *)data
                       isBinary:(BOOL)isBinary
                        command:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

        RTCDataChannel *channel = [holder.dataChannels valueForKey:dataChannelLabel];

        CDVPluginResult *result;

        @try
        {
            [channel sendData:[[RTCDataBuffer alloc] initWithData:data isBinary:isBinary]];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat: @"%ld", (unsigned long)data.length], @"length", nil]];
        }
        @catch (NSException *exception)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        @finally
        {
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

-(void)sendStringOnDataChannel:(CDVInvokedUrlCommand *)command
{
    NSString *connectionID = [command argumentAtIndex:0];
    NSString *dataChannelLabel = [command argumentAtIndex:1];
    NSString *string = [command argumentAtIndex:2];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

    [self _doSendDataOnDataChannel:connectionID dataChannelLabel:dataChannelLabel data:data isBinary:NO command:command];
}

-(void)sendDataOnDataChannel:(CDVInvokedUrlCommand *)command
{
    NSString *connectionID = [command argumentAtIndex:0];
    NSString *dataChannelLabel = [command argumentAtIndex:1];
    NSData *data = [command argumentAtIndex:2];

    [self _doSendDataOnDataChannel:connectionID dataChannelLabel:dataChannelLabel data:data isBinary:YES command:command];
}

-(void)_doCloseDataChannel:(NSString *)connectionID
          dataChannelLabel:(NSString *)dataChannelLabel
{
    RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

    RTCDataChannel *channel = [holder.dataChannels valueForKey:dataChannelLabel];

    if(channel.state == kRTCDataChannelStateOpen)
    {
        [channel close];
    }
}

-(void)closeDataChannel:(CDVInvokedUrlCommand *)command
{
    NSString *connectionID = [command argumentAtIndex:0];
    NSString *dataChannelLabel = [command argumentAtIndex:1];

    [self _doCloseDataChannel:connectionID
             dataChannelLabel:dataChannelLabel];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)_doCloseRTCPeerConnection:(NSString *)connectionID
{
    RTCPeerConnectionHolder *holder = [self.connections valueForKey:connectionID];

    for(NSString *dataChannelLabel in holder.dataChannels)
    {
        [self _doCloseDataChannel:connectionID dataChannelLabel:dataChannelLabel];
    }

    [holder.connection close];
}

-(void)closeRTCPeerConnection:(CDVInvokedUrlCommand *)command
{
    NSString *connectionID = [command argumentAtIndex:0];

    [self _doCloseRTCPeerConnection:connectionID];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
