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
cordova.define("plugin.ios.webrtc.iosRTCPeerConnection", function(require, exports, module) {

var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

var _peerConnections = {};
var _dataChannels = {};

function getRandomInt(min, max)
{
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

if(!window.plugin)
{
    window.plugin = {};
}

window.plugin.iosWebRTCPeerConnection = {
    signalingStateChanged: function(connectionID,state){
        console.log("Connection " + connectionID + " signalingStateChanged: " + state);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.signalingState = state;
            if(pc.onsignalingstatechange)
                pc.onsignalingstatechange(state);
        }
    },
    iceGatheringStateChanged: function(connectionID, state){
        console.log("Connection " + connectionID + " iceGatheringStateChanged: " + state);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.iceGatheringState = state;
        }
    },
    oniceconnectionstatechange: function(connectionID, state){
        console.log("Connection " + connectionID + " oniceconnectionstatechange: " + state);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            pc.iceConnectionState = state;
            if(pc.oniceconnectionstatechange)
                pc.oniceconnectionstatechange(state);
        }
    },
    onicecandidate: function(connectionID, iceCandidateJson){
        console.log("Connection " + connectionID + " onicecandidate: " + iceCandidateJson);
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            if(pc.onicecandidate)
                pc.onicecandidate({candidate:iceCandidateJson});
        }
    },
    ondatachannel: function(connectionID, dataChannelInfo){
        console.log("Connection " + connectionID + " ondatachannel: " + JSON.stringify(dataChannelInfo));
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            var dataChannels = _dataChannels[connectionID];
            if(dataChannels == null || typeof dataChannels == "undefined")
            {
                dataChannels = {};
                _dataChannels[connectionID] = dataChannels;
            }
            var dc;
            if(dataChannels[dataChannelInfo.label])
            {
                dc = dataChannels[dataChannelInfo.label];
            }
            else
            {
                dc = new RTCDataChannel(connectionID, dataChannelInfo.label, dataChannelInfo);
                dc.readyState = dataChannelInfo.readyState;
                dc.maxRetransmits = dataChannelInfo.maxRetransmits;
                dc.maxRetransmitTime = dataChannelInfo.maxRetransmitTime;
                dataChannels[dataChannelInfo.label] = dc;
            }

            console.log("Invoke ondatachannel with", dc);

            if(pc.ondatachannel)
                pc.ondatachannel(dc);
        }
    },
    dataChannelOnMessage: function(connectionID, label, messageObj){
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            var dataChannels = _dataChannels[connectionID];
            if(dataChannels != null)
            {
                var dc = dataChannels[label];
                if(dc != null && dc.readyState == "open")
                {
                    if(dc.onmessage)
                        dc.onmessage(messageObj);
                }
            }
        }
    },
    dataChannelStateChanged: function(connectionID, label, state){
        if(_peerConnections[connectionID])
        {
            var pc = _peerConnections[connectionID];
            var dataChannels = _dataChannels[connectionID];
            if(dataChannels != null)
            {
                var dc = dataChannels[label];
                if(dc != null && dc.readyState == "open")
                {
                    dc.readyState = state;
                }
            }
        }
    }
}

function RTCDataChannel(connectionID, label, options)
{
    this.connectionID = connectionID;
	this.binaryType = "arraybuffer";
	this.bufferedAmount = 0;
	this.id = options.id || getRandomInt(0, 65535); //FIXME: unsafe
	this.label = label
	this.maxRetransmitTime = 65535
	this.maxRetransmits = 65535
	this.negotiated = options.negotiated || false;
	this.onclose = null;
	this.onerror = null;
	this.onmessage = null;
	this.onopen = null;
	this.ordered = options.ordered || true;
	this.protocol = options.protocol || "";
	this.readyState = "connecting";
	this.reliable = options.reliable || true;
}

RTCDataChannel.prototype.send = function(data, callback){
    var self = this;
    var command = "sendDataOnDataChannel";
    if(typeof data === "string")
        command = "sendStringOnDataChannel";

    exec(function(result){
        if(callback)
            callback(result);
    }, function(err){
        console.error(err)
    }, "iosWebRTCPlugin", command, [self.connectionID, self.label, data]);
}

RTCDataChannel.prototype.close = function(callback){
    exec(function(result){
        if(callback)
            callback(result)
    }, function(err){
        console.error(err)
    }, "iosWebRTCPlugin", "closeDataChannel", [self.connectionID, self.label]);
}

function RTCPeerConnection(options, callback)
{
    var self = this;

    this.iceConnectionState = "new"
    this.iceGatheringState = "new"
    this.localDescription = null
    this.onaddstream = null
    this.ondatachannel = null
    this.onicecandidate = null
    this.oniceconnectionstatechange = null
    this.onnegotiationneeded = null
    this.onremovestream = null
    this.onsignalingstatechange = null
    this.remoteDescription = null
    this.signalingState = "stable"

    exec(function(result){
        console.log(result)
        self.connectionID = result.connectionID;
        _peerConnections[result.connectionID] = self;
        callback(self)
    }, function(err){
    	console.error(err);
    }, "iosWebRTCPlugin", "createRTCPeerConnection", [options]);
}

RTCPeerConnection.prototype.createDataChannel = function(label, options, callback){

	var connectionID = this.connectionID;
	var retval = new RTCDataChannel(connectionID, label, options);

	exec(function(result){
        callback(retval)
	}, function(err){
        console.error(err);
	}, "iosWebRTCPlugin", "createDataChannel", [connectionID, label, options]);

	return retval;
}

RTCPeerConnection.prototype.createOffer = function(callback){

	var connectionID = this.connectionID;

    exec(function(result){
        callback(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "createLocalOffer", [connectionID]);
}

RTCPeerConnection.prototype.createAnswer = function(callback){
    var connectionID = this.connectionID;

    exec(function(result){
        callback(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "createAnswer", [connectionID]);
}

RTCPeerConnection.prototype.setLocalDescription = function(sessionDescription, callback){
    console.log(sessionDescription)
    this.localDescription = sessionDescription;
    var connectionID = this.connectionID;

    exec(function(result){
        console.log("setLocalOffer result", result)
        if(callback)
          callback();
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "setLocalOffer", [connectionID, sessionDescription]);
}

RTCPeerConnection.prototype.setRemoteDescription = function(sessionDescription, callback){
    this.remoteDescription = sessionDescription;
    var connectionID = this.connectionID;

    exec(function(result){
        console.log("setRemoteDescription result", result)
        if(callback)
          callback();
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "setRemoteOffer", [connectionID, sessionDescription]);
}

RTCPeerConnection.prototype.addIceCandidate = function(iceCandidate){
    var connectionID = this.connectionID;

    exec(function(result){
        console.log(result)
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "addIceCandidate", [connectionID, iceCandidate]);

}

RTCPeerConnection.prototype.close = function(callback){
    var connectionID = this.connectionID;

    exec(function(result){
        console.log("closeRTCPeerConnection result", result)
        if(callback)
          callback();
    }, function(err){
        console.error(err);
    }, "iosWebRTCPlugin", "closeRTCPeerConnection", [connectionID, sessionDescription]);
}

module.exports = RTCPeerConnection;

});
