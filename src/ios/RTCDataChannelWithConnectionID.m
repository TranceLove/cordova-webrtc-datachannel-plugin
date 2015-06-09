//
//  RTCDataChannelWithConnectionID.m
//  Geotalk-HTML5
//
//  Created by Raymond Lai on 9/6/15.
//
//

#import <Foundation/Foundation.h>
#import "RTCDataChannelWithConnectionID.h"

@implementation RTCDataChannelWithConnectionID
{
    RTCDataChannel *_dataChannel;
}

-(id)initWithRTCDataChannel:(RTCDataChannel *)dataChannel
               connectionID:(NSString *)connectionID
{
    _dataChannel = dataChannel;
    _connectionID = connectionID;
    return self;
}

-(NSString*) label
{
    return _dataChannel.label;
}

-(BOOL) isReliable
{
    return _dataChannel.isReliable;
}

-(BOOL) isOrdered
{
    return _dataChannel.isOrdered;
}

-(NSUInteger) maxRetransmitTime
{
    return _dataChannel.maxRetransmitTime;
}

-(NSUInteger) maxRetransmits
{
    return _dataChannel.maxRetransmits;
}

-(NSString*) protocol
{
    return _dataChannel.protocol;
}

-(BOOL) isNegotiated
{
    return _dataChannel.isNegotiated;
}

-(NSInteger) streamId
{
    return _dataChannel.streamId;
}

-(RTCDataChannelState) state
{
    return _dataChannel.state;
}

-(NSUInteger) bufferedAmount
{
    return _dataChannel.bufferedAmount;
}

-(id<RTCDataChannelDelegate>) delegate
{
    return _dataChannel.delegate;
}

-(void) setDelegate:(id<RTCDataChannelDelegate>)delegate
{
    _dataChannel.delegate = delegate;
}

-(void) close
{
    [_dataChannel close];
}

-(BOOL) sendData:(RTCDataBuffer*)data
{
    return [_dataChannel sendData:data];
}

@end