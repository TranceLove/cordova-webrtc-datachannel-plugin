//
//  WebRTCPlugin.m
//  WebRTCPlugin
//
//  Created by Raymond Lai on 16/5/15.
//
//

#import "iosWebRTCPlugin.h"
#import "RTCPair.h"
#import "RTCDataChannel.h"
#import "RTCICECandidate.h"
#import "PeerConnectionObserver.h"
#import "RTCSessionDescriptionObserver+Internal.h"

@implementation iosWebRTCPlugin

RTCPeerConnectionFactory *factory;
NSMutableDictionary *_connections;

-(void)pluginInitialize
{
    [RTCPeerConnectionFactory initializeSSL];
    factory = [[RTCPeerConnectionFactory alloc] init];
    
    _connections = [[NSMutableDictionary alloc] init];
}

-(void)onAppTerminate
{
    [RTCPeerConnectionFactory deinitializeSSL];
    //TODO: cut off all current connections
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
        
        //FIXME: UUID is so lame... can't I use random string here?
        NSString *connectionID = [[NSUUID UUID] UUIDString];
        
        //TODO: Implement video and audio bridges
        NSArray *mandatoryConstraints = [[NSArray alloc] initWithObjects:
                                         [[RTCPair alloc] initWithKey: @"OfferToReceiveAudio" value: @"false"],
                                         [[RTCPair alloc] initWithKey: @"OfferToReceiveVideo" value: @"false"],
                                         nil
                                         ];
        
        NSArray *optionalConstraints = [[NSArray alloc] initWithObjects:
                                        [[RTCPair alloc] initWithKey: @"RtpDataChannels" value: @"true"],
                                        [[RTCPair alloc] initWithKey: @"DtlsSrtpKeyAgreement" value: @"true"],
                                        nil
                                        ];
        
        RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                                                 optionalConstraints:optionalConstraints];
        
        PeerConnectionObserver *observer = [[PeerConnectionObserver alloc] initWithDelegate:self.commandDelegate
                                                                               connectionID:connectionID];
        
        RTCPeerConnection *connection = [factory peerConnectionWithICEServers:iceServers
                                                                  constraints:constraints
                                                                     delegate:observer];
        
        RTCPeerConnectionHolder *connectionHolder = [[RTCPeerConnectionHolder alloc]initWithRTCPeerConnection:connection
                                                                                             mediaConstraints:constraints
                                                                                                 connectionID:connectionID];
        
        [_connections setValue:connectionHolder forKey:connectionID];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:connectionID, @"connectionID", nil]];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)createDataChannel:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];
        NSString *label = [command argumentAtIndex:1];
        
        RTCPeerConnectionHolder *holder = [_connections valueForKey:connectionID];
        
        RTCDataChannelInit *config = [[RTCDataChannelInit alloc] init];
        
        RTCDataChannel *dataChannel = [holder.connection createDataChannelWithLabel:label
                                                                             config:config];
        
        [holder.dataChannels setValue:dataChannel
                               forKey:label];
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:connectionID, @"connectionID",
                                                                                                                   label, @"label",
                                                                                                                   nil]];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)createLocalOffer:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSString *connectionID = [command argumentAtIndex:0];
        
        RTCPeerConnectionHolder *holder = [_connections valueForKey:connectionID];
        
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
        
        RTCPeerConnectionHolder *holder = [_connections valueForKey:connectionID];
        
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
        
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:[options valueForKey:@"type"] sdp:[options valueForKey:@"sdp"]];
        
        RTCPeerConnectionHolder *holder = [_connections valueForKey:connectionID];
        
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
        
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:[options valueForKey:@"type"] sdp:[options valueForKey:@"sdp"]];
        
        RTCPeerConnectionHolder *holder = [_connections valueForKey:connectionID];
        
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
        
        NSString *sdpMid = [iceCandidateInfo valueForKey:@"sdpMid"];
        NSString *sdpMLineIndex = [iceCandidateInfo valueForKey:@"sdpMLineIndex"];
        NSString *sdp = [iceCandidateInfo valueForKey:@"sdp"];
        
        RTCICECandidate *iceCandidate = [[RTCICECandidate alloc] initWithMid:sdpMid
                                                                       index:[sdpMLineIndex intValue]
                                                                         sdp:sdp];
        
        RTCPeerConnectionHolder *holder = [_connections valueForKey:connectionID];
        
        [holder.connection addICECandidate:iceCandidate];
    }];
}

@end
