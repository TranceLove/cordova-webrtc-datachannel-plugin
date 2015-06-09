//
//  RTCDataChannelWithConnectionID.h
//  Geotalk-HTML5
//
//  Created by Raymond Lai on 9/6/15.
//
//

#ifndef Geotalk_HTML5_RTCDataChannelWithConnectionID_h
#define Geotalk_HTML5_RTCDataChannelWithConnectionID_h

#import "RTCDataChannel.h"

@interface RTCDataChannelWithConnectionID : RTCDataChannel

@property (nonatomic,readonly) NSString* connectionID;

-(id)initWithRTCDataChannel:(RTCDataChannel*)dataChannel
               connectionID:(NSString*)connectionID;

@end

#endif
